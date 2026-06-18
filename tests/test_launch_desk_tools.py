from __future__ import annotations

from datetime import date

from launch_desk.tools import (
    check_launch_readiness_data,
    draft_launch_copy_data,
    extract_tasks_from_brief_data,
    identify_missing_details_data,
    generate_owner_checklist_data,
)


def test_identify_missing_details_flags_core_gaps() -> None:
    result = identify_missing_details_data(
        product_brief="Build a launch assistant",
        audience="everyone",
        launch_date=None,
        constraints=[],
        assets=[],
    )

    assert result["blocking_gaps"]
    assert any(item["blocking"] for item in result["questions"])


def test_readiness_rubric_scores_a_complete_brief_higher() -> None:
    result = check_launch_readiness_data(
        product_brief="Launch Desk helps teams plan launches with clear owners, risks, and copy.",
        audience="engineering leaders and PMs",
        launch_date=date.today(),
        constraints=["security review"],
        assets=["screenshots", "faq draft"],
    )

    assert 0 <= result["score"] <= 100
    assert result["rubric"]
    assert result["verdict"] in {"go", "go_with_risks", "hold"}


def test_extract_tasks_and_copy_are_structured() -> None:
    tasks = extract_tasks_from_brief_data(
        product_brief="Launch Desk helps teams plan launches.",
        audience="engineering leaders",
        launch_date=date.today(),
        constraints=["no downtime"],
        assets=["screenshots"],
    )
    copy_bundle = draft_launch_copy_data(
        product_brief="Launch Desk helps teams plan launches.",
        audience="engineering leaders",
        launch_date=date.today(),
        constraints=["no downtime"],
        assets=["screenshots"],
        channels=["Slack", "Email"],
    )
    checklist = generate_owner_checklist_data(
        product_brief="Launch Desk helps teams plan launches.",
        audience="engineering leaders",
        launch_date=date.today(),
        constraints=["no downtime"],
        assets=["screenshots"],
    )

    assert tasks["task_details"]
    assert copy_bundle["drafts"]
    assert checklist["items"]
