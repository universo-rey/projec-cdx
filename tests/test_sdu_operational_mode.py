from tools import sdu_operational_mode as mode


def test_operational_mode_risk_blocks_main_impact() -> None:
    risk = mode.classify_risk("push canonical baseline to main")

    assert risk["state"] == "REQUIRES_CONFIRMATION"
    assert "main_impact" in risk["flags"]


def test_operational_mode_allows_regular_trace() -> None:
    risk = mode.classify_risk("summarize latest local evidence")

    assert risk == {"state": "AUTO_TRACE_ALLOWED", "flags": []}


def test_live_panel_contains_required_status_fields() -> None:
    timestamp = "2026-06-28T00:00:00Z"
    threads = [
        {"area": "repos", "agent": "repo-agent", "status": "PASS", "observations": {}},
        {
            "area": "governance",
            "agent": "governance-agent",
            "status": "PASS",
            "observations": {},
        },
    ]

    panel = mode.build_live_panel(
        timestamp=timestamp,
        intent="operational_mode_activation",
        tipo_operacion="operational_mode_activation",
        resultado="SDU_OPERATIONAL_MODE_ACTIVE",
        impacto="trace_auto_noc_live_swarm_always_on",
        origen="codex-chat",
        threads=threads,
        risk={"state": "AUTO_TRACE_ALLOWED", "flags": []},
        intelligence_state={},
    )

    assert panel["panel"] == "Operación en Vivo"
    assert panel["ultima_orden"]["timestamp"] == timestamp
    assert panel["estado_sistema"]["trace"] == "ACTIVE"
    assert panel["estado_sistema"]["swarm"] == "ACTIVE"


def test_live_panel_promotes_postcheck_warning_to_alerts() -> None:
    panel = mode.build_live_panel(
        timestamp="2026-06-28T00:00:00Z",
        intent="operational_mode_activation",
        tipo_operacion="post_validation",
        resultado="SDU_OPERATIONAL_MODE_ACTIVE",
        impacto="project_validate_ok_operational_chain_external_csv_missing",
        origen="codex-chat",
        threads=[],
        risk={"state": "AUTO_TRACE_ALLOWED", "flags": []},
        intelligence_state={},
    )

    assert panel["alertas"] == [
        {
            "area": "postcheck",
            "status": "OBSERVED",
            "detail": "project_validate_ok_operational_chain_external_csv_missing",
        }
    ]
