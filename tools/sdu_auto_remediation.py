from __future__ import annotations

import argparse
import json
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

if __package__ in {None, ""}:
    sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from tools import sdu_sentinel


ROOT = Path(__file__).resolve().parents[1]
CONFIG_PATH = ROOT / "operativa" / "SDU_AUTO_REMEDIATION_CONFIG_20260622.json"

DRIFT_POLICIES = {
    "EXPECTED_DOC_DRIFT": "none",
    "EXPECTED_INDEX_REFRESH": "regenerate",
    "UNEXPECTED_RUNTIME_DRIFT": "rollback",
    "BOUNDARY_POLICY_DRIFT": "rollback",
    "SECRET_RISK_DRIFT": "block",
    "VALIDATOR_FAILURE": "rollback",
    "EVIDENCE_GAP_DRIFT": "regenerate_readback",
    "NO_DRIFT": "none",
    "BLOCKING_DRIFT": "block",
}


def _utc_now() -> str:
    return datetime.now(timezone.utc).isoformat(timespec="seconds").replace("+00:00", "Z")


def _next_event_id(prefix: str) -> str:
    date = _utc_now()[:10].replace("-", "")
    events_path = sdu_sentinel.EVENTS_PATH
    count = 0
    if events_path.exists():
        count = sum(1 for line in events_path.read_text(encoding="utf-8").splitlines() if f'"event_id": "{prefix}-{date}-' in line)
    return f"{prefix}-{date}-{count + 1:03d}"


def _run(command: list[str], cwd: Path) -> subprocess.CompletedProcess[str]:
    return subprocess.run(command, cwd=cwd, text=True, capture_output=True)


def _load_json(path: Path) -> dict[str, Any]:
    return json.loads(path.read_text(encoding="utf-8"))


def load_config() -> dict[str, Any]:
    return _load_json(CONFIG_PATH)


def _git_status(root: Path = ROOT) -> list[str]:
    result = _run(["git", "status", "--porcelain=v1"], root)
    if result.returncode != 0:
        return [f"git_status_error:{result.stderr.strip()}"]
    return [line for line in result.stdout.splitlines() if line.strip()]


def _path_inside_root(target: Path, root: Path) -> bool:
    try:
        target.resolve().relative_to(root.resolve())
    except ValueError:
        return False
    return True


def _relative_path(target: Path, root: Path = ROOT) -> str:
    return target.resolve().relative_to(root.resolve()).as_posix()


def analyze(root: Path = ROOT) -> dict[str, Any]:
    status_lines = _git_status(root)
    drift = sdu_sentinel.classify_status_lines(status_lines)
    action = DRIFT_POLICIES.get(drift, "block")
    return {
        "status": "PASS",
        "mode": "LOCAL_ONLY",
        "drift": drift,
        "recommended_action": action,
        "local_changes": len(status_lines),
        "no_external": True,
    }


def rollback_target(target: str, root: Path = ROOT, apply: bool = False) -> dict[str, Any]:
    target_path = (root / target).resolve()
    if not _path_inside_root(target_path, root):
        return {"status": "BLOCK", "action": "rollback", "target": target, "result": "outside_root"}
    rel = _relative_path(target_path, root)
    if rel.startswith(".env") or "/.env" in rel:
        return {"status": "BLOCK", "action": "rollback", "target": rel, "result": "secret_boundary"}

    tracked = _run(["git", "ls-files", "--error-unmatch", rel], root)
    if tracked.returncode != 0:
        return {"status": "BLOCK", "action": "rollback", "target": rel, "result": "untracked_target"}

    if not apply:
        return {"status": "PASS", "action": "rollback", "target": rel, "result": "dry_run"}

    result = _run(["git", "restore", "--source=HEAD", "--", rel], root)
    return {
        "status": "PASS" if result.returncode == 0 else "FAIL",
        "action": "rollback",
        "target": rel,
        "result": "success" if result.returncode == 0 else "failed",
        "stderr": result.stderr.strip(),
    }


def write_evidence_gap_readback(root: Path = ROOT, apply: bool = False) -> dict[str, Any]:
    path = root / "operativa" / "READBACK_AUTO_REMEDIATION_EVIDENCE_GAP.md"
    if not apply:
        return {"status": "PASS", "action": "regenerate", "target": _relative_path(path, root), "result": "dry_run"}
    text = "\n".join(
        [
            "# AUTO REMEDIATION EVIDENCE GAP",
            "",
            "## Estado",
            "EVIDENCE_GAP_REMEDIATED_LOCAL_ONLY",
            "",
            "## Frontera",
            "NO_EXTERNAL",
            "",
        ]
    )
    path.write_text(text, encoding="utf-8")
    return {"status": "PASS", "action": "regenerate", "target": _relative_path(path, root), "result": "success"}


