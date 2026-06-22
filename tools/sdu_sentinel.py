from __future__ import annotations

import argparse
import json
import subprocess
import sys
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
CONFIG_PATH = ROOT / "operativa" / "SDU_SENTINEL_CONFIG_20260622.json"
BOUNDARY_PATH = ROOT / "operativa" / "SDU_RUNTIME_BOUNDARY_MATRIX.json"
STATE_PATH = ROOT / "operativa" / "SENTINEL_STATE.md"
EVENTS_PATH = ROOT / "operativa" / "SENTINEL_EVENTS.jsonl"

EXTERNAL_SURFACES = {
    "github",
    "openai",
    "microsoft",
    "sharepoint",
    "dataverse",
    "power_platform",
    "codex_cloud",
}

SKIP_PARTS = {".git", ".venv", "node_modules", "__pycache__", "dist", "build"}
TEXT_SUFFIXES = {".ps1", ".py", ".toml", ".json", ".yml", ".yaml", ".sh"}


@dataclass(frozen=True)
class SentinelCheck:
    name: str
    status: str
    detail: str


def _utc_now() -> str:
    return datetime.now(timezone.utc).isoformat(timespec="seconds").replace("+00:00", "Z")


def _load_json(path: Path) -> dict[str, Any]:
    return json.loads(path.read_text(encoding="utf-8"))


def _run(command: list[str], cwd: Path = ROOT) -> subprocess.CompletedProcess[str]:
    return subprocess.run(command, cwd=cwd, text=True, capture_output=True)


def _git_status(root: Path = ROOT) -> list[str]:
    result = _run(["git", "status", "--porcelain=v1"], root)
    if result.returncode != 0:
        return [f"git_status_error:{result.stderr.strip()}"]
    return [line for line in result.stdout.splitlines() if line.strip()]


def _safe_relative(path: Path, root: Path = ROOT) -> str:
    try:
        return path.resolve().relative_to(root.resolve()).as_posix()
    except ValueError:
        return str(path)


def _iter_scannable_files(root: Path = ROOT) -> list[Path]:
    files: list[Path] = []
    for path in root.rglob("*"):
        if not path.is_file():
            continue
        if any(part in SKIP_PARTS for part in path.parts):
            continue
        if path.name.startswith(".env"):
            continue
        if path.suffix.lower() not in TEXT_SUFFIXES:
            continue
        files.append(path)
    return files


def _scan_blocked_patterns(config: dict[str, Any], root: Path = ROOT) -> list[str]:
    patterns = [str(item) for item in config.get("blocked_patterns", [])]
    hits: list[str] = []
    for path in _iter_scannable_files(root):
        if path in {CONFIG_PATH, EVENTS_PATH}:
            continue
        try:
            text = path.read_text(encoding="utf-8")
        except UnicodeDecodeError:
            continue
        for pattern in patterns:
            if pattern and pattern in text:
                hits.append(_safe_relative(path, root))
                break
    return sorted(set(hits))


def load_config() -> dict[str, Any]:
    return _load_json(CONFIG_PATH)


def load_boundary() -> dict[str, Any]:
    return _load_json(BOUNDARY_PATH)


def classify_status_lines(status_lines: list[str]) -> str:
    if not status_lines:
        return "NO_DRIFT"

    paths = [line[3:] if len(line) > 3 else line for line in status_lines]
    normalized = [path.replace("\\", "/") for path in paths]

    if any(path.startswith(".env") or "/.env" in path for path in normalized):
        return "SECRET_RISK_DRIFT"
    if any(path == "operativa/SDU_RUNTIME_BOUNDARY_MATRIX.json" for path in normalized):
        return "BOUNDARY_POLICY_DRIFT"
    if any(
        path in {"index.json", "live-manifest.json", "operativa/index.json"} for path in normalized
    ):
        return "EXPECTED_INDEX_REFRESH"
    if any(
        path.startswith("docs/") or path.startswith("operativa/READBACK_") for path in normalized
    ):
        return "EXPECTED_DOC_DRIFT"
    if any(
        path
        in {
            "tools/sdu_boot.ps1",
            "tools/sdu_chain_resolver.py",
            "schema.json",
        }
        for path in normalized
    ):
        return "UNEXPECTED_RUNTIME_DRIFT"
    if any(path.startswith("operativa/") for path in normalized):
        return "EVIDENCE_GAP_DRIFT"
    return "BLOCKING_DRIFT"


