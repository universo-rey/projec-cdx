from http.server import ThreadingHTTPServer, SimpleHTTPRequestHandler
from pathlib import Path
from urllib.parse import urlparse
import datetime as _dt
import json
import os
import subprocess

ROOT = Path(__file__).resolve().parents[1]
COMMANDS_DIR = ROOT / "commands"
LEGACY_COMMANDS_DIR = COMMANDS_DIR
LIVE_CATALOG_PATH = ROOT / "config" / "actions_live_catalog.json"
LEGACY_CATALOG_PATH = ROOT / "config" / "actions_catalog.json"
LOG_PATH = ROOT / "logs" / "action_execution.jsonl"
STATE_PATH = ROOT / "state" / "predictive_score.json"
RECOMMENDED_PATH = ROOT / "outbox" / "recommended_actions.json"
G8_DIR = Path(r"C:\CEO\evidence\g8-operational")
G8_EXECUTED_PATH = G8_DIR / "actions-executed.jsonl"
G8_TRACE_PATH = G8_DIR / "decision-trace.jsonl"
G8_METRICS_PATH = G8_DIR / "metrics.json"
G8_SUGGESTED_PATH = G8_DIR / "actions-suggested.jsonl"
G9_CONFIG_PATH = G8_DIR / "auto-execution-config.json"
G9_EVIDENCE_PATH = G8_DIR / "controlled-auto-execution-g9.json"
AUTO_CANDIDATES_PATH = G8_DIR / "auto-promotable-candidates.json"
RHYTHM_CONFIG_PATH = ROOT / "config" / "operational_rhythm_g8_beta.json"
RHYTHM_SESSION_PATH = G8_DIR / "beta-session.json"
G8_ALLOWED_FILES = {
    "actions-executed.jsonl",
    "actions-suggested.jsonl",
    "decision-trace.jsonl",
    "metrics.json",
    "beta-session.json",
    "beta-priority-queue.json",
    "operational-rhythm-summary.md",
    "auto-promotable-candidates.json",
    "auto-execution-config.json",
    "controlled-auto-execution-g9.json",
    "controlled-auto-execution-g9-postcheck.json",
    "evidence-accumulation-delta.json",
}


# CEO_WEB_GLOBAL_BEGIN
CEO_ROOT = Path(r"C:\CEO")
PROJECT_ROOT = CEO_ROOT / "project-cdx"
COMMANDS_DIR = PROJECT_ROOT / "noc" / "actions"
SYSTEM_MAP_PATH = PROJECT_ROOT / "noc" / "SYSTEM_MAP.json"
NOC_EVENTS_PATH = PROJECT_ROOT / "noc" / "events" / "log.jsonl"
NOC_EVENTS_DIR = PROJECT_ROOT / "noc" / "events"
NOC_EVENT_MAX_BYTES = 1024 * 1024
NOC_ALLOWED_EVENT_TYPES = {
    "SDU_NOC_G2_DECREE_OBSERVED",
    "CE-001_RECOGNITION_REQUIRED",
    "CE-002_CONFLICTS_PRESENT",
}
NOC_CONTAINMENT_MODE = os.environ.get("SDU_NOC_CONTAINMENT_MODE", "0") != "0"
EXECUTION_RUNTIME_ROOT = PROJECT_ROOT / ".cabina" / "execution-runtime"
WEB_ALIASES = {
    "core": PROJECT_ROOT,
    "noc": PROJECT_ROOT / "noc",
    "watchdog": ROOT,
    "runtime": EXECUTION_RUNTIME_ROOT,
    "execution-runtime": EXECUTION_RUNTIME_ROOT,
    "kpi": EXECUTION_RUNTIME_ROOT / "kpi",
    "tools": PROJECT_ROOT / "tools",
    "docs": CEO_ROOT,
}
WEB_ALIAS_FILES = {
    "event-bus": EXECUTION_RUNTIME_ROOT / "event-bus-proxy.jsonl",
}
WEB_ROOT_ASSETS = {"/app.js", "/styles.css", "/canvas.html", "/owner.html", "/ceo-index.json", "/sdu-live.js", "/sdu-live.css"}
WEB_DENY_PARTS = {".git", "node_modules", "__pycache__", ".pytest_cache", ".ruff_cache", ".venv", ".venv_clean", ".venv_test"}
WEB_DENY_NAMES = {".env", ".env.local"}
WEB_DENY_TOKENS = ("secret", "password", "credential", "apikey", "api_key", "private-key")


def web_path_allowed(base, target):
    try:
        base = base.resolve()
        target = target.resolve()
    except Exception:
        return False
    if base != target and base not in target.parents:
        return False
    lowered_parts = {part.lower() for part in target.parts}
    if lowered_parts.intersection(WEB_DENY_PARTS):
        return False
    name = target.name.lower()
    if name in WEB_DENY_NAMES or any(token in name for token in WEB_DENY_TOKENS):
        return False
    if target.suffix.lower() in {".pem", ".pfx", ".key"}:
        return False
    return True
# CEO_WEB_GLOBAL_END

# KPI_BOARD_G14_BEGIN
KPI_DIR = EXECUTION_RUNTIME_ROOT / "kpi"
KPI_SNAPSHOT_PATH = KPI_DIR / "kpi-snapshot.json"
NOC_DISPATCHER_PATH = EXECUTION_RUNTIME_ROOT / "noc-dispatcher.jsonl"
KPI_CRITICAL_ACTIONS = {
    "RUN_CLEAN_PASS",
    "RUN_PROMOTE_PASS",
    "RUN_LEARN_PASS",
    "RUN_RECOVER_PASS",
    "ACK_ALERT",
    "ESCALATE_TO_OPERATOR",
    "BLOCK_ACTION",
    "APPROVE_PROMOTION",
    "SILENCE_LOW_ALERTS",
}
KPI_BUTTONS_AVAILABLE = 15
# KPI_BOARD_G14_END

