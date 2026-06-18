from __future__ import annotations

import argparse
import asyncio
from pathlib import Path
from typing import Iterable

import uvicorn

from .config import DEFAULT_MODEL, load_local_env
from .frontend_server import serve_frontend
from .server import create_app


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Launch Desk developer entrypoint")
    subparsers = parser.add_subparsers(dest="command", required=False)

    backend = subparsers.add_parser("backend", help="Run the API server")
    backend.add_argument("--host", default="127.0.0.1")
    backend.add_argument("--port", type=int, default=8000)
    backend.add_argument("--reload", action="store_true")

    frontend = subparsers.add_parser("frontend", help="Run the static frontend server")
    frontend.add_argument("--host", default="127.0.0.1")
    frontend.add_argument("--port", type=int, default=3000)

    dev = subparsers.add_parser("dev", help="Run both frontend and backend servers")
    dev.add_argument("--host", default="127.0.0.1")
    dev.add_argument("--api-port", type=int, default=8000)
    dev.add_argument("--ui-port", type=int, default=3000)
    dev.add_argument("--reload", action="store_true")

    return parser


def _run_backend(host: str, port: int, reload: bool = False) -> None:
    uvicorn.run(
        "launch_desk.server:create_app",
        factory=True,
        host=host,
        port=port,
        reload=reload,
        log_level="info",
    )


def _run_dev(host: str, api_port: int, ui_port: int, reload: bool = False) -> None:
    import subprocess
    import sys

    python = sys.executable
    backend_cmd = [python, "-m", "launch_desk", "backend", "--host", host, "--port", str(api_port)]
    frontend_cmd = [python, "-m", "launch_desk", "frontend", "--host", host, "--port", str(ui_port)]
    if reload:
        backend_cmd.append("--reload")

    backend_proc = subprocess.Popen(backend_cmd)
    frontend_proc = subprocess.Popen(frontend_cmd)

    try:
        backend_proc.wait()
        frontend_proc.wait()
    finally:
        for proc in (backend_proc, frontend_proc):
            if proc.poll() is None:
                proc.terminate()


def main(argv: Iterable[str] | None = None) -> int:
    load_local_env()
    parser = build_parser()
    args = parser.parse_args(list(argv) if argv is not None else None)
    command = args.command or "dev"

    if command == "backend":
        _run_backend(args.host, args.port, reload=args.reload)
        return 0
    if command == "frontend":
        serve_frontend(host=args.host, port=args.port)
        return 0
    if command == "dev":
        _run_dev(args.host, args.api_port, args.ui_port, reload=args.reload)
        return 0

    parser.error(f"Unknown command: {command}")
    return 2
