"""Validate promoted operational surfaces without granting overlay authority."""

from __future__ import annotations

import csv
import json
from pathlib import Path, PureWindowsPath

import yaml

ROOT = Path(__file__).resolve().parents[1]
COVERAGE = ROOT / ".agents/codex/matrices/VALIDATION_COVERAGE_MATRIX.csv"
ACTIVE_MODES = {"ci", "nested"}
EXTERNAL_PROVIDERS = {"openai-agents-sdk", "codex-cloud"}


def _parts(raw: str) -> list[str]:
    return [PureWindowsPath(item.strip()).as_posix() for item in raw.split("|") if item.strip()]


def _repo_path(root: Path, raw: str) -> Path:
    relative = Path(PureWindowsPath(raw).as_posix())
    if relative.is_absolute() or ".." in relative.parts:
        raise ValueError(f"path escapes repository: {raw}")
    target = (root / relative).resolve()
    if not target.is_relative_to(root.resolve()):
        raise ValueError(f"path escapes repository: {raw}")
    return target


def _parseable(path: Path) -> bool:
    if path.suffix.lower() == ".csv":
        with path.open(encoding="utf-8-sig", newline="") as handle:
            reader = csv.reader(handle)
            return bool(next(reader, [])) and any(
                any(cell.strip() for cell in row) for row in reader
            )
    if path.suffix.lower() == ".json":
        json.loads(path.read_text(encoding="utf-8"))
    elif path.suffix.lower() in {".yaml", ".yml"}:
        yaml.safe_load(path.read_text(encoding="utf-8"))
    return path.stat().st_size > 0


def validate(coverage: Path = COVERAGE, root: Path = ROOT) -> list[str]:
    errors: list[str] = []
    with coverage.open(encoding="utf-8-sig", newline="") as handle:
        reader = csv.DictReader(handle)
        required = {
            "artifact_class",
            "lifecycle_state",
            "promotion_wave",
            "coverage_status",
            "execution_mode",
            "required_index",
            "provider",
            "provider_version",
            "superseded_by",
        }
        missing = required - set(reader.fieldnames or [])
        if missing:
            return [f"coverage matrix lacks fields: {','.join(sorted(missing))}"]
        for row in reader:
            name = row["artifact_class"]
            lifecycle = row["lifecycle_state"].strip().lower()
            promotion_wave = row["promotion_wave"].strip().lower()
            mode = row["execution_mode"].strip().lower()
            status = row["coverage_status"].strip().lower()
            if lifecycle == "active":
                if status != "covered" or mode == "historical":
                    errors.append(f"{name}: ACTIVE cannot be historical")
                if promotion_wave == "legacy-recovery" and mode not in ACTIVE_MODES:
                    errors.append(
                        f"{name}: recovered ACTIVE surface must be reachable through ci|nested"
                    )
                if row["superseded_by"].strip():
                    errors.append(f"{name}: ACTIVE cannot declare superseded_by")
                for raw in _parts(row["required_index"]):
                    try:
                        path = _repo_path(root, raw)
                        if not path.exists():
                            errors.append(f"{name}: active index is absent: {raw}")
                        elif not _parseable(path):
                            errors.append(f"{name}: active index is empty or invalid: {raw}")
                    except (
                        ValueError,
                        OSError,
                        csv.Error,
                        json.JSONDecodeError,
                        yaml.YAMLError,
                    ) as exc:
                        errors.append(f"{name}: invalid active index {raw}: {exc}")
            elif lifecycle == "superseded":
                if mode != "historical" or status != "historical":
                    errors.append(f"{name}: SUPERSEDED must use historical mode/status")
                replacement = row["superseded_by"].strip()
                if not replacement:
                    errors.append(f"{name}: historical row lacks superseded_by evidence")
                else:
                    try:
                        if not _repo_path(root, replacement).exists():
                            errors.append(f"{name}: superseding evidence is absent: {replacement}")
                    except ValueError as exc:
                        errors.append(f"{name}: {exc}")
            else:
                errors.append(f"{name}: invalid lifecycle_state: {lifecycle}")
            provider = row["provider"].strip().lower()
            version = row["provider_version"].strip()
            if provider and provider not in EXTERNAL_PROVIDERS:
                errors.append(f"{name}: unknown external provider: {provider}")
            if provider and not version:
                errors.append(f"{name}: external provider lacks version")

    environment = json.loads(
        (root / "contracts/environment-contract.json").read_text(encoding="utf-8")
    )
    rules = " ".join(environment.get("consistencyRules", [])).lower()
    if "overlay" not in rules or "not" not in rules or "authority" not in rules:
        errors.append("project-cdx overlay contract must deny federal authority")
    return errors


def main() -> int:
    errors = validate()
    if errors:
        print("ACTIVE_SURFACE_CONTRACT: FAIL")
        for error in errors:
            print(f"- {error}")
        return 1
    print("ACTIVE_SURFACE_CONTRACT: PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