def now_iso():
    return _dt.datetime.now().astimezone().isoformat()


def read_json(path):
    try:
        with open(path, "r", encoding="utf-8-sig") as handle:
            text = handle.read().strip()
            return json.loads(text) if text else None
    except Exception:
        return None


def normalize_action(item):
    if not isinstance(item, dict):
        return {}
    normalized = dict(item)
    action_id = str(normalized.get("actionId") or normalized.get("id") or "").strip()
    normalized["id"] = action_id
    normalized["actionId"] = action_id
    return normalized


def load_system_map():
    data = read_json(SYSTEM_MAP_PATH)
    return data if isinstance(data, dict) else {}


def load_catalog():
    system_map = load_system_map()
    if system_map:
        for key in ("actions", "actionCatalog", "catalog"):
            actions = system_map.get(key)
            if isinstance(actions, list) and actions:
                return [normalize_action(item) for item in actions if normalize_action(item).get("id")]

    source = LIVE_CATALOG_PATH if LIVE_CATALOG_PATH.exists() else LEGACY_CATALOG_PATH
    data = read_json(source)
    if isinstance(data, dict):
        for key in ("actions", "actionCatalog", "catalog"):
            actions = data.get(key)
            if isinstance(actions, list) and actions:
                return [normalize_action(item) for item in actions if normalize_action(item).get("id")]
        return []
    if not isinstance(data, list):
        return []
    return [normalize_action(item) for item in data if normalize_action(item).get("id")]


def first_recommendation(recommended):
    if isinstance(recommended, dict):
        recs = recommended.get("recommendations")
        if isinstance(recs, list) and recs:
            return str(recs[0].get("action") or "")
        return str(recommended.get("recommendation") or recommended.get("action") or "")
    return ""


def pre_state():
    score = read_json(STATE_PATH) or {}
    recommended = read_json(RECOMMENDED_PATH) or {}
    recommendation = first_recommendation(recommended)
    return {
        "score": score.get("score"),
        "risk": score.get("risk") or recommended.get("risk"),
        "health": score.get("effectiveHealth") or score.get("health") or recommended.get("effectiveHealth"),
        "graphOk": score.get("graphOk"),
        "recommendation": recommendation or "UNKNOWN",
        "noActionRequired": "NO ACTION REQUIRED" in recommendation.upper(),
        "sourceFiles": {
            "predictiveScore": str(STATE_PATH),
            "recommendedActions": str(RECOMMENDED_PATH),
        },
    }


def append_jsonl(path, entry):
    path.parent.mkdir(parents=True, exist_ok=True)
    with open(path, "a", encoding="utf-8") as handle:
        handle.write(json.dumps(entry, ensure_ascii=False, separators=(",", ":")) + "\n")


def resolve_script(action):
    script_text = str(action.get("script", "")).strip()
    if not script_text:
        return None
    script = Path(script_text)
    if not script.is_absolute():
        canonical = COMMANDS_DIR / script_text
        if canonical.exists():
            return canonical.resolve()
        legacy = LEGACY_COMMANDS_DIR / script_text
        if legacy.exists():
            return legacy.resolve()
        script = canonical
    return script.resolve()


def action_is_safe(action):
    risk = str(action.get("risk", "LOW")).upper()
    return (
        risk == "LOW"
        and not bool(action.get("mutatesData"))
        and not bool(action.get("impactsDataverse"))
        and not bool(action.get("impactsSharePoint"))
        and action.get("enabled", True) is not False
    )

def read_jsonl(path):
    items = []
    try:
        with open(path, "r", encoding="utf-8-sig") as handle:
            for line in handle:
                line = line.strip()
                if not line:
                    continue
                try:
                    items.append(json.loads(line))
                except Exception:
                    continue
    except Exception:
        return []
    return items


def load_rhythm_config():
    config = {
        "enabled": False,
        "maxActionsPerSession": 3,
        "promotableThreshold": 3,
        "individualConfirmationRequired": True,
    }
    data = read_json(RHYTHM_CONFIG_PATH)
    if isinstance(data, dict):
        config.update(data)
    return config


def action_success(entry):
    return str(entry.get("result", "")).upper() == "SUCCESS" or str(entry.get("status", "")).upper() == "EXECUTED"


def rhythm_context():
    config = load_rhythm_config()
    session = read_json(RHYTHM_SESSION_PATH) if RHYTHM_SESSION_PATH.exists() else {}
    if not isinstance(session, dict):
        session = {}
    session_id = str(session.get("sessionId") or _dt.datetime.now().strftime("G8_BETA_%Y%m%d"))
    max_actions = int(config.get("maxActionsPerSession") or config.get("MAX_ACTIONS_PER_SESSION") or 3)
    executed = [
        item for item in read_jsonl(G8_EXECUTED_PATH)
        if str(item.get("sessionId", "")) == session_id and action_success(item)
    ]
    return {
        "enabled": bool(config.get("enabled", False)),
        "sessionId": session_id,
        "maxActionsPerSession": max_actions,
        "sessionExecuted": len(executed),
        "remaining": max(0, max_actions - len(executed)),
        "promotableThreshold": int(config.get("promotableThreshold") or 3),
    }


