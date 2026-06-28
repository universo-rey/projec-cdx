from __future__ import annotations

import json
import shutil
from collections import deque
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

from .agent import smoke_report

ROOT = Path(__file__).parents[2]
CEO_ROOT = Path("C:/CEO")
WATCHDOG_ROOT = CEO_ROOT / "watchdog"
WATCHDOG_CHANGES = WATCHDOG_ROOT / "logs" / "changes.jsonl"
WATCHDOG_BUS = WATCHDOG_ROOT / "bus" / "sdu-event-bus.jsonl"
WATCHDOG_STATE = WATCHDOG_ROOT / "state" / "sdu-system-state.json"
WATCHDOG_BINDING = ROOT / ".cabina" / "execution-runtime" / "logs" / "watchdog-telemetry-binding.json"
SYSTEM_BOOTSTRAP = ROOT / ".cabina" / "execution-runtime" / "system-bootstrap.json"
NOC_ROOT = ROOT / "noc"
NOC_SYSTEM_MAP = NOC_ROOT / "SYSTEM_MAP.json"
NOC_STATE = NOC_ROOT / "noc-state.json"
NOC_LOCK = NOC_ROOT / "noc.lock.json"
SENTINEL_REPORT = WATCHDOG_ROOT / "operativa" / "sentinel" / "SENTINEL_REPORT.json"
DRIFT_LOG = WATCHDOG_ROOT / "operativa" / "sentinel" / "DRIFT_LOG.json"
INTELLIGENCE_ROOT = ROOT / ".cabina" / "execution-runtime" / "intelligence"
INTELLIGENCE_LATEST = INTELLIGENCE_ROOT / "latest.json"
INTELLIGENCE_FALLBACKS = [
    INTELLIGENCE_LATEST,
    INTELLIGENCE_ROOT / "NOC_G9_INTELLIGENCE_REPORT.json",
    ROOT / ".cabina" / "execution-runtime" / "NOC_G9_INTELLIGENCE_REPORT.json",
]

ORG_TOTAL_DECLARED_ROOT = ROOT / ".cabina" / "organizacion-total"
ORG_TOTAL_CANDIDATES = [
    ORG_TOTAL_DECLARED_ROOT,
    ROOT / "work" / "backups" / "sdu-org-total-before-integration-20260623_012542" / "organizacion-total",
    ROOT / "work" / "backups" / "sdu-org-total-before-integration-20260623_012553" / "organizacion-total",
]

RUNTIME_EVENTS = {
    "SDU_PLAN_CREATED",
    "SDU_AGENT_SELECTED",
    "SDU_SKILL_INVOKED",
    "SDU_TOOL_EXECUTED",
    "SDU_ACTION_EXECUTED",
    "SDU_VALIDATION_OK",
}


def _read_json(path: Path) -> dict[str, Any] | None:
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except Exception:
        return None


def _read_text(path: Path) -> str | None:
    try:
        return path.read_text(encoding="utf-8")
    except Exception:
        return None


def _tail_jsonl(path: Path, limit: int = 100) -> list[dict[str, Any]]:
    if not path.exists():
        return []

    lines: deque[str] = deque(maxlen=limit)
    try:
        with path.open("r", encoding="utf-8") as handle:
            for raw_line in handle:
                line = raw_line.strip()
                if line:
                    lines.append(line)
    except Exception:
        return []

    items: list[dict[str, Any]] = []
    for line in lines:
        try:
            value = json.loads(line)
        except json.JSONDecodeError:
            continue
        if isinstance(value, dict):
            items.append(value)
    return items


def _latest_existing_json(paths: list[Path]) -> dict[str, Any]:
    for path in paths:
        payload = _read_json(path)
        if payload is not None:
            return payload
    return {}


def _status_level(value: str | None) -> int:
    normalized = (value or "").strip().upper()
    if normalized in {"CRITICAL", "RED", "FAIL", "DEGRADED", "NOC_ATTENTION_REQUIRED", "YELLOW"}:
        return 2 if normalized in {"CRITICAL", "RED", "FAIL", "DEGRADED"} else 1
    return 0