def scan(root: Path = ROOT) -> dict[str, Any]:
    checks: list[SentinelCheck] = []

    config_exists = CONFIG_PATH.exists()
    boundary_exists = BOUNDARY_PATH.exists()
    checks.append(
        SentinelCheck(
            "sentinel_config_present",
            "PASS" if config_exists else "FAIL",
            _safe_relative(CONFIG_PATH, root),
        )
    )
    checks.append(
        SentinelCheck(
            "boundary_matrix_present",
            "PASS" if boundary_exists else "FAIL",
            _safe_relative(BOUNDARY_PATH, root),
        )
    )

    config: dict[str, Any] = _load_json(CONFIG_PATH) if config_exists else {}
    boundary: dict[str, Any] = _load_json(BOUNDARY_PATH) if boundary_exists else {}

    watched_files = [str(item) for item in config.get("watched_files", [])]
    missing = [item for item in watched_files if not (root / item).exists()]
    checks.append(
        SentinelCheck(
            "watched_files_present",
            "PASS" if not missing else "FAIL",
            "missing=none" if not missing else "missing=" + ",".join(missing),
        )
    )

    default_mode = str(boundary.get("default_mode", ""))
    checks.append(
        SentinelCheck(
            "boundary_default_no_external",
            "PASS" if default_mode == "NO_EXTERNAL" else "FAIL",
            default_mode or "missing",
        )
    )

    status_lines = _git_status(root)
    drift = classify_status_lines(status_lines)
    checks.append(
        SentinelCheck(
            "git_clean",
            "PASS" if not status_lines else "WARN",
            "clean" if not status_lines else f"{len(status_lines)} local changes",
        )
    )

    blocked_hits = _scan_blocked_patterns(config, root) if config else []
    checks.append(
        SentinelCheck(
            "blocked_patterns",
            "PASS" if not blocked_hits else "BLOCKING",
            "none" if not blocked_hits else ",".join(blocked_hits),
        )
    )

    statuses = [check.status for check in checks]
    if "FAIL" in statuses or "BLOCKING" in statuses:
        status = "BLOCK"
    elif "WARN" in statuses:
        status = "WARN"
    else:
        status = "PASS"

    return {
        "status": status,
        "sentinel_id": config.get("sentinel_id", "SDU_SENTINEL_LAYER"),
        "mode": config.get("mode", "LOCAL_FIRST"),
        "drift": drift,
        "checks": [check.__dict__ for check in checks],
        "no_external": True,
    }


def guard(
    surface: str,
    action: str,
    gate: str | None,
    owner: str | None,
    rollback: str | None,
    postcheck: str | None,
    evidence: str | None,
) -> dict[str, Any]:
    normalized_surface = surface.lower()
    if normalized_surface == "local":
        return {
            "decision": "ALLOWED_LOCAL",
            "surface": normalized_surface,
            "action": action,
            "reason": "local action allowed under validation",
        }

    if normalized_surface in EXTERNAL_SURFACES and not gate:
        return {
            "decision": "BLOCKED_WITHOUT_GATE",
            "surface": normalized_surface,
            "action": action,
            "reason": "external surface requires explicit gate",
        }

    missing = [
        name
        for name, value in {
            "owner": owner,
            "rollback": rollback,
            "postcheck": postcheck,
            "evidence": evidence,
        }.items()
        if not value
    ]
    if normalized_surface in EXTERNAL_SURFACES and missing:
        return {
            "decision": "GATE_INCOMPLETE_BLOCKED",
            "surface": normalized_surface,
            "action": action,
            "reason": "missing=" + ",".join(missing),
        }

    return {
        "decision": "ALLOW_WITH_GATE_DRY_RUN",
        "surface": normalized_surface,
        "action": action,
        "reason": "gate metadata complete; no external execution performed",
    }


def append_event(event: dict[str, Any], events_path: Path = EVENTS_PATH) -> None:
    events_path.parent.mkdir(parents=True, exist_ok=True)
    with events_path.open("a", encoding="utf-8", newline="\n") as handle:
        handle.write(json.dumps(event, ensure_ascii=True, sort_keys=True) + "\n")


def make_event(
    category: str, severity: str, decision: str, surface: str, evidence: list[str], notes: str
) -> dict[str, Any]:
    timestamp = _utc_now()
    return {
        "timestamp_utc": timestamp,
        "event_id": "SENTINEL-" + timestamp[:10].replace("-", "") + "-001",
        "severity": severity,
        "category": category,
        "surface": surface,
        "decision": decision,
        "evidence": evidence,
        "notes": notes,
    }


