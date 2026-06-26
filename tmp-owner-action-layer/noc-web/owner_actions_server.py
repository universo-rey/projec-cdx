from http.server import ThreadingHTTPServer, SimpleHTTPRequestHandler
from pathlib import Path
from urllib.parse import urlparse
import datetime as _dt
import json
import os
import re
import subprocess

ROOT = Path(__file__).resolve().parents[1]
COMMANDS_DIR = ROOT / "commands"
CATALOG_PATH = ROOT / "config" / "actions_catalog.json"
LOG_PATH = ROOT / "logs" / "action_execution.jsonl"
STATE_PATH = ROOT / "state" / "predictive_score.json"
RECOMMENDED_PATH = ROOT / "outbox" / "recommended_actions.json"
ACTION_ID_PATTERN = re.compile(r"^[a-z][a-z0-9_]{2,63}$")

OWNER_ACTIONS = {
    "check_alert_source": {
        "action_id": "check_alert_source",
        "label": "Revisar origen de alertas",
        "risk": "LOW",
        "script_name": "check-alert-source.ps1",
    },
    "evaluate_cleanup": {
        "action_id": "evaluate_cleanup",
        "label": "Evaluar limpieza controlada",
        "risk": "MEDIUM",
        "script_name": "cleanup-evaluation.ps1",
    },
}

ENV_ALLOWLIST = (
    "COMSPEC",
    "PATH",
    "PATHEXT",
    "POWERSHELL_TELEMETRY_OPTOUT",
    "PSModulePath",
    "SystemDrive",
    "SystemRoot",
    "TEMP",
    "TMP",
    "WINDIR",
)


def now_iso():
    return _dt.datetime.now().astimezone().isoformat()


def read_json(path):
    try:
        with open(path, "r", encoding="utf-8-sig") as handle:
            text = handle.read().strip()
            return json.loads(text) if text else None
    except Exception:
        return None


def load_catalog():
    data = read_json(CATALOG_PATH)
    return data if isinstance(data, list) else []


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


def append_log(entry):
    LOG_PATH.parent.mkdir(parents=True, exist_ok=True)
    with open(LOG_PATH, "a", encoding="utf-8") as handle:
        handle.write(json.dumps(entry, ensure_ascii=False, separators=(",", ":")) + "\n")


def safe_message(value):
    text = str(value).replace("\r", " ").replace("\n", " ").strip()
    return text[:240] if text else "error"


def lookup_owner_action(action_id):
    if not ACTION_ID_PATTERN.fullmatch(action_id):
        return None
    return OWNER_ACTIONS.get(action_id)


def resolve_action_script(action):
    commands_root = COMMANDS_DIR.resolve()
    script_name = action["script_name"]
    script = (COMMANDS_DIR / script_name).resolve()
    try:
        script.relative_to(commands_root)
    except ValueError as exc:
        raise ValueError("script outside commands whitelist") from exc
    if script.parent != commands_root:
        raise ValueError("script outside commands whitelist")
    return script


def minimal_env():
    env = {"NO_COLOR": "1"}
    for key in ENV_ALLOWLIST:
        value = os.environ.get(key)
        if value is not None:
            env[key] = value
    return env


def process_output_summary(completed):
    stdout = completed.stdout or ""
    stderr = completed.stderr or ""
    return {
        "returncode": completed.returncode,
        "stdoutBytes": len(stdout.encode("utf-8", errors="replace")),
        "stderrBytes": len(stderr.encode("utf-8", errors="replace")),
        "stdoutPresent": bool(stdout.strip()),
        "stderrPresent": bool(stderr.strip()),
    }


class OwnerActionHandler(SimpleHTTPRequestHandler):
    server_version = "SDUOwnerActionServer/1.0"

    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=str(ROOT), **kwargs)

    def end_headers(self):
        self.send_header("Cache-Control", "no-store")
        super().end_headers()

    def do_POST(self):
        if urlparse(self.path).path != "/execute":
            self.send_error(404, "Not found")
            return
        self.handle_execute()

    def send_json(self, status, payload):
        body = json.dumps(payload, ensure_ascii=False).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def handle_execute(self):
        timestamp = now_iso()
        try:
            length = int(self.headers.get("Content-Length", "0"))
            if length <= 0 or length > 4096:
                raise ValueError("invalid request length")
            payload = json.loads(self.rfile.read(length).decode("utf-8"))
            requested_action_id = str(payload.get("actionId", "")).strip()
            if not requested_action_id:
                raise ValueError("missing actionId")

            action = lookup_owner_action(requested_action_id)
            if not action:
                self.send_json(404, {"ok": False, "error": "action not allowed"})
                return

            risk = action["risk"]
            if risk == "HIGH":
                self.send_json(403, {"ok": False, "error": "high risk actions are disabled"})
                return

            script = resolve_action_script(action)
            if not script.exists():
                self.send_json(404, {"ok": False, "error": "script missing", "script": str(script)})
                return

            state = pre_state()
            action_id = action["action_id"]
            action_label = action["label"]
            args = [
                "powershell.exe", "-NoProfile", "-ExecutionPolicy", "Bypass", "-File", str(script),
                "-ActionId", action_id,
                "-ActionLabel", action_label,
                "-Risk", risk,
                "-ExecutedBy", "OWNER_UI",
                "-DecisionSource", "MANUAL_CLICK",
                "-PreStateJson", json.dumps(state, ensure_ascii=False, separators=(",", ":")),
            ]
            completed = subprocess.run(
                args,
                capture_output=True,
                text=True,
                timeout=120,
                cwd=str(COMMANDS_DIR.resolve()),
                env=minimal_env(),
                shell=False,
                check=False,
            )
            result = "SUCCESS" if completed.returncode == 0 else "FAIL"
            output_summary = process_output_summary(completed)
            if completed.returncode != 0:
                append_log({
                    "actionId": action_id,
                    "actionLabel": action_label,
                    "timestamp": timestamp,
                    "executedBy": "OWNER_UI",
                    "decisionSource": "MANUAL_CLICK",
                    "risk": risk,
                    "result": result,
                    "preState": state,
                    "postState": "UNCHANGED",
                    "error": output_summary,
                })
            self.send_json(200 if completed.returncode == 0 else 500, {
                "ok": completed.returncode == 0,
                "actionId": action_id,
                "actionLabel": action_label,
                "timestamp": timestamp,
                "result": result,
                "output": output_summary,
            })
        except Exception as exc:
            append_log({
                "actionId": "UNKNOWN",
                "timestamp": timestamp,
                "executedBy": "OWNER_UI",
                "decisionSource": "MANUAL_CLICK",
                "result": "FAIL",
                "preState": pre_state(),
                "postState": "UNCHANGED",
                "error": safe_message(exc),
            })
            self.send_json(400, {"ok": False, "error": safe_message(exc), "timestamp": timestamp})


if __name__ == "__main__":
    os.chdir(ROOT)
    port = int(os.environ.get("SDU_OWNER_PANEL_PORT", "8080"))
    print(f"Serving SDU NOC Web from {ROOT}")
    print(f"Open http://localhost:{port}/noc-web/")
    print(f"Owner panel http://localhost:{port}/noc-web/owner.html")
    ThreadingHTTPServer(("127.0.0.1", port), OwnerActionHandler).serve_forever()