def _compact_phrase(value: str | None, fallback: str = "Unknown") -> str:
    normalized = str(value or "").strip().replace("_", " ")
    parts = [part for part in normalized.split() if part]
    if not parts:
        return fallback
    return " ".join(part[:1].upper() + part[1:].lower() for part in parts[:3])


def _summary_prefix(status: str) -> str:
    return "OK" if status == "GREEN" else "WARN" if status == "WARN" else "ERR"


def _summary_repo_state(multirepo_status: Any, multirepo_decision: str) -> str:
    readiness = str(multirepo_status or "").strip().upper()
    decision = str(multirepo_decision or "").strip().upper()
    if decision in {"PASS", "OK", "GREEN"} or readiness in {"READY", "PASS", "GREEN"}:
        return "Ready"
    if decision in {"FAIL", "BLOCK", "BLOCKED", "RED"} or readiness in {"BLOCKED", "DEFERRED", "FAIL", "RED"}:
        return "Blocked"
    return "Deferred"


def _summary_drift_state(intelligence_state: dict[str, Any]) -> str:
    status = str(intelligence_state.get("status") or "").upper()
    if status in {"CRITICAL", "FAIL"}:
        return "Critical"
    if intelligence_state.get("alerts_detected"):
        return "Alert"
    if intelligence_state.get("anomalies_detected"):
        return "Anomaly"
    if intelligence_state.get("sync_findings"):
        return "Sync"
    if intelligence_state.get("domain_alignment"):
        return "Align"
    return "None"


def _summary_readback_state(noc_state: dict[str, Any]) -> dict[str, Any]:
    readback = noc_state.get("readback") or {}
    if not isinstance(readback, dict):
        readback = {}

    graph_access = str(readback.get("GRAPH_ACCESS") or noc_state.get("graph_access") or "").strip().upper()
    absence_means_absence = readback.get("absence_means_absence")
    if absence_means_absence is None:
        absence_means_absence = noc_state.get("absence_means_absence")

    readback_untrusted = bool(readback.get("READBACK_UNTRUSTED"))
    partial_details = bool(readback.get("READBACK_PARTIAL_DETAILS"))

    if readback_untrusted:
        status = "UNTRUSTED"
    elif graph_access in {"DEGRADED", "PARTIAL"} or partial_details:
        status = "PARTIAL"
    elif graph_access in {"BLOCKED", "CRITICAL", "FAIL"}:
        status = "DEGRADED"
    else:
        status = "TRUSTED"

    return {
        "status": status,
        "graph_access": graph_access or "UNKNOWN",
        "absence_means_absence": absence_means_absence if absence_means_absence is not None else None,
        "partial_details": partial_details,
        "untrusted": readback_untrusted,
    }


