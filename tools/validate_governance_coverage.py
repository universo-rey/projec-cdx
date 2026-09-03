"""Validate declared validator coverage against executable repository paths."""

from __future__ import annotations

import argparse
import ast
import csv
import re
import shlex
from pathlib import Path, PureWindowsPath

import yaml

EXECUTION_MODES = {"ci", "nested", "manual", "historical"}
APPROVED_WORKFLOW = "APPROVED_GITHUB_ACTIONS_SURFACE"


def _path(root: Path, raw: str) -> Path:
    windows_path = PureWindowsPath(raw.strip())
    posix_path = Path(windows_path.as_posix())
    if windows_path.is_absolute() or posix_path.is_absolute() or ".." in posix_path.parts:
        raise ValueError(f"path escapes repository: {raw}")
    candidate = (root / posix_path).resolve()
    if not candidate.is_relative_to(root.resolve()):
        raise ValueError(f"path escapes repository: {raw}")
    return candidate


def _parts(raw: str) -> list[str]:
    return [PureWindowsPath(value.strip()).as_posix() for value in raw.split("|") if value.strip()]


def _workflow_commands(path: Path) -> str:
    document = yaml.safe_load(path.read_text(encoding="utf-8")) or {}

    def disabled(value: object) -> bool:
        if value is False:
            return True
        if not isinstance(value, str):
            return False
        normalized = re.sub(r"\s+", "", value).lower()
        return normalized in {"false", "${{false}}"}

    return "\n".join(
        step["run"]
        for job in (document.get("jobs") or {}).values()
        if isinstance(job, dict) and not disabled(job.get("if"))
        for step in (job.get("steps") or [])
        if isinstance(step, dict)
        and not disabled(step.get("if"))
        and isinstance(step.get("run"), str)
    )


def _shell_invokes(commands: str, raw: str) -> bool:
    module = raw.removesuffix(".py").replace("/", ".")
    # A declaration does not execute its body. Reject function-contained
    # commands as proof unless reachability is modeled explicitly elsewhere.
    executable_lines = []
    function_depth = 0
    for candidate in commands.splitlines():
        if function_depth == 0 and re.match(r"^\s*(?:function\s+)?[A-Za-z_][\w-]*\s*(?:\(\))?\s*\{", candidate):
            function_depth = candidate.count("{") - candidate.count("}")
            continue
        if function_depth:
            function_depth += candidate.count("{") - candidate.count("}")
            continue
        executable_lines.append(candidate)
    for line in executable_lines:
        try:
            tokens = shlex.split(line, comments=True, posix=True)
        except ValueError:
            continue
        segments: list[tuple[str | None, list[str]]] = [(None, [])]
        for token in tokens:
            if token in {"&&", "||", ";", "|"}:
                segments.append((token, []))
            else:
                segments[-1][1].append(token)
        for segment_index, (preceding_operator, segment) in enumerate(segments):
            if not segment:
                continue
            # The right-hand side of ``||`` is skipped when the left-hand side
            # succeeds, so its mere presence cannot prove reachability.
            if preceding_operator == "||":
                continue
            if (
                preceding_operator == "&&"
                and segment_index > 0
                and segments[segment_index - 1][1]
                and segments[segment_index - 1][1][0].lower() == "false"
            ):
                continue
            executable = PureWindowsPath(segment[0]).name.lower()
            if executable in {"python", "python3"}:
                if len(segment) >= 3 and segment[1] == "-m" and segment[2] == module:
                    return True
                # For direct execution the validator must be Python's script
                # operand, not data passed to another script or ``python -c``.
                script_index = 1
                while script_index < len(segment) and segment[script_index] in {
                    "-B",
                    "-E",
                    "-I",
                    "-O",
                    "-OO",
                    "-P",
                    "-q",
                    "-s",
                    "-S",
                    "-u",
                    "-v",
                }:
                    script_index += 1
                if (
                    script_index < len(segment)
                    and not segment[script_index].startswith("-")
                    and PureWindowsPath(segment[script_index]).as_posix() == raw
                ):
                    return True
            elif PureWindowsPath(segment[0]).as_posix() == raw:
                return True
    return False


