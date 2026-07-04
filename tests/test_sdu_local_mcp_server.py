from __future__ import annotations

from sdu.mcp import server


def test_sdu_local_mcp_initialize() -> None:
    response = server.handle({"jsonrpc": "2.0", "id": 1, "method": "initialize"})

    assert response is not None
    assert response["id"] == 1
    assert response["result"]["serverInfo"]["name"] == "sdu-local-readonly"


def test_sdu_local_mcp_lists_expected_tools() -> None:
    response = server.handle({"jsonrpc": "2.0", "id": 2, "method": "tools/list"})

    assert response is not None
    tools = {tool["name"] for tool in response["result"]["tools"]}
    assert {
        "sdu_agent_list",
        "sdu_dataverse_anchor_read",
        "sdu_noc_state_read",
        "sdu_watchdog_tail",
    } <= tools