def update_g8_metrics():
    suggested = read_jsonl(G8_SUGGESTED_PATH)
    executed = read_jsonl(G8_EXECUTED_PATH)
    successes = [item for item in executed if action_success(item)]
    failures = [item for item in executed if not action_success(item)]
    metrics = read_json(G8_METRICS_PATH)
    if not isinstance(metrics, dict):
        metrics = {}

    suggested_count = max(len(suggested), 1)
    success_by_action = {}
    failure_by_action = {}
    for item in successes:
        action_id = str(item.get("actionId", "UNKNOWN"))
        success_by_action[action_id] = success_by_action.get(action_id, 0) + 1
    for item in failures:
        action_id = str(item.get("actionId", "UNKNOWN"))
        failure_by_action[action_id] = failure_by_action.get(action_id, 0) + 1

    rhythm = rhythm_context()
    threshold = max(1, int(rhythm.get("promotableThreshold", 3)))
    max_repeated = max(success_by_action.values()) if success_by_action else 0
    repeatability = round(min(100.0, (max_repeated / float(threshold)) * 100.0), 2)
    confidence_gain = round((len(successes) / float(max(1, len(successes) + len(failures)))) * repeatability, 2)
    ratio = round(len(successes) / float(suggested_count), 4)
    promotable = {
        action_id: (count >= threshold and failure_by_action.get(action_id, 0) == 0)
        for action_id, count in success_by_action.items()
    }

    metrics.update({
        "generatedAt": now_iso(),
        "suggested": len(suggested),
        "executed": len(successes),
        "avoided": max(0, len(suggested) - len(successes)),
        "executionRatePercent": round((len(successes) / float(suggested_count)) * 100.0, 2),
        "repeatabilityScore": repeatability,
        "confidenceGain": confidence_gain,
        "suggestedExecutedRatio": ratio,
        "maxActionsPerSession": rhythm.get("maxActionsPerSession", 3),
        "sessionId": rhythm.get("sessionId"),
        "sessionExecuted": rhythm.get("sessionExecuted"),
        "sessionRemaining": rhythm.get("remaining"),
        "autoSuggestPromotable": promotable,
        "humanInTheLoop": True,
        "lowRiskOnly": True,
        "noDataverseImpact": True,
        "noSharePointImpact": True,
    })
    g9_config = load_g9_config()
    g9_auto = g9_config.get("autoExecution", {}) if isinstance(g9_config, dict) else {}
    g9_auto_enabled = g9_enabled(g9_config)
    metrics["autoExecutionEnabled"] = g9_auto_enabled
    metrics["AUTO_EXECUTION_GLOBAL"] = bool(g9_config.get("AUTO_EXECUTION_GLOBAL") is True)
    metrics["autoExecution"] = {
        "enabled": g9_auto_enabled,
        "maxAutoPerSession": int(g9_auto.get("maxAutoPerSession") or 1),
        "requireHumanOverride": bool(g9_auto.get("requireHumanOverride", True)),
        "allowedActions": g9_auto.get("allowedActions", []),
        "allowedEventTypes": g9_auto.get("allowedEventTypes", ["ALERT_RAISED"]),
        "ruleSource": g9_auto.get("ruleSource", "G9_AUTO_PROMOTION"),
        "autoSessionId": g9_auto.get("autoSessionId"),
    }
    metrics["autoPromotableCount"] = sum(1 for value in promotable.values() if value)
    G8_METRICS_PATH.parent.mkdir(parents=True, exist_ok=True)
    with open(G8_METRICS_PATH, "w", encoding="utf-8") as handle:
        json.dump(metrics, handle, ensure_ascii=False, indent=4)
        handle.write("\n")
    return metrics


def write_json(path, payload):
    path.parent.mkdir(parents=True, exist_ok=True)
    with open(path, "w", encoding="utf-8") as handle:
        json.dump(payload, handle, ensure_ascii=False, indent=4)
        handle.write("\n")


def load_g9_config():
    data = read_json(G9_CONFIG_PATH)
    if not isinstance(data, dict):
        return {
            "AUTO_EXECUTION_GLOBAL": False,
            "autoExecution": {
                "enabled": False,
                "maxAutoPerSession": 1,
                "requireHumanOverride": True,
                "allowedActions": [],
                "allowedEventTypes": ["ALERT_RAISED"],
                "ruleSource": "G9_AUTO_PROMOTION",
                "autoSessionId": _dt.datetime.now().strftime("G9_AUTO_%Y%m%d"),
            },
        }
    auto = data.get("autoExecution")
    if not isinstance(auto, dict):
        auto = {}
        data["autoExecution"] = auto
    auto.setdefault("maxAutoPerSession", 1)
    auto.setdefault("requireHumanOverride", True)
    auto.setdefault("allowedActions", [])
    auto.setdefault("allowedEventTypes", ["ALERT_RAISED"])
    auto.setdefault("ruleSource", "G9_AUTO_PROMOTION")
    auto.setdefault("autoSessionId", _dt.datetime.now().strftime("G9_AUTO_%Y%m%d"))
    return data


def save_g9_config(config):
    write_json(G9_CONFIG_PATH, config)


def g9_enabled(config):
    auto = config.get("autoExecution", {}) if isinstance(config, dict) else {}
    return bool(config.get("AUTO_EXECUTION_GLOBAL") is True and auto.get("enabled") is True)


def load_auto_candidates():
    data = read_json(AUTO_CANDIDATES_PATH)
    if not isinstance(data, dict):
        return []
    candidates = data.get("candidates")
    return candidates if isinstance(candidates, list) else []


def candidate_passes_g9(candidate):
    return (
        isinstance(candidate, dict)
        and str(candidate.get("classification", "")).upper() == "AUTO_PROMOTABLE"
        and int(candidate.get("executionCount") or 0) >= 3
        and int(candidate.get("errorCount") or 0) == 0
        and bool(candidate.get("readOnlyImpact")) is True
    )


def g9_allowed_actions(config):
    auto = config.get("autoExecution", {}) if isinstance(config, dict) else {}
    configured = {str(item) for item in auto.get("allowedActions", [])}
    promoted = {str(item.get("actionId")) for item in load_auto_candidates() if candidate_passes_g9(item)}
    return sorted(configured.intersection(promoted))


def g9_auto_context(config):
    auto = config.get("autoExecution", {}) if isinstance(config, dict) else {}
    session_id = str(auto.get("autoSessionId") or _dt.datetime.now().strftime("G9_AUTO_%Y%m%d"))
    max_auto = int(auto.get("maxAutoPerSession") or 1)
    executed = [
        item for item in read_jsonl(G8_EXECUTED_PATH)
        if item.get("autoExecuted") is True
        and str(item.get("autoSessionId", "")) == session_id
        and action_success(item)
    ]
    return {
        "autoSessionId": session_id,
        "maxAutoPerSession": max_auto,
        "autoExecutedInSession": len(executed),
        "remaining": max(0, max_auto - len(executed)),
    }