def _nested_callers(raw: str, source_text: dict[str, str]) -> list[str]:
    basename = PureWindowsPath(raw).name
    callers: list[str] = []
    for path, text in source_text.items():
        if path == raw:
            continue
        if raw.endswith(".py") and path.endswith(".py"):
            try:
                tree = ast.parse(text)
            except SyntaxError:
                continue
            for node in ast.walk(tree):
                if not isinstance(node, ast.Call):
                    continue
                function = node.func
                execution_api = (
                    isinstance(function, ast.Attribute)
                    and isinstance(function.value, ast.Name)
                    and (function.value.id, function.attr)
                    in {
                        ("subprocess", "run"),
                        ("subprocess", "call"),
                        ("subprocess", "check_call"),
                        ("subprocess", "check_output"),
                        ("subprocess", "Popen"),
                        ("os", "system"),
                        ("runpy", "run_path"),
                    }
                )
                invoked = False
                if execution_api and node.args:
                    try:
                        command = ast.literal_eval(node.args[0])
                    except (ValueError, TypeError):
                        command = None
                    if isinstance(command, str):
                        shell_enabled = any(
                            keyword.arg == "shell"
                            and isinstance(keyword.value, ast.Constant)
                            and keyword.value.value is True
                            for keyword in node.keywords
                        )
                        if isinstance(function.value, ast.Name) and function.value.id == "os":
                            invoked = _shell_invokes(command, raw)
                        elif isinstance(function.value, ast.Name) and function.value.id == "runpy":
                            invoked = PureWindowsPath(command).as_posix() == raw
                        elif shell_enabled:
                            invoked = _shell_invokes(command, raw)
                        else:
                            invoked = PureWindowsPath(command).as_posix() == raw
                    elif isinstance(command, (list, tuple)) and command:
                        invoked = _shell_invokes(
                            " ".join(shlex.quote(str(item)) for item in command), raw
                        )
                if execution_api and invoked:
                    callers.append(path)
                    break
            continue
        if not (raw.endswith(".ps1") and path.endswith(".ps1")):
            continue
        text = re.sub(r"@['\"](?s:.*?)['\"]@", "", text)
        text = re.sub(r"<\#(?s:.*?)\#>", "", text)
        executable_lines = []
        invocation_lines = []
        quote = None
        escaped = False
        for line in text.splitlines():
            if line.lstrip().startswith("#"):
                continue
            kept = []
            controls = []
            for character in line:
                if quote:
                    kept.append(character)
                    if quote == '"' and character == "`" and not escaped:
                        escaped = True
                    elif character == quote and not escaped:
                        quote = None
                    else:
                        escaped = False
                    controls.append(" ")
                elif character in {"'", '"'}:
                    quote = character
                    kept.append(character)
                    controls.append(" ")
                elif character == "#":
                    break
                else:
                    kept.append(character)
                    controls.append(character)
            executable_lines.append("".join(kept))
            invocation_lines.append("".join(controls))
        executable = "\n".join(executable_lines)
        invocation_text = "\n".join(invocation_lines)
        for variable in re.findall(
            rf"\$(\w+)\s*=\s*Join-Path[^\n#]*{re.escape(basename)}",
            executable,
            re.IGNORECASE,
        ):
            if re.search(rf"&\s*\${re.escape(variable)}\b", invocation_text):
                callers.append(path)
                break
            if re.search(rf"\bPath\s*=\s*\${re.escape(variable)}\b", executable) and re.search(
                r"&\s*\$validatorSpec\.Path\b", invocation_text, re.IGNORECASE
            ):
                callers.append(path)
                break
    return callers


def validate(root: Path, coverage: Path, workflows: Path) -> list[str]:
    errors: list[str] = []
    approved_workflows: list[Path] = []

    with workflows.open(encoding="utf-8-sig", newline="") as handle:
        for row in csv.DictReader(handle):
            if row["status"] != APPROVED_WORKFLOW:
                continue
            try:
                workflow = _path(root, row["path"])
            except ValueError as exc:
                errors.append(f"{row['workflow_id']}: {exc}")
                continue
            if not workflow.is_file():
                errors.append(f"{row['workflow_id']}: approved workflow is absent: {row['path']}")
            else:
                approved_workflows.append(workflow)

    workflow_text = "\n".join(_workflow_commands(path) for path in approved_workflows)
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
            status = row["coverage_status"].strip().lower()
            if mode not in EXECUTION_MODES:
                errors.append(f"{row['artifact_class']}: invalid execution_mode: {mode}")
                continue
            expected_status = "historical" if mode == "historical" else "covered"
            if status != expected_status:
                errors.append(
                    f"{row['artifact_class']}: execution_mode={mode} requires coverage_status={expected_status}"
                )
            indexes = _parts(row["required_index"])
            validators = _parts(row["required_validator"])
            valid_indexes: list[tuple[str, Path]] = []
            for raw in indexes:
                try:
                    valid_indexes.append((raw, _path(root, raw)))
                except ValueError as exc:
                    errors.append(f"{row['artifact_class']}: {exc}")
            if mode != "historical":
                if not indexes:
                    errors.append(f"{row['artifact_class']}: active row lacks required_index")
                if not validators:
                    errors.append(f"{row['artifact_class']}: active row lacks required_validator")
                for raw, index in valid_indexes:
                    if not index.exists():
                        errors.append(f"{row['artifact_class']}: active index is absent: {raw}")
            for raw in validators:
                try:
                    validator = _path(root, raw)
                except ValueError as exc:
                    errors.append(f"{row['artifact_class']}: {exc}")
                    continue
                if mode != "historical" and not validator.is_file():
                    errors.append(f"{row['artifact_class']}: active validator is absent: {raw}")
                    continue
                if mode == "historical":
                    continue
                if mode == "ci" and not _shell_invokes(workflow_text, raw):
                    errors.append(
                        f"{row['artifact_class']}: CI validator is not reachable from an approved workflow: {raw}"
                    )
                if mode == "nested":
                    callers = _nested_callers(raw, source_text)
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
