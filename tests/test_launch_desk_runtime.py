from __future__ import annotations

import asyncio
import json
from datetime import date

from launch_desk.config import resolve_model
from launch_desk.schemas import (
    LaunchDeskReport,
    LaunchDeskRequest,
    ReadinessRubricItem,
    ReadinessSummary,
)
from launch_desk.service import _public_error_message, run_launch_desk, stream_launch_desk
from launch_desk.store import get_cached_run_record, persist_run_record, request_cache_key


def _sample_request() -> LaunchDeskRequest:
    return LaunchDeskRequest(
        product_brief="Launch Desk helps engineering teams turn launch ideas into owner-led release plans.",
        audience="engineering leads",
        launch_date=date(2026, 6, 25),
        constraints=["security review"],
        assets=["release notes draft"],
    )


def _sample_report() -> LaunchDeskReport:
    return LaunchDeskReport(
        title="Launch Desk Plan",
        summary="A practical plan for an internal engineering launch.",
        assumptions=["Engineering has one accountable release owner."],
        follow_up_questions=[],
        prioritized_plan=[],
        risk_register=[],
        owner_checklist=[],
        launch_copy_suggestions=[],
        readiness=ReadinessSummary(
            score=88,
            verdict="go_with_risks",
            top_gaps=["Final security approval"],
            rubric=[
                ReadinessRubricItem(
                    dimension="approval", status="partial", notes="Security is pending."
                )
            ],
        ),
        next_action="Confirm the release owner and security approver.",
    )


def test_model_profiles_can_be_resolved(monkeypatch) -> None:
    monkeypatch.delenv("LAUNCH_DESK_MODEL", raising=False)

    assert resolve_model("fast") == "gpt-5.4-mini"
    assert resolve_model("nano") == "gpt-5.4-nano"
    assert resolve_model("unknown") == "gpt-5.5"


def test_history_cache_key_and_lookup(monkeypatch, tmp_path) -> None:
    history_path = tmp_path / "history.jsonl"

    import launch_desk.store as store

    monkeypatch.setattr(store, "HISTORY_PATH", history_path)
    request = _sample_request()
    report = _sample_report()

    record = persist_run_record(
        request_id="cached-run",
        created_at="2026-06-18T00:00:00Z",
        model="gpt-5.5",
        request=request,
        report=report,
    )

    assert record["cache_key"] == request_cache_key(request, model="gpt-5.5")
    assert get_cached_run_record(request, model="gpt-5.5")["request_id"] == "cached-run"
    assert get_cached_run_record(request, model="gpt-5.4-mini") is None


def test_stream_uses_cached_record_without_openai_call(monkeypatch, tmp_path) -> None:
    history_path = tmp_path / "history.jsonl"

    import launch_desk.service as service
    import launch_desk.store as store

    monkeypatch.setattr(store, "HISTORY_PATH", history_path)
    monkeypatch.setattr(service, "ENABLE_RESPONSE_CACHE", True)

    request = _sample_request()
    persist_run_record(
        request_id="cached-run",
        created_at="2026-06-18T00:00:00Z",
        model="gpt-5.5",
        request=request,
        report=_sample_report(),
    )

    async def collect_events() -> list[dict]:
        return [
            json.loads(line)
            async for line in stream_launch_desk(request, request_id="new-run", model="gpt-5.5")
        ]

    events = asyncio.run(collect_events())

    assert any(event.get("event_name") == "tool_progress" for event in events)
    assert any(event.get("event_name") == "cache_hit" for event in events)
    assert any(event.get("type") == "text_delta" for event in events)
    final = next(event for event in events if event.get("type") == "final")
    assert final["cached"] is True
    assert final["cached_from_request_id"] == "cached-run"


def test_non_stream_run_uses_cached_record(monkeypatch, tmp_path) -> None:
    history_path = tmp_path / "history.jsonl"

    import launch_desk.service as service
    import launch_desk.store as store

    monkeypatch.setattr(store, "HISTORY_PATH", history_path)
    monkeypatch.setattr(service, "ENABLE_RESPONSE_CACHE", True)

    request = _sample_request()
    persist_run_record(
        request_id="cached-run",
        created_at="2026-06-18T00:00:00Z",
        model="gpt-5.5",
        request=request,
        report=_sample_report(),
    )

    result = asyncio.run(run_launch_desk(request, request_id="new-run", model="gpt-5.5"))

    assert result.cached is True
    assert result.report.title == "Launch Desk Plan"


def test_public_error_messages_are_actionable() -> None:
    assert "too long" in _public_error_message(TimeoutError("deadline")).lower()
    assert "rate limits" in _public_error_message(RuntimeError("429 rate limit")).lower()
    assert "openai_api_key" in _public_error_message(RuntimeError("authentication failed")).lower()