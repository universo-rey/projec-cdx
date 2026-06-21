from __future__ import annotations

import json
from dataclasses import dataclass
from pathlib import Path
from typing import Any

import yaml
from jsonschema import Draft202012Validator

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

    @property
    def is_valid(self) -> bool:
        return not self.errors


def _strip_dataset_extension(path: str) -> str | None:
    for ext in (".csv", ".json"):
        if path.endswith(ext):
            return path[: -len(ext)]
    return None


def _artifact_id_convention_error(record: MetadataRecord) -> str | None:
    artifact_id = record.metadata.get("artifact_id")
    repo_path = record.metadata.get("ubicacion_repo")
    if not isinstance(artifact_id, str) or not isinstance(repo_path, str):
        return None

    if record.kind == "front_matter" and repo_path.endswith(".md"):
        if artifact_id != repo_path:
            return "convencion artifact_id: Markdown debe usar la ruta con extension .md"
        return None

    if record.kind == "meta_json":
        expected = _strip_dataset_extension(repo_path)
        if expected and artifact_id != expected:
            return (
                "convencion artifact_id: datasets CSV/JSON deben usar la ruta sin extension"
            )
    return None


def load_schema(schema_path: Path) -> dict[str, Any]:
    return json.loads(schema_path.read_text(encoding="utf-8"))


def _is_ignored(path: Path) -> bool:
    parts = [part.lower() for part in path.parts]
    return any(
        part in IGNORED_PARTS
        or part in IGNORED_ENV_NAMES
        or part.startswith(".venv")
        for part in parts
    )


def _is_relative_to(path: Path, parent: Path) -> bool:
    try:
        path.relative_to(parent)
        return True
    except ValueError:
        return False


def _discover_virtualenv_roots(root: Path) -> list[Path]:
    roots: list[Path] = []
    for config_path in root.rglob("pyvenv.cfg"):
        try:
            rel = config_path.parent.relative_to(root)
        except ValueError:
            continue
        roots.append(rel)
    return roots


def _should_skip(path: Path, virtualenv_roots: list[Path]) -> bool:
    return _is_ignored(path) or any(_is_relative_to(path, root) for root in virtualenv_roots)


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


def discover_metadata_records(root: Path) -> list[MetadataRecord]:
    records: list[MetadataRecord] = []
    virtualenv_roots = _discover_virtualenv_roots(root)

    for md_path in root.rglob("*.md"):
        rel = md_path.relative_to(root)
        if _should_skip(rel, virtualenv_roots):
            continue
        front_matter = parse_front_matter(md_path)
        if front_matter:
            records.append(
                MetadataRecord(
                    source_path=str(rel).replace("\\", "/"),
                    metadata=front_matter,
                    kind="front_matter",
                )
            )

    for meta_path in root.rglob("*.meta.json"):
        rel = meta_path.relative_to(root)
        if _should_skip(rel, virtualenv_roots):
            continue
        payload = json.loads(meta_path.read_text(encoding="utf-8"))
        if not isinstance(payload, dict):
            raise ValueError(f"Metadata file must be an object: {meta_path}")
        records.append(
            MetadataRecord(
                source_path=str(rel).replace("\\", "/"),
                metadata=payload,
                kind="meta_json",
            )
        )

    return records


def validate_repository(root: Path, schema_path: Path) -> ValidationResult:
    schema = load_schema(schema_path)
    validator = Draft202012Validator(schema)
    records = discover_metadata_records(root)
    errors: list[ValidationErrorItem] = []

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
        artifact_id = record.metadata.get("artifact_id")
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

    return ValidationResult(records=records, errors=errors)