def write_report(root: Path = ROOT) -> dict[str, Any]:
    payload = scan(root)
    state = [
        "# SDU SENTINEL STATE",
        "",
        "## Estado",
        (
            "SDU_SENTINEL_ACTIVE_LOCAL_GOVERNED"
            if payload["status"] in {"PASS", "WARN"}
            else "SDU_SENTINEL_BLOCKED"
        ),
        "",
        "## Modo",
        "LOCAL_FIRST",
        "NO_EXTERNAL_BY_DEFAULT",
        "",
        "## Frontera activa",
        "- local: permitido bajo validacion",
        "- github: BLOCKED_WITHOUT_GATE",
        "- openai: BLOCKED_WITHOUT_GATE",
        "- microsoft: BLOCKED_WITHOUT_GATE",
        "- sharepoint: BLOCKED_WITHOUT_GATE",
        "- dataverse: BLOCKED_WITHOUT_GATE",
        "- power_platform: BLOCKED_WITHOUT_GATE",
        "- codex_cloud: BLOCKED_WITHOUT_GATE",
        "",
        "## Checks obligatorios",
        "- git_clean",
        "- boundary_matrix_present",
        "- boot_pass",
        "- resolver_pass",
        "- tests_pass",
        "- metadata_valid",
        "- no_secret_print",
        "- no_external_execution",
        "",
        "## Ultimo resultado",
        payload["status"],
        "",
        "## Drift",
        payload["drift"],
        "",
    ]
    STATE_PATH.write_text("\n".join(state), encoding="utf-8")
    append_event(
        make_event(
            category="VALIDATION",
            severity="INFO" if payload["status"] == "PASS" else "WARN",
            decision="ALLOW" if payload["status"] in {"PASS", "WARN"} else "BLOCK",
            surface="local",
            evidence=["operativa/SENTINEL_STATE.md"],
            notes=f"sentinel report status={payload['status']}",
        )
    )
    return payload


def run_check(root: Path = ROOT) -> dict[str, Any]:
    commands = [
        [
            "powershell",
            "-NoProfile",
            "-ExecutionPolicy",
            "Bypass",
            "-File",
            str(root / "tools" / "sdu_boot.ps1"),
            "-Mode",
            "all",
            "-Agent",
            "All",
            "-NoExternal",
            "-DryRun",
            "-Json",
        ],
        [
            sys.executable,
            str(root / "tools" / "sdu_chain_resolver.py"),
            "--root",
            str(root),
            "--mode",
            "all",
            "--agent",
            "All",
            "--no-external",
            "--dry-run",
            "--json",
        ],
        [sys.executable, "-m", "tools.validate"],
        ["git", "diff", "--check"],
        [sys.executable, "-m", "pytest", "-q"],
    ]
    results: list[dict[str, Any]] = []
    for command in commands:
        result = _run(command, root)
        results.append(
            {
                "command": " ".join(command),
                "returncode": result.returncode,
                "stdout_tail": result.stdout.strip().splitlines()[-5:],
                "stderr_tail": result.stderr.strip().splitlines()[-5:],
            }
        )
        if result.returncode != 0:
            return {"status": "FAIL", "results": results}
    return {"status": "PASS", "results": results}


def _print(payload: dict[str, Any], as_json: bool) -> None:
    if as_json:
        print(json.dumps(payload, ensure_ascii=False, indent=2))
    else:
        print(payload.get("status") or payload.get("decision"))
        for key, value in payload.items():
            if key not in {"checks", "results"}:
                print(f"{key}: {value}")


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="SDU Sentinel local guard.")
    parser.add_argument("--json", action="store_true")
    subparsers = parser.add_subparsers(dest="command", required=True)
    scan_parser = subparsers.add_parser("scan")
    scan_parser.add_argument("--json", action="store_true")
    check_parser = subparsers.add_parser("check")
    check_parser.add_argument("--json", action="store_true")
    report_parser = subparsers.add_parser("report")
    report_parser.add_argument("--json", action="store_true")
    classify_parser = subparsers.add_parser("classify-drift")
    classify_parser.add_argument("--json", action="store_true")
    guard_parser = subparsers.add_parser("guard")
    guard_parser.add_argument("--json", action="store_true")
    guard_parser.add_argument("--surface", required=True)
    guard_parser.add_argument("--action", required=True)
    guard_parser.add_argument("--gate")
    guard_parser.add_argument("--owner")
    guard_parser.add_argument("--rollback")
    guard_parser.add_argument("--postcheck")
    guard_parser.add_argument("--evidence")
    return parser


def main(argv: list[str] | None = None) -> int:
    args = build_parser().parse_args(argv)
    if args.command == "scan":
        payload = scan(ROOT)
    elif args.command == "check":
        payload = run_check(ROOT)
    elif args.command == "report":
        payload = write_report(ROOT)
    elif args.command == "classify-drift":
        payload = {"status": "PASS", "drift": classify_status_lines(_git_status(ROOT))}
    elif args.command == "guard":
        payload = guard(
            args.surface,
            args.action,
            args.gate,
            args.owner,
            args.rollback,
            args.postcheck,
            args.evidence,
        )
    else:
        raise AssertionError(args.command)

    _print(payload, args.json)
    return 1 if payload.get("status") in {"FAIL", "BLOCK"} else 0


if __name__ == "__main__":
    raise SystemExit(main())
