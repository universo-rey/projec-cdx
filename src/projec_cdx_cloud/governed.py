from __future__ import annotations

import json
import os
import subprocess
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[2]


@dataclass(frozen=True)
class GovernedAgent:
    name: str
    role: str
    decision_rule: str


GOVERNED_AGENTS: tuple[GovernedAgent, ...] = (
    GovernedAgent(
        name="thot-tecnico",
        role="check tecnico",
        decision_rule="validar estructura, comandos y archivos criticos sin ejecutar writes externos",
    ),
    GovernedAgent(
        name="maat-cumplimiento",
        role="cumplimiento",
        decision_rule="confirmar evidencia, gates y metadata antes de habilitar avance",
    ),
    GovernedAgent(
        name="horus-riesgo",
        role="riesgo",
        decision_rule="clasificar riesgo tecnico, operativo y de gobierno",
    ),
    GovernedAgent(
        name="anubis-gate",
        role="frontera",
        decision_rule="bloquear live, secretos, workflow dispatch no gobernado y writes externos",
    ),
    GovernedAgent(
        name="seshat-normativa",
        role="evidencia",
        decision_rule="consolidar outputs JSON, readbacks y trazabilidad del run",
    ),
    GovernedAgent(
        name="EATOMIC",
        role="operador de resultado",
        decision_rule="ejecutar un eslabon, verificar resultado, registrar evidencia y avanzar solo si corresponde",
    ),
)


def _run(command: list[str], root: Path = ROOT) -> subprocess.CompletedProcess[str]:
    return subprocess.run(command, cwd=root, text=True, capture_output=True)


def _git(*args: str) -> str:
    result = _run(["git", *args])
    if result.returncode != 0:
        return ""
    return result.stdout.strip()


def _load_json(path: Path) -> Any:
    if not path.exists():
        return None
    return json.loads(path.read_text(encoding="utf-8"))


def _agents_sdk_state() -> dict[str, Any]:
    try:
        import agents  # type: ignore[import-not-found]

        return {
            "estado": "ACTIVE",
            "package": "openai-agents",
            "version": getattr(agents, "__version__", "unknown"),
            "live_api_required_for_runner": True,
        }
    except Exception:
        return {
            "estado": "PARTIAL",
            "package": "openai-agents",
            "version": "missing",
            "live_api_required_for_runner": True,
        }


def _workflow_inventory() -> list[dict[str, Any]]:
    workflow_root = ROOT / ".github" / "workflows"
    rows: list[dict[str, Any]] = []
    if not workflow_root.exists():
        return rows
    for path in sorted(workflow_root.glob("*.yml")):
        content = path.read_text(encoding="utf-8")
        rows.append(
            {
                "path": path.relative_to(ROOT).as_posix(),
                "pull_request": "pull_request:" in content,
                "push": "push:" in content,
                "workflow_dispatch": "workflow_dispatch:" in content,
                "permissions_read_only": "contents: read" in content
                and "contents: write" not in content,
            }
        )
    return rows


def _snapshot_gate() -> dict[str, Any]:
    index = _load_json(ROOT / "operativa" / "snapshots" / "SNAPSHOT_INDEX.json")
    snapshots = index.get("snapshots", []) if isinstance(index, dict) else []
    latest = snapshots[-1] if snapshots else None
    return {
        "status": "PASS" if latest else "FAIL",
        "snapshot_index": "ACTIVE" if isinstance(index, dict) else "MISSING",
        "latest_snapshot": latest,
    }


def _runtime_status() -> dict[str, Any]:
    result = _run([sys.executable, "main.py", "runtime", "status", "--json"])
    if result.returncode != 0:
        return {"status": "FAIL", "stderr": result.stderr.strip()}
    try:
        return json.loads(result.stdout)
    except json.JSONDecodeError:
        return {"status": "FAIL", "stdout": result.stdout.strip()}


def _agent_decisions(
    runtime: dict[str, Any], snapshot_gate: dict[str, Any]
) -> list[dict[str, Any]]:
    workspace_clean = bool(runtime.get("workspace", {}).get("clean"))
    snapshot_ok = snapshot_gate.get("status") == "PASS"
    decisions: list[dict[str, Any]] = []
    for agent in GOVERNED_AGENTS:
        status = "PASS"
        decision = "READY"
        if agent.name == "anubis-gate" and not snapshot_ok:
            status = "FAIL"
            decision = "BLOCKED_NO_SNAPSHOT"
        elif agent.name in {"thot-tecnico", "maat-cumplimiento"} and not workspace_clean:
            status = "WARN"
            decision = "REVIEW_WORKSPACE_DRIFT"
        decisions.append(
            {
                "agent": agent.name,
                "role": agent.role,
                "status": status,
                "decision": decision,
                "rule": agent.decision_rule,
            }
        )
    return decisions


def build_governed_cloud_report(event_name: str | None = None) -> dict[str, Any]:
    event = event_name or os.environ.get("GITHUB_EVENT_NAME") or "local"
    branch = _git("branch", "--show-current") or os.environ.get("GITHUB_REF_NAME") or "unknown"
    commit = _git("rev-parse", "HEAD") or os.environ.get("GITHUB_SHA") or "unknown"
    runtime = _runtime_status()
    snapshot_gate = _snapshot_gate()
    agents_sdk = _agents_sdk_state()
    agent_decisions = _agent_decisions(runtime, snapshot_gate)
    failed_agents = [item for item in agent_decisions if item["status"] == "FAIL"]
    warned_agents = [item for item in agent_decisions if item["status"] == "WARN"]

    return {
        "schema_version": "1.0",
        "status": "PASS" if not failed_agents else "FAIL",
        "event": event,
        "repo": "universo-rey/projec-cdx",
        "branch": branch,
        "commit": commit,
        "workflow_inventory": _workflow_inventory(),
        "runtime": {
            "status": runtime.get("status"),
            "version": runtime.get("version"),
            "drift_detected": runtime.get("drift_detected"),
            "workspace_clean": runtime.get("workspace", {}).get("clean"),
        },
        "snapshot_gate": snapshot_gate,
        "agent_sdk": agents_sdk,
        "agents": agent_decisions,
        "outputs": {
            "json": True,
            "pr_comment": "DISABLED_BY_READ_ONLY_FRONTIER",
            "artifact": "codex-governed-report",
        },
        "frontera": {
            "live": False,
            "external_writes": False,
            "secrets": False,
            "workflow_permissions": "contents:read",
        },
        "riesgo_residual": "Medio" if warned_agents else "Bajo",
        "observaciones": [
            "Codex Cloud runner ejecuta analisis y evidencia, no decisiones finales.",
            "Agents SDK detectado solo como capacidad; no se invoca OPENAI_API_KEY en este flujo.",
            "Comentarios automaticos en PR quedan deshabilitados hasta gate de write explicito.",
        ],
    }


def write_governed_cloud_report(output: Path, event_name: str | None = None) -> dict[str, Any]:
    payload = build_governed_cloud_report(event_name=event_name)
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(json.dumps(payload, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    payload["path"] = str(output)
    return payload
