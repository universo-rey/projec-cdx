from __future__ import annotations

import argparse
import json
import subprocess
import sys
from concurrent.futures import ThreadPoolExecutor, as_completed
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
CONFIG_PATH = ROOT / ".sdu" / "operational-mode.json"
NOC_LIVE_PATH = ROOT / "noc" / "operacion-en-vivo.json"
NOC_EVENTS_PATH = ROOT / "noc" / "events" / "log.jsonl"
INTELLIGENCE_STATE_PATH = ROOT / "noc" / "inteligencia-operativa.json"
BITACORA_PATH = Path("C:/CEO/watchdog/logs/bitacora-operativa.jsonl")

THREAD_SPECS = (
    ("repos", "repo-agent"),
    ("governance", "governance-agent"),
    ("ci", "ci-agent"),
    ("integrations", "integration-agent"),
)
DESTRUCTIVE_TERMS = (
    "delete",
    "eliminar",
    "remove",
    "borrar",
    "drop",
    "destroy",
    "destructiva",
    "reset",
    "force",
    "--force",
    "push -f",
)
STRUCTURAL_TERMS = (
    "estructura",
    "structural",
    "canonicalization",
    "canonizacion",
    "migration",
    "migracion",
    "schema",
)
MAIN_IMPACT_TERMS = (
    "main",
    "origin/main",
    "merge",
    "tag",
    "release",
    "push",
)
ALERT_TERMS = ("warning", "missing", "faltante", "fail", "fallo")


def utc_now() -> str:
    return datetime.now(timezone.utc).isoformat().replace("+00:00", "Z")


def run_git(args: list[str], timeout: int = 20) -> dict[str, Any]:
    completed = subprocess.run(
        ["git", *args],
        cwd=ROOT,
        text=True,
        capture_output=True,
        timeout=timeout,
        check=False,
    )
    return {
        "ok": completed.returncode == 0,
        "returncode": completed.returncode,
        "stdout": completed.stdout.strip(),
        "stderr": completed.stderr.strip(),
    }


