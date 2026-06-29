from __future__ import annotations

import argparse
import json
from http import HTTPStatus
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import urlparse


REPO_ROOT = Path(__file__).resolve().parents[2]
STATE_PATH = REPO_ROOT / "noc" / "state.json"
UI_ROOT = REPO_ROOT / "noc-web"


def load_state() -> dict:
    if not STATE_PATH.exists():
        raise FileNotFoundError(f"Missing NOC state: {STATE_PATH}")
    with STATE_PATH.open("r", encoding="utf-8") as state_file:
        return json.load(state_file)


def json_response(handler: BaseHTTPRequestHandler, status: HTTPStatus, payload: object) -> None:
    body = json.dumps(payload, ensure_ascii=False, indent=2).encode("utf-8")
    handler.send_response(status.value)
    handler.send_header("Content-Type", "application/json; charset=utf-8")
    handler.send_header("Cache-Control", "no-store")
    handler.send_header("Access-Control-Allow-Origin", "*")
    handler.send_header("Content-Length", str(len(body)))
    handler.end_headers()
    handler.wfile.write(body)


def static_response(handler: BaseHTTPRequestHandler, path: Path, content_type: str) -> None:
    body = path.read_bytes()
    handler.send_response(HTTPStatus.OK.value)
    handler.send_header("Content-Type", content_type)
    handler.send_header("Cache-Control", "no-store")
    handler.send_header("Content-Length", str(len(body)))
    handler.end_headers()
    handler.wfile.write(body)


class NocHandler(BaseHTTPRequestHandler):
    def do_GET(self) -> None:  # noqa: N802 - stdlib handler API
        route = urlparse(self.path).path.rstrip("/") or "/"
        try:
            if route == "/":
                return static_response(self, UI_ROOT / "index.html", "text/html; charset=utf-8")
            if route == "/app.js":
                return static_response(self, UI_ROOT / "app.js", "application/javascript; charset=utf-8")
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
            return json_response(self, HTTPStatus.SERVICE_UNAVAILABLE, {"error": "state_missing", "detail": str(exc)})
        except json.JSONDecodeError as exc:
            return json_response(self, HTTPStatus.INTERNAL_SERVER_ERROR, {"error": "state_invalid", "detail": str(exc)})

    def log_message(self, format: str, *args: object) -> None:
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