def build_noc_system_summary(
    sdu_state: dict[str, Any] | None = None,
    noc_state: dict[str, Any] | None = None,
    intelligence_state: dict[str, Any] | None = None,
) -> dict[str, Any]:
    sdu_state = sdu_state or _read_json(WATCHDOG_STATE) or {}
    noc_state = noc_state or _read_json(NOC_STATE) or {}
    intelligence_state = intelligence_state or _latest_existing_json(INTELLIGENCE_FALLBACKS)

    entrypoint = noc_state.get("entrypoint_observability") or {}
    governance = noc_state.get("governance") or {}
    multirepo = governance.get("multirepo") or {}
    run_info = noc_state.get("last_run") or {}
    readback_state = _summary_readback_state(noc_state)

    entrypoint_status = str(entrypoint.get("status") or "UNKNOWN").upper()
    entrypoint_cwd = entrypoint.get("current_cwd")
    coordinator_lane = run_info.get("mode") or "unknown"
    coordinator_state = "action" if str(run_info.get("mode") or "").upper() not in {"", "WATCHDOG_RUN"} else "idle"
    multirepo_status = multirepo.get("readiness") or noc_state.get("estado_general") or "UNKNOWN"
    multirepo_decision = ((multirepo.get("validation") or {}).get("decision")) or "UNKNOWN"

    intelligence_last = intelligence_state.get("generated_at") or intelligence_state.get("last_run_at")
    intelligence_changes = []
    for key in ("alerts_detected", "anomalies_detected", "sync_findings", "domain_alignment"):
        value = intelligence_state.get(key)
        if isinstance(value, list):
            intelligence_changes.append(f"{key}:{len(value)}")
        elif value not in (None, "", 0):
            intelligence_changes.append(f"{key}:{value}")

    sdu_health = (sdu_state.get("health") or {}).get("status") if isinstance(sdu_state.get("health"), dict) else None
    noc_health = (noc_state.get("health") or {}).get("status") if isinstance(noc_state.get("health"), dict) else None
    intelligence_status = str(intelligence_state.get("status") or "").upper()
    overall_rank = max(
        [
            _status_level(str(sdu_health or sdu_state.get("status"))),
            _status_level(str(noc_health or noc_state.get("status"))),
            2 if intelligence_status in {"CRITICAL", "FAIL"} else 1
            if intelligence_status in {"WARN", "YELLOW", "DEGRADED"}
            else 0,
            2
            if readback_state["status"] == "UNTRUSTED"
            else 1
            if readback_state["status"] in {"PARTIAL", "DEGRADED"}
            else 0,
        ]
    )
    overall_status = "CRITICAL" if overall_rank >= 2 else "WARN" if overall_rank == 1 else "GREEN"

    entrypoint_fragment = _compact_phrase(entrypoint_status)
    coordinator_fragment = _compact_phrase(coordinator_lane) if coordinator_state == "action" else "Idle"
    multirepo_fragment = _summary_repo_state(multirepo_status, multirepo_decision)
    intelligence_fragment = _summary_drift_state(intelligence_state)
    intelligence_line = (
        f"Intelligence latest {intelligence_last or 'unknown'}; changes: "
        f"{', '.join(intelligence_changes) if intelligence_changes else 'none'}."
    )
    if readback_state["status"] != "TRUSTED":
        intelligence_line = f"{intelligence_line} Readback {_compact_phrase(readback_state['status'])}."

    lines = [
        "SDU operational." if overall_status == "GREEN" else "SDU requires attention." if overall_status == "WARN" else "SDU critical.",
        f"Entrypoint {entrypoint_status.lower()} at {entrypoint_cwd or 'unknown cwd'}.",
        f"Coordinator {coordinator_state} on lane {coordinator_lane}.",
        f"Multirepo {str(multirepo_status).lower()} ({multirepo_decision}).",
        intelligence_line,
    ]

    headline = (
        f"{_summary_prefix(overall_status)}. "
        f"Entry: {entrypoint_fragment}. "
        f"Coord: {coordinator_fragment}. "
        f"Repo: {multirepo_fragment}. "
        f"Drift: {intelligence_fragment}."
    )
    if readback_state["status"] != "TRUSTED":
        headline = f"{headline} Readback: {_compact_phrase(readback_state['status'])}."

    return {
        "title": "SDU System Summary",
        "status": overall_status,
        "signal": overall_status,
        "headline": headline,
        "summary_lines": lines,
        "entrypoint": {
            "cwd": entrypoint_cwd,
            "status": entrypoint_status.lower(),
        },
        "coordinator": {
            "lane": coordinator_lane,
            "state": coordinator_state,
        },
        "multirepo": {
            "status": multirepo_status,
            "decision": multirepo_decision,
        },
        "intelligence": {
            "last_run": intelligence_last,
            "changes_detected": intelligence_changes,
        },
        "readback": readback_state,
    }


def _task_labels(tasks_data: dict[str, Any] | None) -> list[str]:
    if not tasks_data:
        return []
    tasks = tasks_data.get("tasks")
    if not isinstance(tasks, list):
        return []
    labels: list[str] = []
    for task in tasks:
        if isinstance(task, dict):
            label = task.get("label")
            if isinstance(label, str) and label:
                labels.append(label)
    return labels


