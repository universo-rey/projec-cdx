from __future__ import annotations

import json
import subprocess
import sys
import time
from pathlib import Path
from urllib.request import urlopen

REPO_ROOT = Path(__file__).resolve().parents[2]
STATE_PATH = REPO_ROOT / "noc" / "state.json"
SCHEMA_PATH = REPO_ROOT / "noc" / "schema.json"
INDEX_PATH = REPO_ROOT / "noc" / "index.json"
APP_PATH = REPO_ROOT / "noc-web" / "app.js"
API_PATH = REPO_ROOT / "tools" / "noc" / "noc_api.py"


def read_json(path: Path) -> object:
    with path.open("r", encoding="utf-8") as file:
        return json.load(file)


def fetch_json(path: str) -> object:
    with urlopen(f"http://127.0.0.1:8787{path}", timeout=5) as response:
        return json.loads(response.read().decode("utf-8"))


def main() -> int:
    for path in [STATE_PATH, SCHEMA_PATH, INDEX_PATH, APP_PATH, API_PATH]:
        if not path.exists():
            print(f"missing: {path}")
            return 1

    state = read_json(STATE_PATH)
    read_json(SCHEMA_PATH)
    read_json(INDEX_PATH)

    required = ["global_status", "alerts", "decisions", "kpis", "runtime", "timeline", "updated_at", "source_summary"]
    missing = [field for field in required if field not in state]
    if missing:
        print(f"state missing fields: {', '.join(missing)}")
        return 1

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
        for endpoint, expected_type in checks.items():
            payload = fetch_json(endpoint)
            if not isinstance(payload, expected_type):
                print(f"unexpected payload type for {endpoint}: {type(payload).__name__}")
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