def append_jsonl(path: Path, payload: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("a", encoding="utf-8") as handle:
        handle.write(json.dumps(payload, ensure_ascii=False, sort_keys=True) + "\n")


def write_json(path: Path, payload: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def read_json(path: Path) -> dict[str, Any]:
    if not path.exists():
        return {}
    return json.loads(path.read_text(encoding="utf-8-sig"))


def load_config() -> dict[str, Any]:
    return read_json(CONFIG_PATH)


def load_intelligence_state() -> dict[str, Any]:
    return read_json(INTELLIGENCE_STATE_PATH)


def refresh_intelligence_state(origen: str) -> dict[str, Any]:
    if str(ROOT) not in sys.path:
        sys.path.insert(0, str(ROOT))
    try:
        from tools import sdu_intelligent_operation_layer as intelligence
    except ImportError:
        return {}
    if not intelligence.is_active():
        return {}
    try:
        return intelligence.refresh_intelligence_state(origin=origen, record_events=True)
    except Exception as exc:  # pragma: no cover - trace guard keeps operations visible
        return {
            "mode": "ADAPTIVE_INTELLIGENCE_ERROR",
            "alertas_activas": [
                {
                    "fuente": "intelligence",
                    "gravedad": "WARNING",
                    "problema": f"No se pudo refrescar inteligencia operativa: {exc}",
                }
            ],
            "sugerencias_automaticas": [
                {
                    "problema": "Fallo al refrescar inteligencia operativa.",
                    "gravedad": "WARNING",
                    "accion_sugerida": "Revisar helper tools/sdu_intelligent_operation_layer.py.",
                    "requiere_confirmacion": False,
                }
            ],
            "prioridad": [],
        }


def classify_risk(intent: str, tipo_operacion: str = "") -> dict[str, Any]:
    text = f"{intent} {tipo_operacion}".lower()
    flags: list[str] = []
    if any(term in text for term in DESTRUCTIVE_TERMS):
        flags.append("destructive_operation")
    if any(term in text for term in STRUCTURAL_TERMS):
        flags.append("structural_change")
    if any(term in text for term in MAIN_IMPACT_TERMS):
        flags.append("main_impact")

    state = "REQUIRES_CONFIRMATION" if flags else "AUTO_TRACE_ALLOWED"
    return {"state": state, "flags": flags}


def repo_agent(intent: str, tipo_operacion: str) -> dict[str, Any]:
    del intent, tipo_operacion
    status = run_git(["status", "--short", "--branch"])
    branch = run_git(["rev-parse", "--abbrev-ref", "HEAD"])
    head = run_git(["rev-parse", "HEAD"])
    origin_main = run_git(["rev-parse", "origin/main"])
    diff = run_git(["diff", "--quiet", "origin/main", "HEAD"])
    return {
        "area": "repos",
        "agent": "repo-agent",
        "status": "PASS" if status["ok"] and branch["ok"] and head["ok"] else "WARN",
        "observations": {
            "branch": branch["stdout"],
            "head": head["stdout"],
            "origin_main": origin_main["stdout"] if origin_main["ok"] else None,
            "tree_matches_origin_main": diff["returncode"] == 0,
            "status": status["stdout"],
        },
    }


def governance_agent(intent: str, tipo_operacion: str) -> dict[str, Any]:
    risk = classify_risk(intent, tipo_operacion)
    root_ok = str(ROOT).lower().startswith("c:\\ceo")
    status = "PASS"
    if not root_ok:
        status = "CRITICAL"
    elif risk["state"] == "REQUIRES_CONFIRMATION":
        status = "REQUIRES_CONFIRMATION"
    return {
        "area": "governance",
        "agent": "governance-agent",
        "status": status,
        "observations": {
            "root": str(ROOT),
            "root_under_ceo": root_ok,
            "risk": risk,
            "silent_mode": "prohibited",
        },
    }


def ci_agent(intent: str, tipo_operacion: str) -> dict[str, Any]:
    del intent, tipo_operacion
    workflows_root = ROOT / ".github" / "workflows"
    workflows = sorted(path.name for path in workflows_root.glob("*") if path.is_file())
    return {
        "area": "ci",
        "agent": "ci-agent",
        "status": "PASS" if workflows else "WARN",
        "observations": {
            "workflows_root": str(workflows_root),
            "workflow_count": len(workflows),
            "workflows": workflows,
        },
    }


def integration_agent(intent: str, tipo_operacion: str) -> dict[str, Any]:
    del intent, tipo_operacion
    remote = run_git(["remote", "get-url", "origin"])
    origin_main = run_git(["rev-parse", "--verify", "origin/main"])
    status = "PASS" if remote["ok"] and origin_main["ok"] else "WARN"
    return {
        "area": "integrations",
        "agent": "integration-agent",
        "status": status,
        "observations": {
            "origin": remote["stdout"] if remote["ok"] else None,
            "origin_main_visible": origin_main["ok"],
            "origin_main": origin_main["stdout"] if origin_main["ok"] else None,
        },
    }


def run_threads(intent: str, tipo_operacion: str) -> list[dict[str, Any]]:
    agents = {
        "repos": repo_agent,
        "governance": governance_agent,
        "ci": ci_agent,
        "integrations": integration_agent,
    }
    results: list[dict[str, Any]] = []
    with ThreadPoolExecutor(max_workers=len(THREAD_SPECS)) as executor:
        futures = {
            executor.submit(agents[area], intent, tipo_operacion): area
            for area, _agent in THREAD_SPECS
        }
        for future in as_completed(futures):
            area = futures[future]
            try:
                results.append(future.result())
            except Exception as exc:  # pragma: no cover - defensive trace guard
                results.append(
                    {
                        "area": area,
                        "agent": dict(THREAD_SPECS)[area],
                        "status": "CRITICAL",
                        "observations": {"error": str(exc)},
                    }
                )
    return sorted(results, key=lambda item: [area for area, _ in THREAD_SPECS].index(item["area"]))


def build_live_panel(
    *,
    timestamp: str,
    intent: str,
    tipo_operacion: str,
    resultado: str,
    impacto: str,
    origen: str,
    threads: list[dict[str, Any]],
    risk: dict[str, Any],
    intelligence_state: dict[str, Any] | None = None,
) -> dict[str, Any]:
    config = load_config()
    intelligence = (
        intelligence_state if intelligence_state is not None else load_intelligence_state()
    )
    statuses = {item["area"]: item["status"] for item in threads}
    alerts = [
        {"area": item["area"], "status": item["status"]}
        for item in threads
        if item["status"] not in {"PASS"}
    ]
    if risk["state"] == "REQUIRES_CONFIRMATION":
        alerts.append({"area": "governance", "status": "REQUIRES_CONFIRMATION"})
    alert_text = f"{resultado} {impacto}".lower()
    if any(term in alert_text for term in ALERT_TERMS):
        alerts.append({"area": "postcheck", "status": "OBSERVED", "detail": impacto})
    active_alerts = intelligence.get("alertas_activas", []) if intelligence else []
    suggestions = intelligence.get("sugerencias_automaticas", []) if intelligence else []
    priority = intelligence.get("prioridad", []) if intelligence else []
    for event in active_alerts:
        alerts.append(
            {
                "area": event.get("fuente", "intelligence"),
                "status": event.get("gravedad", "OBSERVED"),
                "detail": event.get("problema"),
            }
        )

    return {
        "schema_version": 1,
        "panel": config.get("noc", {}).get("panel_title", "Operación en Vivo"),
        "generated_at": timestamp,
        "refresh": config.get("noc", {}).get("refresh", "continuous"),
        "operational_mode": config.get("operational_mode", "active"),
        "trace_mode": config.get("trace_mode", "automatic"),
        "swarm_mode": config.get("swarm_mode", "always_on"),
        "silent_mode": config.get("silent_mode", "prohibited"),
        "ultima_orden": {
            "timestamp": timestamp,
            "intent": intent,
            "tipo_operacion": tipo_operacion,
            "resultado": resultado,
            "impacto": impacto,
            "origen": origen,
        },
        "estado_sistema": {
            "root": str(ROOT),
            "trace": "ACTIVE",
            "swarm": "ACTIVE",
            "risk_state": risk["state"],
            "thread_status": statuses,
        },
        "threads_activos": threads,
        "alertas": alerts,
        "alertas_activas": active_alerts,
        "sugerencias_automaticas": suggestions,
        "prioridad": priority,
        "inteligencia": {
            "mode": intelligence.get("mode") if intelligence else "INACTIVE",
            "generated_at": intelligence.get("generated_at") if intelligence else None,
            "summary": intelligence.get("summary", {}) if intelligence else {},
            "auto_apply": intelligence.get("auto_apply", False) if intelligence else False,
        },
    }


def record_operation(
    *,
    intent: str,
    tipo_operacion: str,
    resultado: str,
    impacto: str,
    origen: str,
    threads: list[dict[str, Any]],
    risk: dict[str, Any],
) -> dict[str, Any]:
    timestamp = utc_now()
    intelligence_state = refresh_intelligence_state(origen)
    thread_summary = [
        {"area": item["area"], "agent": item["agent"], "status": item["status"]} for item in threads
    ]
    entry = {
        "timestamp": timestamp,
        "intent": intent,
        "tipo_operacion": tipo_operacion,
        "threads_ejecutados": thread_summary,
        "resultado": resultado,
        "impacto": impacto,
        "origen": origen,
    }
    panel = build_live_panel(
        timestamp=timestamp,
        intent=intent,
        tipo_operacion=tipo_operacion,
        resultado=resultado,
        impacto=impacto,
        origen=origen,
        threads=threads,
        risk=risk,
        intelligence_state=intelligence_state,
    )
    append_jsonl(BITACORA_PATH, entry)
    append_jsonl(
        NOC_EVENTS_PATH,
        {
            "timestamp": timestamp,
            "type": "SDU_OPERATIONAL_MODE",
            "source": "sdu-operational-mode",
            "payload": entry,
        },
    )
    write_json(NOC_LIVE_PATH, panel)
    return {"entry": entry, "panel": panel}


def activate(args: argparse.Namespace) -> int:
    tipo_operacion = "operational_mode_activation"
    threads = run_threads(args.intent, tipo_operacion)
    risk = classify_risk(args.intent, tipo_operacion)
    result = record_operation(
        intent=args.intent,
        tipo_operacion=tipo_operacion,
        resultado="SDU_OPERATIONAL_MODE_ACTIVE",
        impacto="trace_auto_noc_live_swarm_always_on",
        origen=args.origin,
        threads=threads,
        risk=risk,
    )
    print(json.dumps(result["entry"], ensure_ascii=False, indent=2))
    return 0


def trace(args: argparse.Namespace) -> int:
    threads = run_threads(args.intent, args.tipo_operacion)
    risk = classify_risk(args.intent, args.tipo_operacion)
    resultado = args.resultado
    impacto = args.impacto
    if risk["state"] == "REQUIRES_CONFIRMATION" and not args.confirmed:
        resultado = "REQUIRES_CONFIRMATION"
        impacto = "risk_control_blocked_unconfirmed_operation"
    result = record_operation(
        intent=args.intent,
        tipo_operacion=args.tipo_operacion,
        resultado=resultado,
        impacto=impacto,
        origen=args.origin,
        threads=threads,
        risk=risk,
    )
    print(json.dumps(result["entry"], ensure_ascii=False, indent=2))
    return 0


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="SDU operational mode trace helper")
    subparsers = parser.add_subparsers(dest="command", required=True)

    activate_parser = subparsers.add_parser("activate")
    activate_parser.add_argument("--intent", default="operational_mode_activation")
    activate_parser.add_argument("--origin", default="codex-chat")
    activate_parser.set_defaults(func=activate)

    trace_parser = subparsers.add_parser("trace")
    trace_parser.add_argument("--intent", required=True)
    trace_parser.add_argument("--tipo-operacion", required=True)
    trace_parser.add_argument("--resultado", default="RECORDED")
    trace_parser.add_argument("--impacto", default="trace_recorded")
    trace_parser.add_argument("--origin", default="codex-chat")
    trace_parser.add_argument("--confirmed", action="store_true")
    trace_parser.set_defaults(func=trace)
    return parser


def main(argv: list[str] | None = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)
    return args.func(args)


if __name__ == "__main__":
    raise SystemExit(main())