def _task_entrypoints(tasks_data: dict[str, Any] | None) -> dict[str, Any]:
    if not tasks_data:
        return {}

    entrypoints: dict[str, Any] = {}
    tasks = tasks_data.get("tasks")
    if not isinstance(tasks, list):
        return entrypoints

    for task in tasks:
        if not isinstance(task, dict):
            continue
        label = task.get("label")
        args = task.get("args")
        if not isinstance(label, str) or not label:
            continue
        entrypoints[label] = {
            "type": task.get("type"),
            "command": task.get("command"),
            "args": args if isinstance(args, list) else [],
            "dependsOn": task.get("dependsOn"),
            "dependsOrder": task.get("dependsOrder"),
        }
    return entrypoints


def discover_org_total_runner() -> dict[str, Any]:
    probe_results: list[dict[str, Any]] = []
    selected_root: Path | None = None
    selected_policy: dict[str, Any] | None = None
    selected_tasks: dict[str, Any] | None = None

    for candidate in ORG_TOTAL_CANDIDATES:
        exists = candidate.exists()
        policy = _read_json(candidate / "config" / "sdu-org-policy.json") if exists else None
        tasks = _read_json(candidate / ".vscode" / "tasks.json") if exists else None
        probe_results.append(
            {
                "path": str(candidate),
                "exists": exists,
                "policy_readable": policy is not None,
                "tasks_readable": tasks is not None,
            }
        )
        if selected_root is None and exists and policy is not None and tasks is not None:
            selected_root = candidate
            selected_policy = policy
            selected_tasks = tasks

    declared_policy = _read_json(ORG_TOTAL_DECLARED_ROOT / "config" / "sdu-org-policy.json")
    declared_tasks = _read_json(ORG_TOTAL_DECLARED_ROOT / ".vscode" / "tasks.json")

    if selected_root is None:
        selected_policy = declared_policy
        selected_tasks = declared_tasks

    scripts_dir = selected_root / "scripts" if selected_root else None
    script_names = []
    if scripts_dir and scripts_dir.exists():
        script_names = sorted(
            [path.name for path in scripts_dir.iterdir() if path.is_file() and path.suffix.lower() == ".ps1"]
        )

    docs_dir = selected_root / "docs" if selected_root else None
    doc_names = []
    if docs_dir and docs_dir.exists():
        doc_names = sorted(
            [path.name for path in docs_dir.iterdir() if path.is_file() and path.suffix.lower() in {".md", ".json", ".yaml", ".yml"}]
        )

    knowledge = _read_text(selected_root / "RUNNER_KNOWLEDGE.md") if selected_root else None

    runner_root_declared = None
    if selected_policy:
        runner_root_declared = selected_policy.get("runner_root")

    return {
        "runner_id": selected_policy.get("runner_id") if selected_policy else None,
        "mode": selected_policy.get("mode") if selected_policy else None,
        "dry_run_default": selected_policy.get("dry_run_default") if selected_policy else None,
        "no_delete": selected_policy.get("no_delete") if selected_policy else None,
        "no_overwrite": selected_policy.get("no_overwrite") if selected_policy else None,
        "no_live": selected_policy.get("no_live") if selected_policy else None,
        "no_push": selected_policy.get("no_push") if selected_policy else None,
        "no_pr": selected_policy.get("no_pr") if selected_policy else None,
        "apply_requires_explicit_gate": selected_policy.get("apply_requires_explicit_gate") if selected_policy else None,
        "evidence_mode": selected_policy.get("evidence_mode") if selected_policy else None,
        "declared_runner_root": runner_root_declared,
        "selected_root": str(selected_root) if selected_root else None,
        "workspace_materialized": ORG_TOTAL_DECLARED_ROOT.exists(),
        "candidate_roots": probe_results,
        "task_labels": _task_labels(selected_tasks),
        "task_entrypoints": _task_entrypoints(selected_tasks),
        "script_names": script_names,
        "doc_names": doc_names,
        "knowledge_present": knowledge is not None,
        "knowledge_excerpt": knowledge.splitlines()[:8] if knowledge else [],
        "source": "declared_root" if selected_root == ORG_TOTAL_DECLARED_ROOT else "backup_runner" if selected_root else "declared_root_missing",
    }


