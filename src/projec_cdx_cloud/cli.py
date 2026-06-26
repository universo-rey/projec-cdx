from __future__ import annotations

import argparse
import asyncio
import json
import os
from collections.abc import Iterable
from pathlib import Path

from .agent import DEFAULT_MODEL, align_runtime_context, build_sdu_agents, run_agent, smoke_report
from .cloud_bridge import cloud_bridge_packet, run_cloud_bridge_agent, write_cloud_bridge_readback
from .governed import build_governed_cloud_report, write_governed_cloud_report

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
        "--no-local-env",
        action="store_true",
        help="Do not load .env or .env.local before running this command.",
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
        "--governed-check",
        action="store_true",
        help="Run governed cloud readiness checks without external writes or API calls.",
    )
    parser.add_argument(
        "--output",
        type=Path,
        default=None,
        help="Optional JSON output path for governed cloud reports.",
    )
    parser.add_argument(
        "--write-readback",
        action="store_true",
        help="Write a local readback for cloud bridge mode.",
    )
    return parser


def _print_json(payload: dict[str, object]) -> None:
    print(json.dumps(payload, indent=2, ensure_ascii=False))


def main(argv: Iterable[str] | None = None) -> int:
    parser = build_parser()
    args = parser.parse_args(list(argv) if argv is not None else None)
    local_only_mode = args.smoke or args.activate_sdu or args.cloud_bridge or args.governed_check
    if not args.no_local_env and not local_only_mode:
        load_local_env()
    align_runtime_context()

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

    if args.governed_check:
        packet = (
            write_governed_cloud_report(args.output)
            if args.output
            else build_governed_cloud_report()
        )
        if args.json:
            _print_json(packet)
        else:
            print(f"status: {packet['status']}")
            print(f"event: {packet['event']}")
            print(f"snapshot_gate: {packet['snapshot_gate']['status']}")
            print(f"agents: {len(packet['agents'])}")
            print(f"external_writes: {packet['frontera']['external_writes']}")
            if "path" in packet:
                print(f"path: {packet['path']}")
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
