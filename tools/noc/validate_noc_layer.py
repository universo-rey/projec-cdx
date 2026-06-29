from __future__ import annotations

import json
import subprocess
import sys
import time
from pathlib import Path
from urllib.request import Request, urlopen

REPO_ROOT = Path(__file__).resolve().parents[2]
LIVE_STATE_PATH = REPO_ROOT / "noc" / "noc-state.json"
FALLBACK_STATE_PATH = REPO_ROOT / "noc" / "state.json"
SCHEMA_PATH = REPO_ROOT / "noc" / "schema.json"
INDEX_PATH = REPO_ROOT / "noc" / "index.json"
APP_PATH = REPO_ROOT / "noc-web" / "app.js"
API_PATH = REPO_ROOT / "tools" / "noc" / "noc_api.py"


def expected_state_path() -> Path:
    if LIVE_STATE_PATH.exists():
        return LIVE_STATE_PATH
    return FALLBACK_STATE_PATH


def read_json(path: Path) -> object:
    with path.open("r", encoding="utf-8") as file:
        return json.load(file)


def fetch_json(path: str, origin: str | None = None) -> tuple[object, str | None]:
    headers = {"Origin": origin} if origin else {}
    request = Request(f"http://127.0.0.1:8787{path}", headers=headers)
    with urlopen(request, timeout=5) as response:
        payload = json.loads(response.read().decode("utf-8"))
        return payload, response.headers.get("Access-Control-Allow-Origin")


def main() -> int:
    for path in [expected_state_path(), SCHEMA_PATH, INDEX_PATH, APP_PATH, API_PATH]:
        if not path.exists():
            print(f"missing: {path}")
            return 1

    read_json(expected_state_path())
    read_json(SCHEMA_PATH)
    read_json(INDEX_PATH)

    app_text = APP_PATH.read_text(encoding="utf-8")
    for endpoint in ["/state", "/alerts", "/kpis", "/decisions"]:
        if endpoint not in app_text:
            print(f"ui missing endpoint reference: {endpoint}")
            return 1

    process = subprocess.Popen(
        [sys.executable, str(API_PATH), "--host", "127.0.0.1", "--port", "8787"],
        cwd=str(REPO_ROOT),
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )
    try:
        time.sleep(1)
        checks = {
            "/state": dict,
            "/alerts": list,
            "/kpis": dict,
            "/decisions": list,
        }
        state_payload: dict | None = None
        for endpoint, expected_type in checks.items():
            payload, cors = fetch_json(endpoint, "http://127.0.0.1:8787")
            if cors == "*":
                print(f"wildcard CORS returned for {endpoint}")
                return 1
            if cors != "http://127.0.0.1:8787":
                print(f"unexpected CORS origin for {endpoint}: {cors}")
                return 1
            if not isinstance(payload, expected_type):
                print(f"unexpected payload type for {endpoint}: {type(payload).__name__}")
                return 1
            if endpoint == "/state":
                state_payload = payload

        if state_payload is None:
            print("state endpoint did not return payload")
            return 1

        required = [
            "global_status",
            "alerts",
            "decisions",
            "kpis",
            "runtime",
            "timeline",
            "updated_at",
            "source_summary",
        ]
        missing = [field for field in required if field not in state_payload]
        if missing:
            print(f"state missing fields: {', '.join(missing)}")
            return 1

        selected = state_payload.get("source_summary", {}).get("selected_state_path")
        expected_selected = expected_state_path().relative_to(REPO_ROOT).as_posix()
        if selected != expected_selected:
            print(f"unexpected selected state path: {selected}; expected {expected_selected}")
            return 1
    finally:
        process.terminate()
        try:
            process.wait(timeout=5)
        except subprocess.TimeoutExpired:
            process.kill()

    print("NOC visible execution layer validation passed.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
