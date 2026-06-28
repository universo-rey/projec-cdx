from __future__ import annotations

import json
from collections.abc import Iterable
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any

import yaml
from jsonschema import Draft202012Validator

from .path_policy import canonical_path, normalize_path_value

IGNORED_PARTS = {
    ".git",
    ".mypy_cache",
    ".pytest_cache",
    ".ruff_cache",
    "__pycache__",
    "dist-packages",
    "node_modules",
    "site-packages",
}
IGNORED_ENV_NAMES = {".env", ".venv", "env", "venv"}
EXTERNAL_METADATA_ROOTS = (
    Path(".agent"),
    Path(".agents"),
    Path(".cursor"),
    Path(".github/agents"),
    Path(".github/skills"),
    Path("_archive_noise"),
    Path("operativa/tasks"),
    Path("outputs"),
)
CORE_ONLY_ROOTS = (Path("src"), Path("tests"), Path("tools"), Path("operativa"))


@dataclass(frozen=True)
class MetadataRecord:
    source_path: str
    metadata: dict[str, Any]
    kind: str


@dataclass(frozen=True)
class ValidationErrorItem:
    source_path: str
    message: str
    field_path: str


@dataclass(frozen=True)
class ValidationResult:
    records: list[MetadataRecord]
    errors: list[ValidationErrorItem]
    ignored_errors: list[str] = field(default_factory=list)

    @property
    def is_valid(self) -> bool:
        return not self.errors


def _strip_dataset_extension(path: str) -> str | None:
    for ext in (".csv", ".json"):
        if path.endswith(ext):
            return path[: -len(ext)]
    return None


def _artifact_id_convention_error(record: MetadataRecord) -> str | None:
    artifact_id = canonical_path(record.metadata.get("artifact_id"))
    repo_path = canonical_path(record.metadata.get("ubicacion_repo"))
    if not isinstance(artifact_id, str) or not isinstance(repo_path, str):
        return None

    if record.kind == "front_matter" and repo_path.endswith(".md"):
        if artifact_id != repo_path:
            return "convencion artifact_id: Markdown debe usar la ruta con extension .md"
        return None

    if record.kind == "meta_json":
        expected = _strip_dataset_extension(repo_path)
        if expected and artifact_id != expected:
            return "convencion artifact_id: datasets CSV/JSON deben usar la ruta sin extension"
    return None


def load_schema(schema_path: Path) -> dict[str, Any]:
    return json.loads(schema_path.read_text(encoding="utf-8"))


def _is_ignored(path: Path) -> bool:
    parts = [part.lower() for part in path.parts]
    return any(
        part in IGNORED_PARTS or part in IGNORED_ENV_NAMES or part.startswith(".venv")
        for part in parts
    )


def _is_relative_to(path: Path, parent: Path) -> bool:
    try:
        path.relative_to(parent)
        return True
    except ValueError:
        return False


def _is_under_any(path: Path, roots: Iterable[Path]) -> bool:
    return any(_is_relative_to(path, root) for root in roots)


def _display_path(path: Path) -> str:
    return str(path).replace("\\", "/")


def _discover_virtualenv_roots(root: Path) -> list[Path]:
    roots: list[Path] = []
    for config_path in root.rglob("pyvenv.cfg"):
        try:
            rel = config_path.parent.relative_to(root)
        except ValueError:
            continue
        roots.append(rel)
    return roots


def _should_skip(
    path: Path,
    virtualenv_roots: list[Path],
    excluded_roots: Iterable[Path],
) -> bool:
    return (
        _is_ignored(path)
        or _is_under_any(path, virtualenv_roots)
        or _is_under_any(path, excluded_roots)
    )


def parse_front_matter(path: Path) -> dict[str, Any] | None:
    raw = path.read_text(encoding="utf-8")
    if not raw.startswith("---\n"):
        return None
    marker = "\n---\n"
    end_idx = raw.find(marker, 4)
    if end_idx == -1:
        return None
    block = raw[4:end_idx]
    data = yaml.safe_load(block) or {}
    if not isinstance(data, dict):
        raise ValueError(f"Front matter in {path} must be a mapping")
    return data


def dump_front_matter(metadata: dict[str, Any]) -> str:
    return f"---\n{yaml.safe_dump(metadata, sort_keys=False, allow_unicode=True)}---\n"