def g9_event_executed_keys():
    return {
        f"{str(item.get('actionId', ''))}|{str(item.get('eventId', ''))}"
        for item in read_jsonl(G8_EXECUTED_PATH)
        if action_success(item)
    }


def select_g9_suggestion(config, allowed_actions):
    auto = config.get("autoExecution", {}) if isinstance(config, dict) else {}
    allowed_event_types = {str(item) for item in auto.get("allowedEventTypes", ["ALERT_RAISED"])}
    executed_keys = g9_event_executed_keys()
    for suggestion in reversed(read_jsonl(G8_SUGGESTED_PATH)):
        action_id = str(suggestion.get("actionId", ""))
        event_id = str(suggestion.get("eventId", ""))
        event_type = str(suggestion.get("eventType", ""))
        key = f"{action_id}|{event_id}"
        if action_id in allowed_actions and event_type in allowed_event_types and key not in executed_keys:
            if str(suggestion.get("risk", "LOW")).upper() == "LOW":
                return suggestion
    return None


def block_g9_auto(reason, status=403, action_id="", event_id="", extra=None):
    payload = {
        "ok": False,
        "autoExecuted": False,
        "blocked": True,
        "reason": reason,
        "actionId": action_id,
        "eventId": event_id,
        "timestamp": now_iso(),
    }
    if isinstance(extra, dict):
        payload.update(extra)
    append_jsonl(G8_TRACE_PATH, {
        "traceType": "G9_AUTO_BLOCKED",
        "timestamp": payload["timestamp"],
        "actionId": action_id,
        "eventId": event_id,
        "reason": reason,
        "autoExecuted": False,
        "ruleSource": "G9_AUTO_PROMOTION",
        "automaticExecution": False,
        "runtimeMutation": False,
        "externalWrites": False,
    })
    return status, payload


def update_g9_evidence(payload):
    evidence = {
        "title": "SDU_CONTROLLED_AUTO_EXECUTION_G9",
        "generatedAt": now_iso(),
        "configPath": str(G9_CONFIG_PATH),
        "candidatePath": str(AUTO_CANDIDATES_PATH),
        "lastResult": payload,
        "guardrails": {
            "lowOnly": True,
            "readOnlyOnly": True,
            "noDataverseImpact": True,
            "noSharePointImpact": True,
            "runtimeMutation": False,
            "externalWrites": False,
            "killSwitch": str(G9_CONFIG_PATH),
        },
    }
    write_json(G9_EVIDENCE_PATH, evidence)
    return evidence
