"""Validate declared validator coverage against executable repository paths."""

from __future__ import annotations

import argparse
import csv
from pathlib import Path, PureWindowsPath

EXECUTION_MODES = {"ci", "nested", "manual", "historical"}
APPROVED_WORKFLOW = "APPROVED_GITHUB_ACTIONS_SURFACE"


def _path(root: Path, raw: str) -> Path:
    return root / PureWindowsPath(raw.strip()).as_posix()


def _parts(raw: str) -> list[str]:
    return [PureWindowsPath(value.strip()).as_posix() for value in raw.split("|") if value.strip()]


def validate(root: Path, coverage: Path, workflows: Path) -> list[str]:
    errors: list[str] = []
    approved_workflows: list[Path] = []

    with workflows.open(encoding="utf-8-sig", newline="") as handle:
        for row in csv.DictReader(handle):
            if row["status"] != APPROVED_WORKFLOW:
                continue
            workflow = _path(root, row["path"])
            if not workflow.is_file():
                errors.append(f"{row['workflow_id']}: approved workflow is absent: {row['path']}")
            else:
                approved_workflows.append(workflow)

    workflow_text = "\n".join(path.read_text(encoding="utf-8") for path in approved_workflows)
    source_text: dict[str, str] = {}
    for suffix in ("*.py", "*.ps1"):
        for path in root.rglob(suffix):
            if ".git" not in path.parts:
                source_text[path.relative_to(root).as_posix()] = path.read_text(
                    encoding="utf-8", errors="ignore"
                )

    with coverage.open(encoding="utf-8-sig", newline="") as handle:
        reader = csv.DictReader(handle)
        if "execution_mode" not in (reader.fieldnames or []):
            return ["coverage matrix lacks execution_mode"]
        for row in reader:
            mode = row["execution_mode"].strip().lower()
            if mode not in EXECUTION_MODES:
                errors.append(f"{row['artifact_class']}: invalid execution_mode: {mode}")
                continue
            for raw in _parts(row["required_validator"]):
                validator = _path(root, raw)
                if mode != "historical" and not validator.is_file():
                    errors.append(f"{row['artifact_class']}: active validator is absent: {raw}")
                    continue
                if mode == "historical":
                    if row["coverage_status"].strip().lower() == "covered":
                        errors.append(
                            f"{row['artifact_class']}: historical validator cannot claim covered: {raw}"
                        )
                    continue
                if mode == "ci" and raw not in workflow_text:
                    module = raw.removesuffix(".py").replace("/", ".")
                    if f"python -m {module}" not in workflow_text:
                        errors.append(
                            f"{row['artifact_class']}: CI validator is not reachable from an approved workflow: {raw}"
                        )
                if mode == "nested":
                    callers = [
                        path
                        for path, text in source_text.items()
                        if path != raw and (raw in text or PureWindowsPath(raw).name in text)
                    ]
                    if not callers:
                        errors.append(
                            f"{row['artifact_class']}: nested validator has no repo-local caller: {raw}"
                        )
    return errors


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", type=Path, default=Path.cwd())
    parser.add_argument(
        "--coverage",
        type=Path,
        default=Path(".agents/codex/matrices/VALIDATION_COVERAGE_MATRIX.csv"),
    )
    parser.add_argument(
        "--workflows",
        type=Path,
        default=Path(".agents/codex/matrices/GITHUB_ACTIONS_WORKFLOW_MATRIX.csv"),
    )
    args = parser.parse_args()
    root = args.root.resolve()
    errors = validate(root, root / args.coverage, root / args.workflows)
    if errors:
        print("GOVERNANCE_COVERAGE: FAIL")
        for error in errors:
            print(f"- {error}")
        return 1
    print("GOVERNANCE_COVERAGE: PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
