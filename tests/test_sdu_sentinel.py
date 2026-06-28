from __future__ import annotations

import json
from pathlib import Path

from tools import sdu_sentinel


def test_sentinel_loads_config_and_boundary() -> None:
    assert sdu_sentinel.load_config()["sentinel_id"] == "SDU_SENTINEL_LAYER"
    assert sdu_sentinel.load_boundary()["default_mode"] == "NO_EXTERNAL"


def test_guard_allows_local_action() -> None:
    decision = sdu_sentinel.guard("local", "test", None, None, None, None, None)
    assert decision["decision"] == "ALLOWED_LOCAL"


def test_guard_blocks_github_without_gate() -> None:
    decision = sdu_sentinel.guard("github", "push", None, None, None, None, None)
    assert decision["decision"] == "BLOCKED_WITHOUT_GATE"


def test_guard_blocks_microsoft_without_gate() -> None:
    decision = sdu_sentinel.guard("microsoft", "sharepoint_write", None, None, None, None, None)
    assert decision["decision"] == "BLOCKED_WITHOUT_GATE"


def test_gate_incomplete_blocks_external_action() -> None:
    decision = sdu_sentinel.guard(
        "github", "workflow_dispatch", "GATE-1", "owner", None, "postcheck", "evidence"
    )
    assert decision["decision"] == "GATE_INCOMPLETE_BLOCKED"
    assert "rollback" in decision["reason"]


def test_drift_classifier_detects_critical_files() -> None:
    assert (
        sdu_sentinel.classify_status_lines([" M tools/sdu_boot.ps1"]) == "UNEXPECTED_RUNTIME_DRIFT"
    )
    assert (
        sdu_sentinel.classify_status_lines([" M operativa/SDU_RUNTIME_BOUNDARY_MATRIX.json"])
        == "BOUNDARY_POLICY_DRIFT"
    )
    assert sdu_sentinel.classify_status_lines([" M index.json"]) == "EXPECTED_INDEX_REFRESH"
    assert sdu_sentinel.classify_status_lines([]) == "NO_DRIFT"


def test_governed_local_residual_filter_keeps_tracked_runtime_drift() -> None:
    filtered = sdu_sentinel._filter_governed_local_residuals(
        [
            "?? .agents/",
            "?? web/",
            " M tools/sdu_boot.ps1",
        ]
    )

    assert filtered == [" M tools/sdu_boot.ps1"]
    assert sdu_sentinel.classify_status_lines(filtered) == "UNEXPECTED_RUNTIME_DRIFT"


def test_event_jsonl_valid_and_secret_free(tmp_path: Path) -> None:
    event_path = tmp_path / "events.jsonl"
    event = sdu_sentinel.make_event(
        category="BOUNDARY",
        severity="INFO",
        decision="BLOCK",
        surface="github",
        evidence=["guard"],
        notes="blocked_without_gate",
    )
    sdu_sentinel.append_event(event, event_path)
    parsed = json.loads(event_path.read_text(encoding="utf-8"))
    assert parsed["surface"] == "github"
    assert "TOKEN" not in event_path.read_text(encoding="utf-8")


def test_scan_reports_boundary_present() -> None:
    payload = sdu_sentinel.scan()
    names = {check["name"]: check for check in payload["checks"]}
    assert names["boundary_matrix_present"]["status"] == "PASS"


def test_blocked_pattern_scan_skips_generated_outputs_and_tasks(tmp_path: Path) -> None:
    placeholder_token = "DEV_AUTH_" + "PLACEHOLDER_ONLY"
    (tmp_path / "outputs" / "suite").mkdir(parents=True)
    (tmp_path / "operativa" / "tasks" / "20260623").mkdir(parents=True)
    (tmp_path / "tools").mkdir(parents=True)
    (tmp_path / "outputs" / "suite" / "event.json").write_text(
        f'{{"token":"{placeholder_token}"}}',
        encoding="utf-8",
    )
    (tmp_path / "operativa" / "tasks" / "20260623" / "event.json").write_text(
        f'{{"token":"{placeholder_token}"}}',
        encoding="utf-8",
    )
    config = {"blocked_patterns": [placeholder_token]}

    assert sdu_sentinel._scan_blocked_patterns(config, tmp_path) == []

    (tmp_path / "tools" / "active.json").write_text(
        f'{{"token":"{placeholder_token}"}}',
        encoding="utf-8",
    )

    assert sdu_sentinel._scan_blocked_patterns(config, tmp_path) == ["tools/active.json"]
