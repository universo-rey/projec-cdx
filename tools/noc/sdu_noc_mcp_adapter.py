from __future__ import annotations

import argparse
import json
import sys
from typing import Any

import noc_api

VALID_RESOURCES = {"state", "alerts", "kpis", "decisions"}


def read_resource(resource: str) -> Any:
    state = noc_api.load_state()
    if resource == "state":
        return state
    if resource == "alerts":
        return state.get("alerts", [])
    if resource == "kpis":
        return state.get("kpis", {})
    if resource == "decisions":
        return state.get("decisions", [])
    raise ValueError(f"Unsupported resource: {resource}")


def smoke_payload() -> dict[str, Any]:
    state = noc_api.load_state()
    source_summary = state.get("source_summary") or {}
    return {
        "status": "PASS",
        "adapter": "sdu_noc_mcp_adapter",
        "mode": "read_only",
        "resources": sorted(VALID_RESOURCES),
        "selected_state_path": source_summary.get("selected_state_path"),
        "state_source_mode": source_summary.get("state_source_mode"),
        "has_global_status": isinstance(state.get("global_status"), dict),
        "alerts_count": len(state.get("alerts") or []),
        "decisions_count": len(state.get("decisions") or []),
        "writes_executed": False,
        "service_started": False,
        "secrets_read": False,
    }


def emit_json(payload: Any) -> None:
    print(json.dumps(payload, ensure_ascii=False, indent=2))


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Read-only SDU NOC adapter smoke and resource reader."
    )
    parser.add_argument(
        "--resource",
        choices=sorted(VALID_RESOURCES),
        help="Read a single NOC resource as JSON.",
    )
    parser.add_argument(
        "--smoke",
        action="store_true",
        help="Run a read-only adapter smoke check.",
    )
    return parser


def main(argv: list[str] | None = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)

    try:
        if args.smoke:
            emit_json(smoke_payload())
            return 0
        if args.resource:
            emit_json(read_resource(args.resource))
            return 0
        parser.error("one of --smoke or --resource is required")
    except Exception as exc:
        emit_json(
            {
                "status": "FAIL",
                "adapter": "sdu_noc_mcp_adapter",
                "mode": "read_only",
                "error": type(exc).__name__,
                "detail": str(exc),
                "writes_executed": False,
                "service_started": False,
                "secrets_read": False,
            }
        )
        return 1


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
