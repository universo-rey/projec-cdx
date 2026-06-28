from __future__ import annotations

import argparse
import asyncio
import json
import os
from collections.abc import Iterable
from pathlib import Path

from .agent import DEFAULT_MODEL, align_runtime_context, build_sdu_agents, run_agent, smoke_report
from .cloud_bridge import cloud_bridge_packet, run_cloud_bridge_agent, write_cloud_bridge_readback
from .runtime import runtime_sentinel_report, runtime_status_report

ROOT = Path(__file__).parents[2]


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
    parser.add_argument(
        "--cloud-bridge",
        action="store_true",
        help="Build a governed Codex Cloud smoke packet without creating a Cloud task.",
    )
    parser.add_argument(
        "--agentic-cloud-bridge",
        action="store_true",
        help="Use Agents SDK to review the governed Codex Cloud smoke packet.",
    )
    parser.add_argument(
        "--write-readback",
        action="store_true",
        help="Write a local readback for cloud bridge mode.",
    )

    runtime_parser = parser.add_subparsers(dest="command")
    runtime = runtime_parser.add_parser(
        "runtime",
        help="Read-only runtime wrappers for status and sentinel views.",
    )
    runtime_subparsers = runtime.add_subparsers(dest="runtime_command")
    runtime_status = runtime_subparsers.add_parser(
        "status", help="Show the read-only runtime status wrapper."
    )
    runtime_status.add_argument("--json", action="store_true", help="Emit JSON instead of text.")
    runtime_sentinel = runtime_subparsers.add_parser(
        "sentinel", help="Show the read-only runtime sentinel wrapper."
    )
    runtime_sentinel.add_argument("--json", action="store_true", help="Emit JSON instead of text.")
    return parser


def _print_json(payload: dict[str, object]) -> None:
    print(json.dumps(payload, indent=2, ensure_ascii=True))


def _print_runtime_text(payload: dict[str, object]) -> None:
    print(f"status: {payload.get('status')}")
    print(f"wrapper: {payload.get('wrapper')}")
    print(f"live_write_touched: {payload.get('live_write_touched')}")
    if "org_total_runner" in payload and isinstance(payload["org_total_runner"], dict):
        org_total = payload["org_total_runner"]
        print(f"selected_root: {org_total.get('selected_root')}")
        print(f"declared_runner_root: {org_total.get('declared_runner_root')}")
    if payload.get("next_safe_task"):
        print(f"next_safe_task: {payload.get('next_safe_task')}")


def main(argv: Iterable[str] | None = None) -> int:
    load_local_env()
    align_runtime_context()
    parser = build_parser()
    args = parser.parse_args(list(argv) if argv is not None else None)

    if getattr(args, "command", None) == "runtime":
        runtime_command = getattr(args, "runtime_command", None)
        if runtime_command == "status":
            payload = runtime_status_report()
        elif runtime_command == "sentinel":
            payload = runtime_sentinel_report()
        else:
            parser.error("runtime requires one of: status, sentinel")
        if args.json:
            _print_json(payload)
        else:
            _print_runtime_text(payload)
        return 0

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

    if args.cloud_bridge:
        packet = cloud_bridge_packet()
        if args.write_readback:
            output_path = write_cloud_bridge_readback(packet)
            packet["readback_path"] = str(output_path)
        if args.json:
            _print_json(packet)
        else:
            print(f"status: {packet['status']}")
            print(f"remote_branch_found: {packet['checks']['remote_branch_found']}")
            print(f"context_ok: {packet['checks']['context_ok']}")
            print(f"sdu_agents_defined: {packet['checks']['sdu_agents_defined']}")
            print(f"next_delta: {packet['next_delta']}")
            if "readback_path" in packet:
                print(f"readback_path: {packet['readback_path']}")
        return 0

    if args.agentic_cloud_bridge:
        final_output = asyncio.run(
            run_cloud_bridge_agent(
                args.prompt
                or "Revisa el puente Codex Cloud y devuelve PASS/OBSERVED/FAIL con proximo delta unico.",
                model=args.model,
            )
        )
        payload = {"status": "ok", "model": args.model, "final_output": final_output}
        if args.json:
            _print_json(payload)
        else:
            print(final_output)
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