def runtime_status_report() -> dict[str, Any]:
    smoke = smoke_report()
    org = discover_org_total_runner()
    bootstrap = _read_json(SYSTEM_BOOTSTRAP) or {}
    binding = _read_json(WATCHDOG_BINDING) or {}
    state = _read_json(WATCHDOG_STATE) or {}
    noc_map = _read_json(NOC_SYSTEM_MAP) or {}
    noc_summary = build_noc_system_summary(state, _read_json(NOC_STATE) or {}, _latest_existing_json(INTELLIGENCE_FALLBACKS))

    code_insiders = shutil.which("code-insiders") is not None
    pwsh = shutil.which("pwsh") is not None or shutil.which("powershell") is not None
    git = shutil.which("git") is not None
    python = shutil.which("python") is not None

    bootstrap_subset = {
        "status": bootstrap.get("status"),
        "final_state": bootstrap.get("final_state"),
        "runner_active": bootstrap.get("runner_active"),
        "watchdog_active": bootstrap.get("watchdog_active"),
        "event_bus_active": bootstrap.get("event_bus_active"),
        "agents_running": bootstrap.get("agents_running"),
    }

    binding_subset = {
        "watchdog_connected": binding.get("watchdog_connected"),
        "telemetry_connected": binding.get("telemetry_connected"),
        "event_bus_connected": binding.get("event_bus_connected"),
        "event_bus_state": binding.get("event_bus_state"),
        "outside_runtime_write_performed": binding.get("outside_runtime_write_performed"),
    }

    return {
        "status": "READY" if org.get("selected_root") else "DEGRADED",
        "mode": "READ_ONLY_WRAPPER",
        "wrapper": "runtime.status",
        "created_at": datetime.now(timezone.utc).isoformat(),
        "live_write_touched": False,
        "org_total_runner": org,
        "environment": {
            "code_insiders": code_insiders,
            "pwsh": pwsh,
            "python": python,
            "git": git,
            "open_console": (Path("C:/Windows/System32/OpenConsole.exe").exists()),
        },
        "cloud_smoke": smoke,
        "bootstrap": bootstrap_subset,
        "watchdog_binding": binding_subset,
        "watchdog_state": {
            "matrix_loaded": state.get("governance", {}).get("matrix_loaded"),
            "codex_execution_contract": state.get("governance", {}).get("codex_execution_contract"),
            "multirepo_readiness": state.get("governance", {}).get("multirepo", {}).get("readiness"),
            "taxonomy_status": state.get("governance", {}).get("taxonomy", {}).get("status"),
        },
        "noc_control_plane": {
            "system_map_present": NOC_SYSTEM_MAP.exists(),
            "state_present": NOC_STATE.exists(),
            "lock_present": NOC_LOCK.exists(),
            "system_map_path": str(NOC_SYSTEM_MAP),
            "state_path": str(NOC_STATE),
            "lock_path": str(NOC_LOCK),
            "control_plane": noc_map.get("control_plane"),
            "routes": noc_map.get("routes"),
            "actions_count": len(noc_map.get("actions") or []),
            "recipes_count": len(noc_map.get("recipes") or []),
        },
        "noc_system_summary": noc_summary,
        "next_safe_task": "SDU: Full DryRun" if org.get("selected_root") else "Resolve ORG_TOTAL_RUNNER root",
        "systems_not_touched": [
            "watchdog run-primary",
            "watchdog telemetry writer",
            "watchdog live telemetry loop",
            "organizacion-total live apply",
        ],
    }


