from __future__ import annotations

import argparse
import asyncio
import json
import os
from pathlib import Path
from typing import Iterable

from .agent import DEFAULT_MODEL, align_runtime_context, build_sdu_agents, run_agent, smoke_report


ROOT = Path(__file__).resolve().parents[2]


def load_env_file(path: Path) -> None:
    if not path.exists():
        return
    for raw_line in path.read_text(encoding="utf-8").splitlines():
        line = raw_line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, value = line.split("=", 1)
        key = key.strip()
        value = value.strip().strip('"').strip("'")
        if key and key not in os.environ:
            os.environ[key] = value


def load_local_env() -> None:
    for candidate in (ROOT / ".env", ROOT / ".env.local"):
        load_env_file(candidate)


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="PROJEC CDX Codex Cloud runner")
    parser.add_argument(
        "--smoke",
        action="store_true",
        help="Show a metadata-only smoke report without calling the API",
    )
    parser.add_argument(
        "--prompt",
        default="Resume el estado del carril Codex Cloud con energia atomica.",
        help="Prompt to send to the agent when not running smoke mode.",
    )
    parser.add_argument(
        "--model",
        default=os.environ.get("OPENAI_MODEL", DEFAULT_MODEL),
        help="OpenAI model name for live runs.",
    )
    parser.add_argument(
        "--json",
        action="store_true",
        help="Emit JSON instead of plain text.",
    )
    parser.add_argument(
        "--activate-sdu",
        action="store_true",
        help="Build the six SDK-SDU agents and report them as active in the local runtime.",
    )
    return parser


def _print_json(payload: dict[str, object]) -> None:
    print(json.dumps(payload, indent=2, ensure_ascii=False))


def main(argv: Iterable[str] | None = None) -> int:
    load_local_env()
    align_runtime_context()
    parser = build_parser()
    args = parser.parse_args(list(argv) if argv is not None else None)

    if args.smoke:
        report = smoke_report()
        if args.json:
            _print_json(report)
        else:
            for key, value in report.items():
                print(f"{key}: {value}")
        return 0

    if args.activate_sdu:
        agents = build_sdu_agents(model=args.model)
        payload = {
            "status": "activated",
            "model": args.model,
            "count": len(agents),
            "agents": list(agents.keys()),
            "gate": os.environ.get("CODEX_CLOUD_GATE", "metadata-only"),
        }
        if args.json:
            _print_json(payload)
        else:
            print(f"status: {payload['status']}")
            print(f"model: {payload['model']}")
            print(f"count: {payload['count']}")
            print(f"agents: {', '.join(payload['agents'])}")
            print(f"gate: {payload['gate']}")
        return 0

    result = asyncio.run(run_agent(args.prompt, model=args.model))
    payload = {
        "status": "ok",
        "model": result.model,
        "prompt": result.prompt,
        "final_output": result.final_output,
    }
    if args.json:
        _print_json(payload)
    else:
        print(result.final_output)
    return 0