def replace_front_matter(path: Path, metadata: dict[str, Any]) -> None:
    raw = path.read_text(encoding="utf-8")
    marker = "\n---\n"
    if raw.startswith("---\n"):
        end_idx = raw.find(marker, 4)
        if end_idx != -1:
            content = raw[end_idx + len(marker) :]
            path.write_text(f"{dump_front_matter(metadata)}{content}", encoding="utf-8")
            return
    path.write_text(f"{dump_front_matter(metadata)}\n{raw}", encoding="utf-8")


def _scan_patterns(
    root: Path,
    include_roots: Iterable[Path] | None,
    pattern: str,
) -> Iterable[Path]:
    if include_roots:
        for include_root in include_roots:
            scan_root = root / include_root
            if scan_root.exists():
                yield from scan_root.rglob(pattern)
        return
    yield from root.rglob(pattern)


def discover_metadata_records(
    root: Path,
    include_roots: Iterable[Path] | None = None,
) -> tuple[list[MetadataRecord], list[str], list[ValidationErrorItem]]:
    records: list[MetadataRecord] = []
    ignored_errors: list[str] = []
    parse_errors: list[ValidationErrorItem] = []
    virtualenv_roots = _discover_virtualenv_roots(root)
    excluded_roots = EXTERNAL_METADATA_ROOTS

    for md_path in _scan_patterns(root, include_roots, "*.md"):
        rel = md_path.relative_to(root)
        if _should_skip(rel, virtualenv_roots, excluded_roots):
            if _is_under_any(rel, excluded_roots):
                ignored_errors.append(f"{_display_path(rel)} :: excluded external metadata scope")
            continue
        try:
            front_matter = parse_front_matter(md_path)
        except (ValueError, yaml.YAMLError, UnicodeDecodeError) as exc:
            parse_errors.append(
                ValidationErrorItem(
                    source_path=_display_path(rel),
                    message=f"front matter invalido: {exc}",
                    field_path="<root>",
                )
            )
            continue
        if front_matter:
            records.append(
                MetadataRecord(
                    source_path=_display_path(rel),
                    metadata=normalize_path_value(front_matter),
                    kind="front_matter",
                )
            )

    for meta_path in _scan_patterns(root, include_roots, "*.meta.json"):
        rel = meta_path.relative_to(root)
        if _should_skip(rel, virtualenv_roots, excluded_roots):
            if _is_under_any(rel, excluded_roots):
                ignored_errors.append(f"{_display_path(rel)} :: excluded external metadata scope")
            continue
        try:
            payload = json.loads(meta_path.read_text(encoding="utf-8"))
        except (json.JSONDecodeError, UnicodeDecodeError) as exc:
            parse_errors.append(
                ValidationErrorItem(
                    source_path=_display_path(rel),
                    message=f"json invalido: {exc}",
                    field_path="<root>",
                )
            )
            continue
        if not isinstance(payload, dict):
            parse_errors.append(
                ValidationErrorItem(
                    source_path=_display_path(rel),
                    message=f"metadata file must be an object: {meta_path}",
                    field_path="<root>",
                )
            )
            continue
        records.append(
            MetadataRecord(
                source_path=_display_path(rel),
                metadata=normalize_path_value(payload),
                kind="meta_json",
            )
        )

    return records, ignored_errors, parse_errors


def validate_repository(
    root: Path,
    schema_path: Path,
    include_roots: Iterable[Path] | None = None,
) -> ValidationResult:
    schema = load_schema(schema_path)
    validator = Draft202012Validator(schema)
    records, ignored_errors, parse_errors = discover_metadata_records(
        root, include_roots=include_roots
    )
    errors: list[ValidationErrorItem] = []
    errors.extend(parse_errors)

    seen_artifacts: dict[str, str] = {}
    for record in records:
        for err in validator.iter_errors(record.metadata):
            field_path = ".".join(str(part) for part in err.path) or "<root>"
            errors.append(
                ValidationErrorItem(
                    source_path=record.source_path,
                    message=err.message,
                    field_path=field_path,
                )
            )
        artifact_id = canonical_path(record.metadata.get("artifact_id"))
        if isinstance(artifact_id, str) and artifact_id:
            if artifact_id in seen_artifacts:
                errors.append(
                    ValidationErrorItem(
                        source_path=record.source_path,
                        message=f"artifact_id duplicado con {seen_artifacts[artifact_id]}",
                        field_path="artifact_id",
                    )
                )
            else:
                seen_artifacts[artifact_id] = record.source_path

        convention_error = _artifact_id_convention_error(record)
        if convention_error:
            errors.append(
                ValidationErrorItem(
                    source_path=record.source_path,
                    message=convention_error,
                    field_path="artifact_id",
                )
            )

    return ValidationResult(records=records, errors=errors, ignored_errors=ignored_errors)