def runtime_sentinel_report() -> dict[str, Any]:
    org = discover_org_total_runner()
    bootstrap = _read_json(SYSTEM_BOOTSTRAP) or {}
    binding = _read_json(WATCHDOG_BINDING) or {}
    state = _read_json(WATCHDOG_STATE) or {}
    noc_map = _read_json(NOC_SYSTEM_MAP) or {}
    noc_summary = build_noc_system_summary(state, _read_json(NOC_STATE) or {}, _latest_existing_json(INTELLIGENCE_FALLBACKS))

    changes = _tail_jsonl(WATCHDOG_CHANGES, limit=120)
    bus_events = _tail_jsonl(WATCHDOG_BUS, limit=80)

    change_actions = [
        item.get("action")
        for item in changes
        if isinstance(item.get("action"), str) and item.get("action")
    ]
    bus_event_names = [
        item.get("type") or item.get("event_type")
        for item in bus_events
        if isinstance(item.get("type") or item.get("event_type"), str)
    ]

    recent_relevant = []
    for item in reversed(changes):
        name = item.get("action") or item.get("type")
        if isinstance(name, str) and (
            name.startswith("SDU_")
            or name.startswith("WATCHDOG_")
            or name in {"SDU_FULL_STACK_ACTIVATED", "SDU_G50_MODEL_ENFORCED"}
        ):
            recent_relevant.append(item)
        if len(recent_relevant) >= 10:
            break

    event_presence = {
        event: (event in change_actions or event in bus_event_names)
        for event in sorted(RUNTIME_EVENTS)
    }

    sentinel_artifacts = [
        {"path": str(SENTINEL_REPORT), "exists": SENTINEL_REPORT.exists()},
        {"path": str(DRIFT_LOG), "exists": DRIFT_LOG.exists()},
    ]

    return {
        "status": "OK"
        if bootstrap.get("event_bus_active") and binding.get("event_bus_connected")
        else "DEGRADED",
        "mode": "READ_ONLY_WRAPPER",
        "wrapper": "runtime.sentinel",
        "created_at": datetime.now(timezone.utc).isoformat(),
        "live_write_touched": False,
        "org_total_runner": org,
        "sentinel_artifacts": sentinel_artifacts,
        "watchdog": {
            "watchdog_active": bootstrap.get("watchdog_active"),
            "watchdog_connected": binding.get("watchdog_connected"),
            "telemetry_connected": binding.get("telemetry_connected"),
            "event_bus_connected": binding.get("event_bus_connected"),
        },
        "event_bus_state": binding.get("event_bus_state"),
        "watchdog_state": {
            "matrix_loaded": state.get("governance", {}).get("matrix_loaded"),
            "codex_execution_contract": state.get("governance", {}).get("codex_execution_contract"),
            "multirepo_readiness": state.get("governance", {}).get("multirepo", {}).get("readiness"),
            "taxonomy_status": state.get("governance", {}).get("taxonomy", {}).get("status"),
        },
        "noc_control_plane": {
            "system_map_present": NOC_SYSTEM_MAP.exists(),
            "state_present": NOC_STATE.exists(),
            "lock_present": NOC_LOCK.exists(),
            "control_plane": noc_map.get("control_plane"),
            "routes": noc_map.get("routes"),
            "actions_count": len(noc_map.get("actions") or []),
            "recipes_count": len(noc_map.get("recipes") or []),
        },
        "noc_system_summary": noc_summary,
        "bootstrap": {
            "status": bootstrap.get("status"),
            "final_state": bootstrap.get("final_state"),
            "runner_active": bootstrap.get("runner_active"),
            "watchdog_active": bootstrap.get("watchdog_active"),
            "event_bus_active": bootstrap.get("event_bus_active"),
            "agents_running": bootstrap.get("agents_running"),
        },
        "recent_relevant_changes": recent_relevant,
        "event_presence": event_presence,
        "systems_not_touched": [
            "watchdog run-primary",
            "watchdog telemetry writer",
            "watchdog live telemetry loop",
            "organizacion-total live apply",
        ],
        "sentinel_source": "synthesized_from_watchdog_state",
    }
