from __future__ import annotations

from datetime import date
from pathlib import Path

from fastapi.testclient import TestClient

from launch_desk.server import create_app


def test_health_endpoint_reports_model_and_key_state(monkeypatch) -> None:
    monkeypatch.setenv("OPENAI_API_KEY", "test-key")
    app = create_app()
    client = TestClient(app)

    response = client.get("/api/health")

    assert response.status_code == 200
    payload = response.json()
    assert payload["status"] == "ok"
    assert "model" in payload
    assert payload["openai_api_key_present"] is True


def test_history_endpoint_lists_saved_runs(monkeypatch, tmp_path: Path) -> None:
    history_path = tmp_path / "history.jsonl"
    monkeypatch.setenv("OPENAI_API_KEY", "test-key")
    monkeypatch.setenv("LAUNCH_DESK_HISTORY_PATH", str(history_path))

    import launch_desk.store as store

    store.HISTORY_PATH = history_path

    app = create_app()
    client = TestClient(app)

    from launch_desk.schemas import LaunchDeskReport, LaunchDeskRequest, ReadinessRubricItem, ReadinessSummary

    request = LaunchDeskRequest(
        product_brief="Launch Desk helps teams plan launches with owner checklists and risk control.",
        audience="engineering leads",
        launch_date=date(2026, 6, 25),
        constraints=["security review"],
        assets=["screenshots"],
    )
    report = LaunchDeskReport(
        title="Launch Desk v1 Internal Launch Plan",
        summary="Ready to proceed.",
        assumptions=["a"],
        follow_up_questions=[],
        prioritized_plan=[],
        risk_register=[],
        owner_checklist=[],
        launch_copy_suggestions=[],
        readiness=ReadinessSummary(
            score=90,
            verdict="go",
            top_gaps=["timing"],
            rubric=[ReadinessRubricItem(dimension="brief clarity", status="ready", notes="ok")],
        ),
        next_action="Ship it.",
    )

    from launch_desk.store import persist_run_record

    persist_run_record(
        request_id="abc123",
        created_at="2026-06-18T00:00:00Z",
        model="gpt-5.5",
        request=request,
        report=report,
    )

    response = client.get("/api/history?limit=5")
    assert response.status_code == 200
    data = response.json()
    assert data["items"][0]["request_id"] == "abc123"

    detail = client.get("/api/history/abc123")
    assert detail.status_code == 200
    assert detail.json()["request_id"] == "abc123"


def test_history_filters_and_exports(monkeypatch, tmp_path: Path) -> None:
    history_path = tmp_path / "history.jsonl"
    monkeypatch.setenv("OPENAI_API_KEY", "test-key")
    monkeypatch.setenv("LAUNCH_DESK_HISTORY_PATH", str(history_path))

    import launch_desk.store as store

    store.HISTORY_PATH = history_path

    app = create_app()
    client = TestClient(app)

    from launch_desk.schemas import LaunchDeskReport, LaunchDeskRequest, ReadinessRubricItem, ReadinessSummary
    from launch_desk.store import persist_run_record

    common_report = dict(
        title="Launch Desk v1 Internal Launch Plan",
        summary="Ready to proceed.",
        assumptions=["a"],
        follow_up_questions=[],
        prioritized_plan=[],
        risk_register=[],
        owner_checklist=[],
        launch_copy_suggestions=[],
        readiness=ReadinessSummary(
            score=90,
            verdict="go",
            top_gaps=["timing"],
            rubric=[ReadinessRubricItem(dimension="brief clarity", status="ready", notes="ok")],
        ),
        next_action="Ship it.",
    )

    persist_run_record(
        request_id="abc123",
        created_at="2026-06-18T00:00:00Z",
        model="gpt-5.5",
        request=LaunchDeskRequest(
            product_brief="Launch Desk helps teams plan launches with owner checklists and risk control.",
            audience="engineering leads",
            launch_date=date(2026, 6, 25),
            constraints=["security review"],
            assets=["screenshots"],
        ),
        report=LaunchDeskReport(**common_report),
    )

    persist_run_record(
        request_id="def456",
        created_at="2026-06-18T00:01:00Z",
        model="gpt-5.5",
        request=LaunchDeskRequest(
            product_brief="A separate internal rollout for support and operations.",
            audience="support operations",
            launch_date=date(2026, 7, 1),
            constraints=["training required"],
            assets=["faq draft"],
        ),
        report=LaunchDeskReport(
            **{
                **common_report,
                "summary": "Proceed with care.",
                "readiness": ReadinessSummary(
                    score=45,
                    verdict="hold",
                    top_gaps=["signoff"],
                    rubric=[ReadinessRubricItem(dimension="brief clarity", status="partial", notes="needs work")],
                ),
            }
        ),
    )

    filtered = client.get("/api/history?query=ready&verdict=go")
    assert filtered.status_code == 200
    filtered_items = filtered.json()["items"]
    assert len(filtered_items) == 1
    assert filtered_items[0]["request_id"] == "abc123"

    markdown = client.get("/api/history/abc123/export?format=markdown")
    assert markdown.status_code == 200
    assert markdown.headers["content-type"].startswith("text/markdown")
    assert "# Launch Desk v1 Internal Launch Plan" in markdown.text
    assert "Request ID" in markdown.text

    export_json = client.get("/api/history/abc123/export?format=json")
    assert export_json.status_code == 200
    assert export_json.json()["request_id"] == "abc123"
