from __future__ import annotations

import argparse
import json
from http import HTTPStatus
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import urlparse

REPO_ROOT = Path(__file__).resolve().parents[2]
LIVE_STATE_PATH = REPO_ROOT / "noc" / "noc-state.json"
FALLBACK_STATE_PATH = REPO_ROOT / "noc" / "state.json"
UI_ROOT = REPO_ROOT / "noc-web"
LOCAL_127_ORIGIN = "http://127.0.0.1:8787"
LOCALHOST_ORIGIN = "http://localhost:8787"


def as_list(value: object) -> list:
    if value is None:
        return []
    return value if isinstance(value, list) else [value]


def resolve_state_path() -> Path:
    if LIVE_STATE_PATH.exists():
        return LIVE_STATE_PATH
    if FALLBACK_STATE_PATH.exists():
        return FALLBACK_STATE_PATH
    raise FileNotFoundError(f"Missing NOC state: {LIVE_STATE_PATH} or {FALLBACK_STATE_PATH}")


def read_state_file(path: Path) -> dict:
    with path.open("r", encoding="utf-8") as state_file:
        state = json.load(state_file)
    if not isinstance(state, dict):
        raise ValueError(f"NOC state must be a JSON object: {path}")
    return state


def normalize_alert(alert: dict) -> dict:
    return {
        "id": alert.get("id") or alert.get("traceId") or "watchdog_alert",
        "type": alert.get("event_type") or alert.get("tipo") or "WATCHDOG_ALERT",
        "area": alert.get("area") or "watchdog",
        "status": alert.get("status") or "ACTIVE",
        "severity": alert.get("severity") or "HIGH",
        "classification": alert.get("classification") or alert.get("risk_state") or "observed",
        "decision": alert.get("decision") or alert.get("mode") or "OBSERVE",
        "count": alert.get("count") or 1,
        "source": alert.get("source") or "noc-live-state",
        "latest_timestamp": alert.get("latest_timestamp") or alert.get("timestamp"),
        "trace_id": alert.get("traceId") or alert.get("currentTraceId"),
        "note": alert.get("note") or alert.get("reason") or "",
        "escalation": alert.get("escalation") is True,
        "block_operations": alert.get("block_operations") is True,
    }


def normalize_decision(decision: dict, index: int) -> dict:
    return {
        "id": decision.get("id") or f"decision-{index + 1}",
        "event_type": decision.get("event_type") or decision.get("tipo") or "WATCHDOG_ALERT",
        "severity": decision.get("severity"),
        "classification": decision.get("classification") or decision.get("tipo") or "observed",
        "decision": decision.get("decision") or decision.get("accion") or "OBSERVE",
        "count": decision.get("count") or decision.get("cantidad"),
        "escalation": decision.get("escalation") is True,
        "block_operations": decision.get("block_operations") is True,
        "reason": decision.get("reason") or decision.get("note") or decision.get("nota") or "",
    }


def state_has_visible_contract(state: dict) -> bool:
    required = {"global_status", "alerts", "decisions", "kpis", "runtime", "timeline"}
    return required.issubset(state)


def normalize_state(raw_state: dict, selected_path: Path) -> dict:
    selected_relative = selected_path.relative_to(REPO_ROOT).as_posix()
    if state_has_visible_contract(raw_state):
        state = dict(raw_state)
        source_summary = dict(state.get("source_summary") or {})
        source_summary["selected_state_path"] = selected_relative
        source_summary["state_source_mode"] = "fallback_consolidated"
        state["source_summary"] = source_summary
        return state

    live = (
        raw_state.get("operation_live") or raw_state.get("noc", {}).get("operacion_en_vivo") or {}
    )
    noc = raw_state.get("noc") or {}
    health = raw_state.get("health") or {}
    bus = raw_state.get("bus") or {}
    visibility = raw_state.get("alert_visibility") or live.get("alert_visibility") or {}
    runtime_state = live.get("estado_sistema") or {}

    alerts = [normalize_alert(alert) for alert in as_list(live.get("alertas_activas"))]
    decisions = [
        normalize_decision(decision, index)
        for index, decision in enumerate(as_list(live.get("decisiones")))
    ]

    global_status = {
        "status": health.get("status")
        or noc.get("estado_general")
        or raw_state.get("status")
        or "UNKNOWN",
        "label": raw_state.get("status") or live.get("panel") or "NOC_OPERATIONAL",
        "score": health.get("score") or runtime_state.get("score"),
        "risk": health.get("risk") or runtime_state.get("riesgo"),
        "trend": health.get("trend") or "STABLE",
    }
    kpis = {
        "total_expedientes": noc.get("total_expedientes", 0),
        "expedientes_ok": noc.get("expedientes_ok", 0),
        "expedientes_con_error": noc.get("expedientes_con_error", 0),
        "live_alerts_visible": visibility.get("visible_count") or len(alerts),
        "source_watchdog_alerts": visibility.get("source_watchdog_alerts")
        or noc.get("alertas_activas")
        or bus.get("visible_alerts")
        or 0,
        "classified_events": 0,
        "visible_events": bus.get("visible_events", 0),
        "visible_alerts": bus.get("visible_alerts") or noc.get("alertas_activas") or len(alerts),
        "focus_alerts": len(as_list(live.get("foco_visible"))),
        "monitoring_alerts": len(as_list(live.get("monitoreo_agregado"))),
    }
    runtime = {
        "project_root": runtime_state.get("root") or "C:/CEO/project-cdx",
        "operational_mode": live.get("operational_mode") or "active",
        "trace_mode": live.get("trace_mode") or runtime_state.get("trace"),
        "swarm_mode": live.get("swarm_mode") or runtime_state.get("swarm"),
        "silent_mode": live.get("silent_mode"),
        "runtime": runtime_state.get("runtime"),
        "watchdog": runtime_state.get("watchdog"),
        "lifecycle": runtime_state.get("lifecycle"),
        "local_desktop_authority": True,
        "cloud_gate": "read-observe",
    }
    timeline = [
        {
            "timestamp": raw_state.get("generated_at") or live.get("generated_at"),
            "type": "STATE_UPDATED",
            "source": selected_relative,
            "summary": "NOC API selected live generated state.",
        }
    ]

    return {
        "schema_version": 1,
        "global_status": global_status,
        "alerts": alerts,
        "decisions": decisions,
        "kpis": kpis,
        "runtime": runtime,
        "timeline": timeline,
        "updated_at": raw_state.get("generated_at") or live.get("generated_at"),
        "source_summary": {
            "selected_state_path": selected_relative,
            "state_source_mode": "live_generated",
            "preferred_state": LIVE_STATE_PATH.relative_to(REPO_ROOT).as_posix(),
            "fallback_state": FALLBACK_STATE_PATH.relative_to(REPO_ROOT).as_posix(),
        },
    }


