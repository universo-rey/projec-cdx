from __future__ import annotations

import argparse
import json
import subprocess
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
CONFIG_PATH = ROOT / ".sdu" / "intelligent-operation-layer.json"
STATE_PATH = ROOT / "noc" / "inteligencia-operativa.json"
BITACORA_PATH = Path("C:/CEO/watchdog/logs/bitacora-operativa.jsonl")
NOC_EVENTS_PATH = ROOT / "noc" / "events" / "log.jsonl"

SEVERITY_WEIGHT = {"CRITICAL": 300, "WARNING": 200, "INFO": 100}
PRIORITY_LABELS = {"CRITICAL": "P1", "WARNING": "P2", "INFO": "P3"}


def utc_now() -> str:
    return datetime.now(timezone.utc).isoformat().replace("+00:00", "Z")


def run_command(args: list[str], timeout: int = 30) -> dict[str, Any]:
    try:
        completed = subprocess.run(
            args,
            cwd=ROOT,
            text=True,
            capture_output=True,
            timeout=timeout,
            check=False,
        )
    except (FileNotFoundError, subprocess.TimeoutExpired) as exc:
        return {"ok": False, "returncode": -1, "stdout": "", "stderr": str(exc)}
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


def read_jsonl_tail(path: Path, limit: int = 40) -> list[dict[str, Any]]:
    if not path.exists():
        return []
    lines = path.read_text(encoding="utf-8", errors="replace").splitlines()[-limit:]
    items: list[dict[str, Any]] = []
    for line in lines:
        if not line.strip():
            continue
        try:
            items.append(json.loads(line))
        except json.JSONDecodeError:
            continue
    return items


def is_active() -> bool:
    config = read_json(CONFIG_PATH)
    return config.get("mode") == "ADAPTIVE_INTELLIGENCE_ACTIVE"


def make_event(
    *,
    event_id: str,
    fuente: str,
    problema: str,
    gravedad: str,
    accion_sugerida: str,
    impacto: int,
    urgencia: int,
    recurrencia: int = 1,
    requiere_confirmacion: bool = False,
    ejecucion: str = "no_aplicada",
) -> dict[str, Any]:
    score = SEVERITY_WEIGHT[gravedad] + (impacto * 10) + (urgencia * 5) + (recurrencia * 3)
    suggestion = {
        "problema": problema,
        "gravedad": gravedad,
        "accion_sugerida": accion_sugerida,
        "requiere_confirmacion": requiere_confirmacion,
    }
    return {
        "id": event_id,
        "fuente": fuente,
        "problema": problema,
        "gravedad": gravedad,
        "impacto": impacto,
        "urgencia": urgencia,
        "recurrencia": recurrencia,
        "prioridad_score": score,
        "prioridad": PRIORITY_LABELS[gravedad],
        "sugerencia": suggestion,
        "ejecucion": ejecucion,
    }


def sort_events(events: list[dict[str, Any]]) -> list[dict[str, Any]]:
    return sorted(
        events,
        key=lambda event: (
            -int(event["prioridad_score"]),
            event["gravedad"],
            event["fuente"],
            event["id"],
        ),
    )