def remediation_event(payload: dict[str, Any]) -> dict[str, Any]:
    timestamp = _utc_now()
    return {
        "timestamp_utc": timestamp,
        "event_id": _next_event_id("REMEDIATION"),
        "severity": "INFO" if payload.get("status") == "PASS" else "WARN",
        "category": "DRIFT",
        "surface": "local",
        "decision": "ALLOW" if payload.get("status") == "PASS" else "BLOCK",
        "evidence": [str(payload.get("target", "local"))],
        "notes": f"auto_remediation action={payload.get('action')}",
        "remediation": {
            "action": str(payload.get("action", "none")),
            "target": str(payload.get("target", "local")),
            "result": str(payload.get("result", "skipped")),
        },
    }


def log_remediation_event(payload: dict[str, Any]) -> None:
    sdu_sentinel.append_event(remediation_event(payload), sdu_sentinel.EVENTS_PATH)


def remediate(drift_type: str | None = None, target: str | None = None, root: Path = ROOT, apply: bool = False) -> dict[str, Any]:
    drift = drift_type or analyze(root)["drift"]
    if drift == "NO_DRIFT":
        payload = {"status": "PASS", "drift": drift, "action": "none", "target": "local", "result": "skipped"}
    elif drift == "SECRET_RISK_DRIFT":
        payload = {"status": "BLOCK", "drift": drift, "action": "block", "target": target or "secret_boundary", "result": "skipped"}
    elif drift == "BOUNDARY_POLICY_DRIFT":
        payload = rollback_target("operativa/SDU_RUNTIME_BOUNDARY_MATRIX.json", root, apply)
        payload["drift"] = drift
    elif drift in {"UNEXPECTED_RUNTIME_DRIFT", "VALIDATOR_FAILURE"}:
        if not target:
            payload = {"status": "BLOCK", "drift": drift, "action": "rollback", "target": "missing", "result": "target_required"}
        else:
            payload = rollback_target(target, root, apply)
            payload["drift"] = drift
    elif drift == "EVIDENCE_GAP_DRIFT":
        payload = write_evidence_gap_readback(root, apply)
        payload["drift"] = drift
    elif drift == "EXPECTED_INDEX_REFRESH":
        payload = {"status": "PASS", "drift": drift, "action": "regenerate", "target": "index", "result": "operator_review_required"}
    else:
        payload = {"status": "BLOCK", "drift": drift, "action": "block", "target": target or "local", "result": "unsupported_drift"}

    log_remediation_event(payload)
    return payload


def simulate(drift_type: str = "UNEXPECTED_RUNTIME_DRIFT") -> dict[str, Any]:
    action = DRIFT_POLICIES.get(drift_type, "block")
    payload = {
        "status": "PASS" if action != "block" else "BLOCK",
        "drift": drift_type,
        "action": action,
        "target": "simulation",
        "result": "logged",
        "no_external": True,
    }
    log_remediation_event(payload)
    return payload


def _print(payload: dict[str, Any], as_json: bool) -> None:
    if as_json:
        print(json.dumps(payload, ensure_ascii=False, indent=2))
    else:
        for key, value in payload.items():
            print(f"{key}: {value}")


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="SDU auto-remediation local engine.")
    parser.add_argument("--json", action="store_true")
    subparsers = parser.add_subparsers(dest="command", required=True)

    analyze_parser = subparsers.add_parser("analyze")
    analyze_parser.add_argument("--json", action="store_true")

    remediate_parser = subparsers.add_parser("remediate")
    remediate_parser.add_argument("--json", action="store_true")
    remediate_parser.add_argument("--drift-type")
    remediate_parser.add_argument("--target")
    remediate_parser.add_argument("--apply", action="store_true")

    rollback_parser = subparsers.add_parser("rollback")
    rollback_parser.add_argument("--json", action="store_true")
    rollback_parser.add_argument("--target", required=True)
    rollback_parser.add_argument("--apply", action="store_true")

    simulate_parser = subparsers.add_parser("simulate")
    simulate_parser.add_argument("--json", action="store_true")
    simulate_parser.add_argument("--drift-type", default="UNEXPECTED_RUNTIME_DRIFT")
    return parser


def main(argv: list[str] | None = None) -> int:
    args = build_parser().parse_args(argv)
    if args.command == "analyze":
        payload = analyze(ROOT)
    elif args.command == "remediate":
        payload = remediate(args.drift_type, args.target, ROOT, args.apply)
    elif args.command == "rollback":
        payload = rollback_target(args.target, ROOT, args.apply)
        log_remediation_event(payload)
    elif args.command == "simulate":
        payload = simulate(args.drift_type)
    else:
        raise AssertionError(args.command)

    _print(payload, args.json)
    return 1 if payload.get("status") in {"FAIL", "BLOCK"} else 0


if __name__ == "__main__":
    raise SystemExit(main())