def load_state() -> dict:
    selected_path = resolve_state_path()
    return normalize_state(read_state_file(selected_path), selected_path)


def is_allowed_origin(origin: str | None) -> bool:
    return origin in {LOCAL_127_ORIGIN, LOCALHOST_ORIGIN}


def send_cors_headers(handler: BaseHTTPRequestHandler) -> None:
    origin = handler.headers.get("Origin")
    if origin == LOCAL_127_ORIGIN:
        handler.send_header("Access-Control-Allow-Origin", LOCAL_127_ORIGIN)
        handler.send_header("Vary", "Origin")
    elif origin == LOCALHOST_ORIGIN:
        handler.send_header("Access-Control-Allow-Origin", LOCALHOST_ORIGIN)
        handler.send_header("Vary", "Origin")


def send_common_headers(handler: BaseHTTPRequestHandler, content_type: str, length: int) -> None:
    handler.send_header("Content-Type", content_type)
    handler.send_header("Cache-Control", "no-store")
    send_cors_headers(handler)
    handler.send_header("Content-Length", str(length))


def json_response(handler: BaseHTTPRequestHandler, status: HTTPStatus, payload: object) -> None:
    body = json.dumps(payload, ensure_ascii=False, indent=2).encode("utf-8")
    handler.send_response(status.value)
    send_common_headers(handler, "application/json; charset=utf-8", len(body))
    handler.end_headers()
    handler.wfile.write(body)


def static_response(handler: BaseHTTPRequestHandler, path: Path, content_type: str) -> None:
    body = path.read_bytes()
    handler.send_response(HTTPStatus.OK.value)
    send_common_headers(handler, content_type, len(body))
    handler.end_headers()
    handler.wfile.write(body)


class NocHandler(BaseHTTPRequestHandler):
    def do_OPTIONS(self) -> None:  # noqa: N802 - stdlib handler API
        origin = self.headers.get("Origin")
        if origin and not is_allowed_origin(origin):
            self.send_response(HTTPStatus.FORBIDDEN.value)
            self.end_headers()
            return

        self.send_response(HTTPStatus.NO_CONTENT.value)
        send_cors_headers(self)
        self.send_header("Access-Control-Allow-Methods", "GET, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "Content-Type")
        self.end_headers()

    def do_GET(self) -> None:  # noqa: N802 - stdlib handler API
        route = urlparse(self.path).path.rstrip("/") or "/"
        try:
            if route == "/":
                return static_response(self, UI_ROOT / "index.html", "text/html; charset=utf-8")
            if route == "/app.js":
                return static_response(
                    self,
                    UI_ROOT / "app.js",
                    "application/javascript; charset=utf-8",
                )
            if route == "/style.css":
                return static_response(self, UI_ROOT / "style.css", "text/css; charset=utf-8")

            state = load_state()
            if route == "/state":
                return json_response(self, HTTPStatus.OK, state)
            if route == "/alerts":
                return json_response(self, HTTPStatus.OK, state.get("alerts", []))
            if route == "/kpis":
                return json_response(self, HTTPStatus.OK, state.get("kpis", {}))
            if route == "/decisions":
                return json_response(self, HTTPStatus.OK, state.get("decisions", []))

            return json_response(self, HTTPStatus.NOT_FOUND, {"error": "not_found", "path": route})
        except FileNotFoundError as exc:
            return json_response(
                self,
                HTTPStatus.SERVICE_UNAVAILABLE,
                {"error": "state_missing", "detail": str(exc)},
            )
        except (ValueError, json.JSONDecodeError) as exc:
            return json_response(
                self,
                HTTPStatus.INTERNAL_SERVER_ERROR,
                {"error": "state_invalid", "detail": str(exc)},
            )

    def log_message(self, log_format: str, *args: object) -> None:
        return


def main() -> None:
    parser = argparse.ArgumentParser(description="Read-only local NOC API")
    parser.add_argument("--host", default="127.0.0.1")
    parser.add_argument("--port", type=int, default=8787)
    args = parser.parse_args()

    server = ThreadingHTTPServer((args.host, args.port), NocHandler)
    print(f"NOC API listening on http://{args.host}:{args.port}", flush=True)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass
    finally:
        server.server_close()


if __name__ == "__main__":
    main()