def build_chain_events(chain_result: dict[str, Any]) -> list[dict[str, Any]]:
    if not chain_result:
        return [
            make_event(
                event_id="operational_chain_validator_unavailable",
                fuente="runtime",
                problema="No se pudo leer el validador de cadena operacional.",
                gravedad="WARNING",
                accion_sugerida="Revisar disponibilidad del validador antes de cerrar gates documentales.",
                impacto=5,
                urgencia=4,
                requiere_confirmacion=False,
            )
        ]

    canonized = [
        check
        for check in chain_result.get("checks", [])
        if check.get("status") == "WARNING_CANONIZED"
    ]
    failed = [check for check in chain_result.get("checks", []) if check.get("status") == "FAIL"]
    missing_external = {
        "chain_csv_exists",
        "schema_csv_exists",
    }
    missing_names = [check["name"] for check in failed if check.get("name") in missing_external]
    other_failures = [
        check["name"] for check in failed if check.get("name") not in missing_external
    ]
    events: list[dict[str, Any]] = []
    if canonized and not failed:
        events.append(
            make_event(
                event_id="external_operational_chain_csv_canonized",
                fuente="runtime",
                problema="CSV externos de cadena operacional canonizados como legado/opcional.",
                gravedad="INFO",
                accion_sugerida="Usar estado interno SDU (bitacora/runtime) como fallback canonico.",
                impacto=1,
                urgencia=1,
                recurrencia=len(canonized),
                requiere_confirmacion=False,
            )
        )
    if missing_names:
        events.append(
            make_event(
                event_id="external_operational_chain_csv_missing",
                fuente="runtime",
                problema="Faltan CSV externos de indice puente/schema para validar la cadena operacional.",
                gravedad="WARNING",
                accion_sugerida=(
                    "Restaurar los CSV externos esperados o promover una ruta canonica nueva "
                    "mediante gate documental con evidencia."
                ),
                impacto=6,
                urgencia=5,
                recurrencia=len(missing_names),
                requiere_confirmacion=True,
            )
        )
    if other_failures:
        events.append(
            make_event(
                event_id="operational_chain_contract_failure",
                fuente="runtime",
                problema="La cadena operacional tiene fallas fuera de faltantes externos tolerados.",
                gravedad="CRITICAL",
                accion_sugerida="Bloquear cierre de gates dependientes y corregir contrato antes de operar.",
                impacto=9,
                urgencia=9,
                recurrencia=len(other_failures),
                requiere_confirmacion=True,
            )
        )
    if not failed and not canonized:
        events.append(
            make_event(
                event_id="operational_chain_stable",
                fuente="runtime",
                problema="Cadena operacional validada sin fallas.",
                gravedad="INFO",
                accion_sugerida="Mantener observacion continua sin remediacion.",
                impacto=1,
                urgencia=1,
            )
        )
    return events


def detect_repo_events() -> list[dict[str, Any]]:
    status = run_command(["git", "status", "--porcelain=v1"])
    events: list[dict[str, Any]] = []
    if not status["ok"]:
        return [
            make_event(
                event_id="repo_status_unavailable",
                fuente="repo",
                problema="No se pudo leer el estado Git local.",
                gravedad="CRITICAL",
                accion_sugerida="Detener acciones repo-dependientes hasta recuperar estado Git.",
                impacto=9,
                urgencia=8,
                requiere_confirmacion=True,
            )
        ]

    changed_count = len([line for line in status["stdout"].splitlines() if line.strip()])
    if changed_count:
        events.append(
            make_event(
                event_id="repo_local_operational_delta_visible",
                fuente="repo",
                problema=f"Hay {changed_count} cambios locales visibles pendientes de consolidacion.",
                gravedad="INFO",
                accion_sugerida=(
                    "Mantenerlos en rama gobernada y promover commit/PR solo con confirmacion explicita."
                ),
                impacto=3,
                urgencia=2,
                recurrencia=changed_count,
                requiere_confirmacion=True,
            )
        )
    else:
        events.append(
            make_event(
                event_id="repo_stable",
                fuente="repo",
                problema="Repositorio local sin cambios pendientes.",
                gravedad="INFO",
                accion_sugerida="Continuar observacion.",
                impacto=1,
                urgencia=1,
            )
        )
    return events


def detect_ci_events() -> list[dict[str, Any]]:
    result = run_command(
        [
            "gh",
            "run",
            "list",
            "--limit",
            "5",
            "--json",
            "databaseId,status,conclusion,workflowName,headBranch,headSha,createdAt,url",
        ],
        timeout=45,
    )
    if not result["ok"]:
        return [
            make_event(
                event_id="ci_remote_status_unavailable",
                fuente="ci",
                problema="No se pudo leer el estado remoto de GitHub Actions.",
                gravedad="WARNING",
                accion_sugerida="Reintentar lectura CI con gh autenticado antes de tomar decisiones de release.",
                impacto=5,
                urgencia=4,
                requiere_confirmacion=False,
            )
        ]
    runs = json.loads(result["stdout"] or "[]")
    failed = [run for run in runs if run.get("conclusion") in {"failure", "cancelled", "timed_out"}]
    in_progress = [run for run in runs if run.get("status") not in {"completed"}]
    if failed:
        return [
            make_event(
                event_id="ci_failed",
                fuente="ci",
                problema="Hay ejecuciones CI recientes fallidas o canceladas.",
                gravedad="CRITICAL",
                accion_sugerida="Bloquear merge/release y abrir carril de correccion CI.",
                impacto=9,
                urgencia=9,
                recurrencia=len(failed),
                requiere_confirmacion=True,
            )
        ]
    if in_progress:
        return [
            make_event(
                event_id="ci_in_progress",
                fuente="ci",
                problema="Hay checks CI en ejecucion.",
                gravedad="INFO",
                accion_sugerida="Esperar conclusion antes de decisiones de publicacion.",
                impacto=3,
                urgencia=3,
            )
        ]
    return [
        make_event(
            event_id="ci_stable",
            fuente="ci",
            problema="CI remoto reciente en estado estable.",
            gravedad="INFO",
            accion_sugerida="Mantener monitoreo.",
            impacto=1,
            urgencia=1,
        )
    ]