class OwnerActionHandler(SimpleHTTPRequestHandler):
    server_version = "SDUOwnerActionServer/1.1"
    extensions_map = {**SimpleHTTPRequestHandler.extensions_map, ".jsonl": "application/x-ndjson", ".md": "text/markdown; charset=utf-8", ".json": "application/json; charset=utf-8"}

    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=str(ROOT), **kwargs)

    def end_headers(self):
        self.send_header("Cache-Control", "no-store")
        origin = self.headers.get("Origin")
        if origin and self.origin_is_local(origin):
            self.send_header("Access-Control-Allow-Origin", origin)
        self.send_header("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "Content-Type, X-SDU-NOC-Producer")
        super().end_headers()

    def do_OPTIONS(self):
        self.send_response(204)
        self.end_headers()

    def translate_path(self, path):
        parsed = urlparse(path).path
        clean = parsed.lstrip("/")
        first, _, rest = clean.partition("/")
        if first in WEB_ALIAS_FILES and not rest:
            target = WEB_ALIAS_FILES[first]
            if web_path_allowed(target.parent, target):
                return str(target)
            return str(ROOT / "__blocked__")
        if first in WEB_ALIASES:
            base = WEB_ALIASES[first]
            target = (base / rest).resolve() if rest else base.resolve()
            if first == "core":
                events_dir = NOC_EVENTS_DIR.resolve()
                if target == events_dir or events_dir in target.parents:
                    return str(ROOT / "__blocked__")
            if web_path_allowed(base, target):
                return str(target)
            return str(ROOT / "__blocked__")
        return super().translate_path(path)
    def do_GET(self):
        parsed = urlparse(self.path).path
        if parsed in ("/", "/index.html"):
            self.path = "/noc-web/index.html"
            parsed = urlparse(self.path).path
        elif parsed in WEB_ROOT_ASSETS:
            self.path = f"/noc-web{parsed}"
            parsed = urlparse(self.path).path
        if parsed.startswith("/g8/"):
            self.handle_g8_get(parsed)
            return
        super().do_GET()

    def do_POST(self):
        parsed_path = urlparse(self.path).path
        if NOC_CONTAINMENT_MODE and parsed_path != "/api/noc/events":
            self.send_json(423, {
                "ok": False,
                "error": "NOC containment mode active; write endpoints are paused",
                "allowed": "/api/noc/events",
            })
            return
        if parsed_path.startswith("/action/"):
            self.handle_action_route(parsed_path.removeprefix("/action/"))
            return
        if parsed_path == "/api/noc/events":
            self.handle_local_noc_event()
            return
        if parsed_path == "/core/noc/events/log.json":
            self.send_json(410, {"ok": False, "error": "use /api/noc/events"})
            return
        if parsed_path == "/execute":
            self.handle_execute()
            return
        if parsed_path == "/g9/auto-execute":
            self.handle_g9_auto_execute()
            return
        if parsed_path == "/g9/kill-switch":
            self.handle_g9_kill_switch()
            return
        if parsed_path == "/kpi/action":
            self.handle_kpi_action()
            return
        if parsed_path == "/kpi/export-snapshot":
            self.handle_kpi_export_snapshot()
            return
        self.send_error(404, "Not found")

    def send_json(self, status, payload):
        body = json.dumps(payload, ensure_ascii=False).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)


    # KPI_BOARD_G14_BEGIN
    def build_kpi_snapshot_payload(self, buttons_available=None):
        panel = read_json(EXECUTION_RUNTIME_ROOT / "noc-panel.json") or {}
        evolution = read_json(EXECUTION_RUNTIME_ROOT / "evolution" / "evolution-state.json") or {}
        intel = panel.get("intelligence_overlay") or {}
        gov = panel.get("governance_overlay") or {}
        multi = panel.get("multi_domain_overlay") or {}
        evo = panel.get("evolution_overlay") or {}
        op = panel.get("operational_mode") or {}
        return {
            "timestamp": now_iso(),
            "system_status": op.get("status") or panel.get("status") or evolution.get("status"),
            "loop_status": evolution.get("status") or evo.get("status"),
            "cleaned_items": evolution.get("cleaned_items", evo.get("cleaned_items", 0)),
            "promoted_patterns": evolution.get("promoted_patterns", evo.get("promoted_patterns", 0)),
            "learned_patterns": evolution.get("learned_patterns", evo.get("learned_patterns", 0)),
            "recoveries_executed": evolution.get("recoveries_executed", evo.get("recoveries_executed", 0)),
            "alerts": intel.get("alerts_detected", len(panel.get("alerts") or [])),
            "anomalies": intel.get("anomalies_detected", 0),
            "governance_status": gov.get("status"),
            "domains": multi.get("domains") or [],
            "buttons_available": buttons_available or KPI_BUTTONS_AVAILABLE,
        }

    def kpi_event_from_payload(self, payload, status="REQUESTED"):
        action_type = str(payload.get("action_type") or "UNKNOWN").strip().upper()
        confirmation_required = bool(payload.get("confirmation_required")) or action_type in KPI_CRITICAL_ACTIONS
        return {
            "timestamp": now_iso(),
            "source": "noc-kpi-board",
            "action_type": action_type,
            "target_id": str(payload.get("target_id") or "system"),
            "decision_level": str(payload.get("decision_level") or ("HUMAN_REQUIRED" if confirmation_required else "ASSISTED")),
            "actor": "OPERATOR",
            "confirmation_required": confirmation_required,
            "confirmed": bool(payload.get("confirmed")),
            "status": status,
        }

    def handle_kpi_action(self):
        payload = self.read_payload()
        event = self.kpi_event_from_payload(payload)
        if event["confirmation_required"] and not event["confirmed"]:
            event["status"] = "BLOCKED_CONFIRMATION"
            append_jsonl(NOC_DISPATCHER_PATH, event)
            self.send_json(403, {"ok": False, "status": event["status"], "event": event})
            return
        append_jsonl(NOC_DISPATCHER_PATH, event)
        self.send_json(200, {"ok": True, "status": event["status"], "event": event})

    def handle_kpi_export_snapshot(self):
        payload = self.read_payload()
        payload["action_type"] = "EXPORT_KPI_SNAPSHOT"
        event = self.kpi_event_from_payload(payload)
        snapshot = self.build_kpi_snapshot_payload(payload.get("buttons_available"))
        write_json(KPI_SNAPSHOT_PATH, snapshot)
        append_jsonl(NOC_DISPATCHER_PATH, event)
        self.send_json(200, {"ok": True, "status": event["status"], "snapshot": str(KPI_SNAPSHOT_PATH), "event": event})
    # KPI_BOARD_G14_END
    def handle_g8_get(self, parsed_path):
        name = Path(parsed_path).name
        if name not in G8_ALLOWED_FILES:
            self.send_error(404, "Not found")
            return
        path = G8_DIR / name
        if not path.exists():
            self.send_error(404, "Not found")
            return
        body = path.read_bytes()
        self.send_response(200)
        content_type = "application/x-ndjson; charset=utf-8" if name.endswith(".jsonl") else "application/json; charset=utf-8"
        self.send_header("Content-Type", content_type)
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)


    def read_payload(self):
        length = int(self.headers.get("Content-Length", "0"))
        if length <= 0:
            return {}
        if length > 8192:
            raise ValueError("invalid request length")
        return json.loads(self.rfile.read(length).decode("utf-8"))

    def origin_is_local(self, origin):
        parsed_origin = urlparse(origin)
        host = str(self.headers.get("Host") or "").split(":", 1)[0].lower()
        origin_host = str(parsed_origin.hostname or "").lower()
        local_hosts = {"127.0.0.1", "localhost"}
        return origin_host in local_hosts and host in local_hosts

    def local_origin_allowed(self):
        origin = self.headers.get("Origin")
        if not origin:
            return True
        return self.origin_is_local(origin)

    def handle_local_noc_event(self):
        if not self.local_origin_allowed():
            self.send_json(403, {"ok": False, "error": "local NOC events require same-machine origin"})
            return
        content_type = str(self.headers.get("Content-Type") or "").lower()
        if "application/json" not in content_type:
            self.send_json(415, {"ok": False, "error": "application/json required"})
            return
        if str(self.headers.get("X-SDU-NOC-Producer") or "") != "sdu-live-g2":
            self.send_json(403, {"ok": False, "error": "missing local NOC producer header"})
            return
        if NOC_EVENTS_PATH.exists() and NOC_EVENTS_PATH.stat().st_size > NOC_EVENT_MAX_BYTES:
            self.send_json(507, {"ok": False, "error": "local NOC event log size limit reached"})
            return
        try:
            payload = self.read_payload()
        except Exception as exc:
            self.send_json(400, {"ok": False, "error": str(exc)})
            return
        if not isinstance(payload, dict):
            self.send_json(400, {"ok": False, "error": "JSON object required"})
            return
        event_type = str(payload.get("type") or "").strip()
        if event_type not in NOC_ALLOWED_EVENT_TYPES:
            self.send_json(400, {"ok": False, "error": "unsupported local NOC event type"})
            return
        event_payload = payload.get("payload") if isinstance(payload.get("payload"), dict) else {}
        signature = str(event_payload.get("signature") or "").strip()
        if signature:
            for existing in read_jsonl(NOC_EVENTS_PATH)[-100:]:
                if (
                    isinstance(existing, dict)
                    and existing.get("type") == event_type
                    and isinstance(existing.get("payload"), dict)
                    and str(existing["payload"].get("signature") or "") == signature
                ):
                    self.send_json(200, {"ok": True, "duplicate": True, "path": str(NOC_EVENTS_PATH)})
                    return
        event = {
            "timestamp": now_iso(),
            "type": event_type,
            "source": "noc-web-g2",
            "payload": event_payload,
        }
        append_jsonl(NOC_EVENTS_PATH, event)
        self.send_json(200, {"ok": True, "path": str(NOC_EVENTS_PATH), "event": event})

    def handle_g9_kill_switch(self):
        payload = self.read_payload()
        config = load_g9_config()
        auto = config.get("autoExecution", {})
        config["AUTO_EXECUTION_GLOBAL"] = False
        auto["enabled"] = False
        config["autoExecution"] = auto
        config["disabledAt"] = now_iso()
        config["disabledBy"] = str(payload.get("disabledBy") or "OWNER_OVERRIDE")
        config["disableReason"] = str(payload.get("reason") or "G9_KILL_SWITCH")
        save_g9_config(config)
        metrics = update_g8_metrics()
        append_jsonl(G8_TRACE_PATH, {
            "traceType": "G9_KILL_SWITCH",
            "timestamp": config["disabledAt"],
            "disabledBy": config["disabledBy"],
            "reason": config["disableReason"],
            "autoExecutionEnabled": False,
            "automaticExecution": False,
            "runtimeMutation": False,
            "externalWrites": False,
        })
        self.send_json(200, {"ok": True, "autoExecutionEnabled": False, "metrics": metrics})

    def handle_g9_auto_execute(self):
        timestamp = now_iso()
        config = load_g9_config()
        if not g9_enabled(config):
            status, payload = block_g9_auto("AUTO_EXECUTION_DISABLED", 403)
            self.send_json(status, payload)
            return
        allowed_actions = g9_allowed_actions(config)
        if not allowed_actions:
            status, payload = block_g9_auto("NO_AUTO_PROMOTABLE_ALLOWED_ACTION", 403)
            self.send_json(status, payload)
            return
        context = g9_auto_context(config)
        if context["autoExecutedInSession"] >= context["maxAutoPerSession"]:
            status, payload = block_g9_auto("MAX_AUTO_PER_SESSION_REACHED", 429, extra=context)
            self.send_json(status, payload)
            return
        suggestion = select_g9_suggestion(config, allowed_actions)
        if not suggestion:
            self.send_json(200, {
                "ok": True,
                "autoExecuted": False,
                "reason": "NO_ELIGIBLE_EVENT",
                "timestamp": timestamp,
                **context,
            })
            return
        action_id = str(suggestion.get("actionId", ""))
        event_id = str(suggestion.get("eventId", ""))
        event_type = str(suggestion.get("eventType", ""))
        catalog = load_catalog()
        action = next((item for item in catalog if str(item.get("id")) == action_id or str(item.get("actionId")) == action_id), None)
        if not action:
            status, payload = block_g9_auto("ACTION_NOT_FOUND", 404, action_id, event_id)
            self.send_json(status, payload)
            return
        if not action_is_safe(action):
            status, payload = block_g9_auto("ACTION_NOT_SAFE_LOW_READONLY", 403, action_id, event_id)
            self.send_json(status, payload)
            return
        script = resolve_script(action)
        commands_root = COMMANDS_DIR.resolve()
        legacy_root = LEGACY_COMMANDS_DIR.resolve()
        if script is None or script.parent not in {commands_root, legacy_root}:
            status, payload = block_g9_auto("SCRIPT_OUTSIDE_COMMANDS_WHITELIST", 403, action_id, event_id)
            self.send_json(status, payload)
            return
        if not script.exists():
            status, payload = block_g9_auto("SCRIPT_MISSING", 404, action_id, event_id)
            payload["script"] = str(script)
            self.send_json(status, payload)
            return

        state = pre_state()
        args = [
            "powershell.exe", "-NoProfile", "-ExecutionPolicy", "Bypass", "-File", str(script),
            "-ActionId", action_id,
            "-ActionLabel", str(action.get("label", action_id)),
            "-Risk", str(action.get("risk", "LOW")).upper(),
            "-ExecutedBy", "SYSTEM_AUTO",
            "-DecisionSource", "G9_AUTO_PROMOTION",
            "-PreStateJson", json.dumps(state, ensure_ascii=False, separators=(",", ":")),
        ]
        completed = subprocess.run(args, capture_output=True, text=True, timeout=120)
        result = "SUCCESS" if completed.returncode == 0 else "FAIL"
        entry = {
            "actionId": action_id,
            "eventId": event_id,
            "eventType": event_type,
            "autoExecuted": True,
            "ruleSource": "G9_AUTO_PROMOTION",
            "autoSessionId": context["autoSessionId"],
            "autoSessionOrdinal": context["autoExecutedInSession"] + 1,
            "maxAutoPerSession": context["maxAutoPerSession"],
            "actionLabel": action.get("label", action_id),
            "timestamp": timestamp,
            "executedBy": "SYSTEM_AUTO",
            "decisionSource": "G9_AUTO_PROMOTION",
            "risk": str(action.get("risk", "LOW")).upper(),
            "status": "EXECUTED" if completed.returncode == 0 else "FAILED",
            "result": result,
            "impact": "READ_ONLY",
            "expectedImpact": action.get("expectedImpact") or "LOCAL_READ_ONLY_ACTION",
            "preState": state,
            "postState": "UNCHANGED",
            "stdout": completed.stdout.strip(),
            "stderr": completed.stderr.strip(),
            "exitCode": completed.returncode,
            "runtimeMutation": False,
            "externalWrites": False,
            "dataverseImpact": False,
            "sharePointImpact": False,
        }
        append_jsonl(G8_EXECUTED_PATH, entry)
        append_jsonl(LOG_PATH, entry)
        if completed.returncode != 0:
            config["AUTO_EXECUTION_GLOBAL"] = False
            config.setdefault("autoExecution", {})["enabled"] = False
            config["disabledAt"] = now_iso()
            config["disableReason"] = "AUTO_EXECUTION_FAILURE_FAIL_CLOSED"
            save_g9_config(config)
        metrics = update_g8_metrics()
        trace = {
            "traceType": "G9_AUTO_EXECUTION",
            "timestamp": timestamp,
            "autoExecuted": completed.returncode == 0,
            "ruleSource": "G9_AUTO_PROMOTION",
            "actionId": action_id,
            "eventId": event_id,
            "eventType": event_type,
            "result": result,
            "exitCode": completed.returncode,
            "autoSessionId": context["autoSessionId"],
            "autoSessionOrdinal": context["autoExecutedInSession"] + 1,
            "maxAutoPerSession": context["maxAutoPerSession"],
            "runtimeMutation": False,
            "externalWrites": False,
            "dataverseImpact": False,
            "sharePointImpact": False,
            "autoExecutionEnabled": metrics.get("autoExecutionEnabled"),
        }
        append_jsonl(G8_TRACE_PATH, trace)
        evidence = update_g9_evidence({"execution": entry, "trace": trace, "metrics": metrics})
        self.send_json(200 if completed.returncode == 0 else 500, {
            "ok": completed.returncode == 0,
            "autoExecuted": completed.returncode == 0,
            "ruleSource": "G9_AUTO_PROMOTION",
            "actionId": action_id,
            "eventId": event_id,
            "eventType": event_type,
            "result": result,
            "timestamp": timestamp,
            "exitCode": completed.returncode,
            "autoSessionId": context["autoSessionId"],
            "autoSessionRemaining": metrics.get("autoExecution", {}).get("maxAutoPerSession", 1) - (context["autoExecutedInSession"] + (1 if completed.returncode == 0 else 0)),
            "metrics": metrics,
            "evidence": evidence,
        })

    def handle_action_route(self, action_name):
        try:
            payload = self.read_payload()
            if not isinstance(payload, dict):
                payload = {}
            payload.setdefault("actionId", action_name)
            payload.setdefault("executedBy", "OWNER_UI")
            payload.setdefault("decisionSource", "ACTION_ROUTE")
            payload.setdefault("confirmationMode", "DIRECT_ROUTE")
            self.handle_execute_payload(payload, action_id_override=action_name)
        except Exception as exc:
            timestamp = now_iso()
            self.send_json(400, {"ok": False, "error": str(exc), "timestamp": timestamp})

    def handle_execute_payload(self, payload, action_id_override=None):
        timestamp = now_iso()
        action_id = str(action_id_override or payload.get("actionId", "")).strip()
        event_id = str(payload.get("eventId", "") or payload.get("sourceEventId", "")).strip()
        executed_by = str(payload.get("executedBy") or "OWNER_UI")
        decision_source = str(payload.get("decisionSource") or "MANUAL_CLICK")
        confirmation_mode = str(payload.get("confirmationMode") or "INDIVIDUAL_MODAL")
        try:
            if not action_id:
                raise ValueError("missing actionId")

            catalog = load_catalog()
            action = next((item for item in catalog if str(item.get("id")) == action_id or str(item.get("actionId")) == action_id), None)
            if not action:
                self.send_json(404, {"ok": False, "error": "action not found"})
                return

            if not action_is_safe(action):
                self.send_json(403, {"ok": False, "error": "only LOW read-only local actions are enabled in G8"})
                return

            script = resolve_script(action)
            canonical_root = COMMANDS_DIR.resolve()
            legacy_root = LEGACY_COMMANDS_DIR.resolve()
            if script is None or script.parent not in {canonical_root, legacy_root}:
                self.send_json(403, {"ok": False, "error": "script outside commands whitelist"})
                return
            if not script.exists():
                self.send_json(404, {"ok": False, "error": "script missing", "script": str(script)})
                return

            rhythm = rhythm_context()
            if rhythm.get("enabled") and rhythm.get("sessionExecuted", 0) >= rhythm.get("maxActionsPerSession", 3):
                append_jsonl(G8_TRACE_PATH, {
                    "traceType": "RHYTHM_LIMIT_BLOCKED",
                    "timestamp": timestamp,
                    "actionId": action_id,
                    "eventId": event_id,
                    "sessionId": rhythm.get("sessionId"),
                    "maxActionsPerSession": rhythm.get("maxActionsPerSession"),
                    "sessionExecuted": rhythm.get("sessionExecuted"),
                    "decision": "BLOCKED_SESSION_LIMIT",
                    "automaticExecution": False,
                    "humanGateRequired": True,
                    "runtimeMutation": False,
                    "externalWrites": False,
                })
                self.send_json(429, {
                    "ok": False,
                    "error": "MAX_ACTIONS_PER_SESSION reached",
                    "sessionId": rhythm.get("sessionId"),
                    "maxActionsPerSession": rhythm.get("maxActionsPerSession"),
                    "sessionExecuted": rhythm.get("sessionExecuted"),
                })
                return

            state = pre_state()
            args = [
                "powershell.exe", "-NoProfile", "-ExecutionPolicy", "Bypass", "-File", str(script),
                "-ActionId", action_id,
                "-ActionLabel", str(action.get("label", action_id)),
                "-Risk", str(action.get("risk", "LOW")).upper(),
                "-ExecutedBy", executed_by,
                "-DecisionSource", decision_source,
                "-PreStateJson", json.dumps(state, ensure_ascii=False, separators=(",", ":")),
            ]
            completed = subprocess.run(args, capture_output=True, text=True, timeout=120)
            result = "SUCCESS" if completed.returncode == 0 else "FAIL"
            execution_entry = {
                "actionId": action_id,
                "eventId": event_id,
                "sessionId": rhythm.get("sessionId"),
                "sessionOrdinal": rhythm.get("sessionExecuted", 0) + 1,
                "maxActionsPerSession": rhythm.get("maxActionsPerSession"),
                "confirmationMode": confirmation_mode,
                "actionLabel": action.get("label", action_id),
                "timestamp": timestamp,
                "executedBy": executed_by,
                "decisionSource": decision_source,
                "risk": str(action.get("risk", "LOW")).upper(),
                "result": result,
                "impact": action.get("expectedImpact") or "LOCAL_READ_ONLY_ACTION",
                "preState": state,
                "postState": "UNCHANGED",
                "stdout": completed.stdout.strip(),
                "stderr": completed.stderr.strip(),
                "runtimeMutation": False,
                "externalWrites": False,
                "dataverseImpact": False,
                "sharePointImpact": False,
            }
            append_jsonl(G8_EXECUTED_PATH, execution_entry)
            rhythm_metrics = update_g8_metrics()
            promotable = rhythm_metrics.get("autoSuggestPromotable", {}).get(action_id, False)
            append_jsonl(G8_TRACE_PATH, {
                "traceType": "HUMAN_CONFIRMED_ACTION",
                "timestamp": timestamp,
                "actionId": action_id,
                "eventId": event_id,
                "sessionId": rhythm.get("sessionId"),
                "sessionOrdinal": rhythm.get("sessionExecuted", 0) + 1,
                "maxActionsPerSession": rhythm.get("maxActionsPerSession"),
                "decision": "EXECUTED" if completed.returncode == 0 else "FAILED",
                "executedBy": executed_by,
                "confirmationMode": confirmation_mode,
                "auto-suggest-promotable": bool(promotable),
                "repeatabilityScore": rhythm_metrics.get("repeatabilityScore"),
                "confidenceGain": rhythm_metrics.get("confidenceGain"),
                "suggestedExecutedRatio": rhythm_metrics.get("suggestedExecutedRatio"),
                "automaticExecution": False,
                "humanGateRequired": True,
                "runtimeMutation": False,
                "externalWrites": False,
            })
            if completed.returncode != 0:
                append_jsonl(LOG_PATH, {
                    "actionId": action_id,
                    "actionLabel": action.get("label", action_id),
                    "timestamp": timestamp,
                    "executedBy": executed_by,
                    "decisionSource": decision_source,
                    "risk": str(action.get("risk", "LOW")).upper(),
                    "result": result,
                    "preState": state,
                    "postState": "UNCHANGED",
                    "error": completed.stderr.strip() or completed.stdout.strip(),
                })
            self.send_json(200 if completed.returncode == 0 else 500, {
                "ok": completed.returncode == 0,
                "actionId": action_id,
                "eventId": event_id,
                "sessionId": rhythm.get("sessionId"),
                "sessionOrdinal": rhythm.get("sessionExecuted", 0) + 1,
                "maxActionsPerSession": rhythm.get("maxActionsPerSession"),
                "confirmationMode": confirmation_mode,
                "actionLabel": action.get("label", action_id),
                "timestamp": timestamp,
                "result": result,
                "stdout": completed.stdout.strip(),
                "stderr": completed.stderr.strip(),
                "sessionRemaining": rhythm_metrics.get("sessionRemaining"),
                "repeatabilityScore": rhythm_metrics.get("repeatabilityScore"),
                "confidenceGain": rhythm_metrics.get("confidenceGain"),
                "suggestedExecutedRatio": rhythm_metrics.get("suggestedExecutedRatio"),
                "autoSuggestPromotable": bool(promotable),
            })
        except Exception as exc:
            error_entry = {
                "actionId": action_id,
                "eventId": event_id,
                "timestamp": timestamp,
                "executedBy": executed_by,
                "decisionSource": decision_source,
                "result": "FAIL",
                "preState": pre_state(),
                "postState": "UNCHANGED",
                "error": str(exc),
                "runtimeMutation": False,
                "externalWrites": False,
            }
            append_jsonl(LOG_PATH, error_entry)
            append_jsonl(G8_EXECUTED_PATH, error_entry)
            append_jsonl(G8_TRACE_PATH, {
                "traceType": "HUMAN_CONFIRMED_ACTION",
                "timestamp": timestamp,
                "actionId": action_id,
                "eventId": event_id,
                "decision": "FAILED",
                "executedBy": executed_by,
                "confirmationMode": confirmation_mode,
                "automaticExecution": False,
                "humanGateRequired": True,
                "runtimeMutation": False,
                "externalWrites": False,
                "error": str(exc),
            })
            self.send_json(400, {"ok": False, "error": str(exc), "timestamp": timestamp})

    def handle_execute(self):
        self.send_json(410, {
            "ok": False,
            "error": "legacy /execute disabled; use /action/:name",
            "route": "/action/:name",
            "timestamp": now_iso(),
        })


if __name__ == "__main__":
    os.chdir(ROOT)
    port = int(os.environ.get("SDU_OWNER_PANEL_PORT", "8081"))
    print(f"Serving SDU NOC Web from {ROOT}")
    print(f"Open http://localhost:{port}/noc-web/")
    print(f"Owner panel http://localhost:{port}/noc-web/owner.html")
    print(f"G8 evidence http://localhost:{port}/g8/actions-suggested.jsonl")
    ThreadingHTTPServer(("127.0.0.1", port), OwnerActionHandler).serve_forever()



