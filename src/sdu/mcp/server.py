from __future__ import annotations

import json
import sys
from pathlib import Path

ROOTS = {
    "trace": Path("C:/CEO/sdu-control-plane/10_VALIDATION/TRACE_AUDIT_REGISTER_V52.json"),
    "anchor": Path("C:/CEO/sdu-control-plane/00_STATE/DATAVERSE_ANCHOR_STATE_V50.json"),
    "write_authority": Path(
        "C:/CEO/sdu-control-plane/19_WRITE_AUTHORITY/WRITE_AUTHORITY_REGISTRY.json"
    ),
    "noc": Path("C:/CEO/project-cdx/noc/operacion-en-vivo.json"),
    "bus": Path("C:/CEO/watchdog/bus/sdu-event-bus.jsonl"),
    "skills": Path("C:/CEO/project-cdx/.agents/skills"),
    "recipes": Path("C:/CEO/project-cdx/.agents/codex/matrices"),
    "agents": Path("C:/Users/enzo1/.codex/agents"),
}


TOOLS = [
    {"name": "sdu_trace_read", "description": "Read SDU trace register summary"},
    {"name": "sdu_dataverse_anchor_read", "description": "Read SDU Dataverse anchor summary"},
    {
        "name": "sdu_write_authority_read",
        "description": "Read SDU write authority registry summary",
    },
    {"name": "sdu_agent_list", "description": "List configured SDU agent TOML files"},
    {"name": "sdu_recipe_list", "description": "List SDU recipe matrix files"},
    {"name": "sdu_skill_list", "description": "List SDU skill directories"},
    {"name": "sdu_noc_state_read", "description": "Read SDU NOC local state summary"},
    {"name": "sdu_watchdog_tail", "description": "Read last SDU watchdog bus events"},
]


def _summary_json(path: Path) -> dict:
    if not path.exists():
        return {"exists": False, "path": str(path)}
    data = json.loads(path.read_text(encoding="utf-8-sig"))
    if isinstance(data, dict):
        return {
            "exists": True,
            "path": str(path),
            "keys": list(data)[:25],
            "status": data.get("status") or data.get("STATUS") or data.get("v88_status"),
        }
    return {"exists": True, "path": str(path), "type": type(data).__name__}


def _list_dir(path: Path, pattern: str = "*") -> dict:
    if not path.exists():
        return {"exists": False, "path": str(path), "items": []}
    return {"exists": True, "path": str(path), "items": [p.name for p in path.glob(pattern)][:200]}


def _watchdog_tail(limit: int = 5) -> dict:
    path = ROOTS["bus"]
    if not path.exists():
        return {"exists": False, "path": str(path), "events": []}
    lines = path.read_text(encoding="utf-8-sig", errors="ignore").splitlines()
    return {"exists": True, "path": str(path), "events": lines[-limit:]}


def call_tool(name: str, arguments: dict | None = None) -> dict:
    arguments = arguments or {}
    if name == "sdu_trace_read":
        return _summary_json(ROOTS["trace"])
    if name == "sdu_dataverse_anchor_read":
        return _summary_json(ROOTS["anchor"])
    if name == "sdu_write_authority_read":
        return _summary_json(ROOTS["write_authority"])
    if name == "sdu_agent_list":
        return _list_dir(ROOTS["agents"], "*.toml")
    if name == "sdu_recipe_list":
        return _list_dir(ROOTS["recipes"], "*.csv")
    if name == "sdu_skill_list":
        return _list_dir(ROOTS["skills"], "*")
    if name == "sdu_noc_state_read":
        return _summary_json(ROOTS["noc"])
    if name == "sdu_watchdog_tail":
        return _watchdog_tail(int(arguments.get("limit", 5)))
    raise ValueError(f"UNKNOWN_TOOL:{name}")


def _send(message: dict) -> None:
    sys.stdout.write(json.dumps(message, separators=(",", ":")) + "\n")
    sys.stdout.flush()


def handle(message: dict) -> dict | None:
    method = message.get("method")
    msg_id = message.get("id")
    if method == "initialize":
        return {
            "jsonrpc": "2.0",
            "id": msg_id,
            "result": {
                "protocolVersion": "2024-11-05",
                "capabilities": {"tools": {}},
                "serverInfo": {"name": "sdu-local-readonly", "version": "0.1.0"},
            },
        }
    if method == "tools/list":
        return {
            "jsonrpc": "2.0",
            "id": msg_id,
            "result": {
                "tools": [
                    {
                        "name": tool["name"],
                        "description": tool["description"],
                        "inputSchema": {
                            "type": "object",
                            "properties": {},
                            "additionalProperties": True,
                        },
                    }
                    for tool in TOOLS
                ]
            },
        }
    if method == "tools/call":
        params = message.get("params", {})
        name = params.get("name", "")
        args = params.get("arguments") or {}
        result = call_tool(name, args)
        return {
            "jsonrpc": "2.0",
            "id": msg_id,
            "result": {
                "content": [{"type": "text", "text": json.dumps(result, ensure_ascii=False)}]
            },
        }
    if method and method.startswith("notifications/"):
        return None
    return {
        "jsonrpc": "2.0",
        "id": msg_id,
        "error": {"code": -32601, "message": "Method not found"},
    }


def main() -> None:
    for line in sys.stdin:
        line = line.strip()
        if not line:
            continue
        try:
            response = handle(json.loads(line))
        except Exception as exc:  # noqa: BLE001 - MCP error envelope
            response = {
                "jsonrpc": "2.0",
                "id": None,
                "error": {"code": -32000, "message": str(exc)},
            }
        if response is not None:
            _send(response)


if __name__ == "__main__":
    main()