def detect_runtime_events() -> list[dict[str, Any]]:
    operational = read_json(ROOT / ".sdu" / "operational-mode.json")
    if operational.get("operational_mode") != "active":
        return [
            make_event(
                event_id="operational_mode_inactive",
                fuente="runtime",
                problema="Modo operacional no figura activo.",
                gravedad="CRITICAL",
                accion_sugerida="Reactivar G8 antes de ejecutar nuevas ordenes.",
                impacto=8,
                urgencia=8,
                requiere_confirmacion=False,
            )
        ]
    return [
        make_event(
            event_id="runtime_stable",
            fuente="runtime",
            problema="Modo operacional y panel vivo activos.",
            gravedad="INFO",
            accion_sugerida="Mantener operacion continua.",
            impacto=1,
            urgencia=1,
        )
    ]


def detect_dependency_events() -> list[dict[str, Any]]:
    dependabot = ROOT / ".github" / "dependabot.yml"
    pyproject = ROOT / "pyproject.toml"
    events: list[dict[str, Any]] = []
    if not dependabot.exists():
        events.append(
            make_event(
                event_id="dependabot_config_missing",
                fuente="dependencies",
                problema="No se encontro configuracion Dependabot.",
                gravedad="WARNING",
                accion_sugerida="Restaurar configuracion Dependabot gobernada.",
                impacto=5,
                urgencia=4,
                requiere_confirmacion=True,
            )
        )
    if not pyproject.exists():
        events.append(
            make_event(
                event_id="pyproject_missing",
                fuente="dependencies",
                problema="No se encontro pyproject.toml.",
                gravedad="CRITICAL",
                accion_sugerida="Bloquear cambios Python hasta restaurar manifiesto del proyecto.",
                impacto=9,
                urgencia=8,
                requiere_confirmacion=True,
            )
        )
    if not events:
        events.append(
            make_event(
                event_id="dependencies_surface_visible",
                fuente="dependencies",
                problema="Manifiesto Python y Dependabot visibles.",
                gravedad="INFO",
                accion_sugerida="Mantener monitoreo semanal de dependencias.",
                impacto=1,
                urgencia=1,
            )
        )
    return events


def detect_bitacora_events() -> list[dict[str, Any]]:
    chain_result = read_chain_validator()
    chain_canonized = chain_result.get("status") == "WARNING_CANONIZED" or any(
        check.get("status") == "WARNING_CANONIZED" for check in chain_result.get("checks", [])
    )
    entries = read_jsonl_tail(BITACORA_PATH)
    csv_mentions = [
        entry
        for entry in entries
        if "external_csv_missing" in json.dumps(entry, ensure_ascii=False)
        or "csv_missing" in json.dumps(entry, ensure_ascii=False)
    ]
    if csv_mentions and not chain_canonized:
        return [
            make_event(
                event_id="bitacora_recurrent_external_csv_missing",
                fuente="bitacora",
                problema="La bitacora registra faltantes externos CSV recurrentes.",
                gravedad="WARNING",
                accion_sugerida="Abrir carril documental para resolver fuente externa o actualizar canon.",
                impacto=6,
                urgencia=5,
                recurrencia=len(csv_mentions),
                requiere_confirmacion=True,
            )
        ]
    if csv_mentions and chain_canonized:
        return [
            make_event(
                event_id="bitacora_external_csv_missing_canonized",
                fuente="bitacora",
                problema="Menciones historicas de CSV externos reconocidas como estado canonizado.",
                gravedad="INFO",
                accion_sugerida="Mantener fallback interno SDU sin remediacion automatica.",
                impacto=1,
                urgencia=1,
                recurrencia=len(csv_mentions),
                requiere_confirmacion=False,
            )
        ]
    return [
        make_event(
            event_id="bitacora_stable",
            fuente="bitacora",
            problema="Bitacora reciente sin eventos repetidos de riesgo.",
            gravedad="INFO",
            accion_sugerida="Continuar registro automatico.",
            impacto=1,
            urgencia=1,
        )
    ]


