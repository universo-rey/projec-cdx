from __future__ import annotations

import argparse
import json
import sdu_noc_mcp_adapter as adapter
import sys
from typing import Any

from mcp.server.fastmcp import FastMCP


SERVER_NAME = "sdu_noc"
RESOURCE_URIS = {
    "state": "sdu-noc://state",
    "alerts": "sdu-noc://alerts",
    "kpis": "sdu-noc://kpis",
    "decisions": "sdu-noc://decisions",
}

mcp = FastMCP(
    SERVER_NAME,
    instructions=(
        "Read-only SDU NOC MCP server. Exposes NOC state, alerts, KPIs, "
        "and decisions without writing files, starting services, binding "
        "ports, or reading secrets."
    ),
)


def _json_text(payload: Any) -> str:
    return json.dumps(payload, ensure_ascii=False, indent=2, sort_keys=True)


def _read_json_text(resource: str) -> str:
    return _json_text(adapter.read_resource(resource))


@mcp.resource(
    RESOURCE_URIS["state"],
    name="state",
    title="SDU NOC state",
    description="Full read-only SDU NOC state payload.",
    mime_type="application/json",
)
def read_state_resource() -> str:
    return _read_json_text("state")


@mcp.resource(
    RESOURCE_URIS["alerts"],
    name="alerts",
    title="SDU NOC alerts",
    description="Read-only SDU NOC alerts.",
    mime_type="application/json",
)
def read_alerts_resource() -> str:
    return _read_json_text("alerts")


@mcp.resource(
    RESOURCE_URIS["kpis"],
    name="kpis",
    title="SDU NOC KPIs",
    description="Read-only SDU NOC KPI payload.",
    mime_type="application/json",
)
def read_kpis_resource() -> str:
    return _read_json_text("kpis")


@mcp.resource(
    RESOURCE_URIS["decisions"],
    name="decisions",
    title="SDU NOC decisions",
    description="Read-only SDU NOC decisions.",
    mime_type="application/json",
)
def read_decisions_resource() -> str:
    return _read_json_text("decisions")


@mcp.tool(
    name="get_state",
    title="Get SDU NOC state",
    description="Return the full SDU NOC state as read-only JSON data.",
)
def get_state() -> dict[str, Any]:
    return adapter.read_resource("state")


@mcp.tool(
    name="get_alerts",
    title="Get SDU NOC alerts",
    description="Return SDU NOC alerts as read-only JSON data.",
)
def get_alerts() -> list[Any]:
    return adapter.read_resource("alerts")


@mcp.tool(
    name="get_kpis",
    title="Get SDU NOC KPIs",
    description="Return SDU NOC KPIs as read-only JSON data.",
)
def get_kpis() -> dict[str, Any]:
    return adapter.read_resource("kpis")


@mcp.tool(
    name="get_decisions",
    title="Get SDU NOC decisions",
    description="Return SDU NOC decisions as read-only JSON data.",
)
def get_decisions() -> list[Any]:
    return adapter.read_resource("decisions")


def smoke_payload() -> dict[str, Any]:
    adapter_smoke = adapter.smoke_payload()
    resources = sorted(adapter.VALID_RESOURCES)
    resource_read_checks = {
        resource: adapter.read_resource(resource) is not None for resource in resources
    }
    return {
        "status": "PASS",
        "server": "sdu_noc_mcp_server",
        "transport": "stdio",
        "mode": "read_only",
        "resources": resources,
        "resource_uris": {resource: RESOURCE_URIS[resource] for resource in resources},
        "tools": ["get_alerts", "get_decisions", "get_kpis", "get_state"],
        "adapter_smoke_status": adapter_smoke.get("status"),
        "resource_read_checks": resource_read_checks,
        "writes_executed": False,
        "service_started": False,
        "port_bound": False,
        "secrets_read": False,
    }


def emit_json(payload: Any) -> None:
    print(json.dumps(payload, ensure_ascii=False, indent=2, sort_keys=True))


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Read-only stdio MCP server for SDU NOC resources."
    )
    parser.add_argument(
        "--smoke",
        action="store_true",
        help="Run a read-only smoke check without starting the MCP server.",
    )
    return parser


def main(argv: list[str] | None = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)

    try:
        if args.smoke:
            emit_json(smoke_payload())
            return 0
        mcp.run(transport="stdio")
        return 0
    except Exception as exc:
        emit_json(
            {
                "status": "FAIL",
                "server": "sdu_noc_mcp_server",
                "transport": "stdio",
                "mode": "read_only",
                "error": type(exc).__name__,
                "detail": str(exc),
                "writes_executed": False,
                "service_started": False,
                "port_bound": False,
                "secrets_read": False,
            }
        )
        return 1


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
