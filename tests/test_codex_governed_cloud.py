from __future__ import annotations

import json
from pathlib import Path

from projec_cdx_cloud.governed import GOVERNED_AGENTS, build_governed_cloud_report

from projec_cdx_cloud.cli import main as cloud_main


def test_governed_cloud_report_has_agent_contract() -> None:
    report = build_governed_cloud_report(event_name="unit-test")

    assert report["event"] == "unit-test"
    assert report["repo"] == "universo-rey/projec-cdx"
    assert report["frontera"]["external_writes"] is False
    assert report["frontera"]["live"] is False
    assert report["frontera"]["secrets"] is False
    assert [agent["agent"] for agent in report["agents"]] == [
        agent.name for agent in GOVERNED_AGENTS
    ]
    assert report["outputs"]["pr_comment"] == "DISABLED_BY_READ_ONLY_FRONTIER"


def test_governed_cloud_cli_writes_json_output(tmp_path: Path) -> None:
    output = tmp_path / "governed-report.json"

    result = cloud_main(["--governed-check", "--json", "--output", str(output)])

    assert result == 0
    payload = json.loads(output.read_text(encoding="utf-8"))
    assert payload["repo"] == "universo-rey/projec-cdx"
    assert payload["frontera"]["external_writes"] is False
    assert payload["outputs"]["artifact"] == "codex-governed-report"