def read_chain_validator() -> dict[str, Any]:
    result = run_command(
        [
            "powershell",
            "-NoProfile",
            "-ExecutionPolicy",
            "Bypass",
            "-File",
            "tools\\validate_proj_cdx_operational_chain.ps1",
            "-Json",
        ],
        timeout=60,
    )
    if not result["stdout"]:
        return {}
    try:
        return json.loads(result["stdout"])
    except json.JSONDecodeError:
        return {}


def collect_events() -> list[dict[str, Any]]:
    chain_result = read_chain_validator()
    events: list[dict[str, Any]] = []
    events.extend(detect_repo_events())
    events.extend(detect_ci_events())
    events.extend(detect_runtime_events())
    events.extend(detect_dependency_events())
    events.extend(detect_bitacora_events())
    events.extend(build_chain_events(chain_result))
    return sort_events(events)


def build_state(events: list[dict[str, Any]], timestamp: str) -> dict[str, Any]:
    active_alerts = [event for event in events if event["gravedad"] in {"CRITICAL", "WARNING"}]
    suggestions = [event["sugerencia"] for event in events]
    priority = [
        {
            "rank": index + 1,
            "id": event["id"],
            "gravedad": event["gravedad"],
            "prioridad": event["prioridad"],
            "prioridad_score": event["prioridad_score"],
            "problema": event["problema"],
        }
        for index, event in enumerate(events)
    ]
    counts = {
        "CRITICAL": len([event for event in events if event["gravedad"] == "CRITICAL"]),
        "WARNING": len([event for event in events if event["gravedad"] == "WARNING"]),
        "INFO": len([event for event in events if event["gravedad"] == "INFO"]),
    }
    return {
        "schema_version": 1,
        "intent": "intelligent_operation_layer_activation",
        "mode": "ADAPTIVE_INTELLIGENCE_ACTIVE",
        "generated_at": timestamp,
        "monitor_mode": "continuous_on_trace",
        "auto_apply": False,
        "summary": counts,
        "eventos": events,
        "alertas_activas": active_alerts,
        "sugerencias_automaticas": suggestions,
        "prioridad": priority,
    }


def record_detected_events(events: list[dict[str, Any]], timestamp: str, origin: str) -> None:
    for event in events:
        entry = {
            "timestamp": timestamp,
            "intent": "intelligent_operation_layer_activation",
            "tipo": "detected_event",
            "event_id": event["id"],
            "gravedad": event["gravedad"],
            "sugerencia": event["sugerencia"],
            "ejecucion": event["ejecucion"],
            "origen": origin,
        }
        append_jsonl(BITACORA_PATH, entry)
        append_jsonl(
            NOC_EVENTS_PATH,
            {
                "timestamp": timestamp,
                "type": "SDU_INTELLIGENT_DETECTED_EVENT",
                "source": "sdu-intelligent-operation-layer",
                "payload": entry,
            },
        )


def refresh_intelligence_state(
    origin: str = "codex-chat", record_events: bool = True
) -> dict[str, Any]:
    timestamp = utc_now()
    events = collect_events()
    state = build_state(events, timestamp)
    write_json(STATE_PATH, state)
    if record_events:
        record_detected_events(events, timestamp, origin)
    return state


def activate(args: argparse.Namespace) -> int:
    state = refresh_intelligence_state(origin=args.origin, record_events=True)
    print(json.dumps(state, ensure_ascii=False, indent=2))
    return 0


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="SDU intelligent operation layer")
    subparsers = parser.add_subparsers(dest="command", required=True)

    activate_parser = subparsers.add_parser("activate")
    activate_parser.add_argument("--origin", default="codex-chat")
    activate_parser.set_defaults(func=activate)
    return parser


def main(argv: list[str] | None = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)
    return args.func(args)


if __name__ == "__main__":
    raise SystemExit(main())
