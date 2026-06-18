from __future__ import annotations

from dataclasses import dataclass
from datetime import date, datetime
from zoneinfo import ZoneInfo
from typing import Any

from agents import function_tool

LOCAL_TZ = ZoneInfo("America/Argentina/Salta")


def _normalize_lines(values: list[str] | None) -> list[str]:
    if not values:
        return []

    items: list[str] = []
    for value in values:
        for chunk in value.replace("\r", "\n").split("\n"):
            chunk = chunk.strip(" -\t")
            if chunk:
                items.append(chunk)
    return items


def _unique(items: list[str]) -> list[str]:
    seen: set[str] = set()
    ordered: list[str] = []
    for item in items:
        key = item.strip().lower()
        if not key or key in seen:
            continue
        seen.add(key)
        ordered.append(item.strip())
    return ordered


def _contains(text: str, *needles: str) -> bool:
    lowered = text.lower()
    return any(needle.lower() in lowered for needle in needles)


def _days_until(launch_date: date | None) -> int | None:
    if launch_date is None:
        return None
    today = datetime.now(tz=LOCAL_TZ).date()
    return (launch_date - today).days


def identify_missing_details_data(
    *,
    product_brief: str,
    audience: str,
    launch_date: date | None,
    constraints: list[str] | None = None,
    assets: list[str] | None = None,
) -> dict[str, Any]:
    constraints = _normalize_lines(constraints)
    assets = _normalize_lines(assets)

    questions: list[dict[str, Any]] = []
    assumptions: list[str] = []
    blocking: list[str] = []

    if len(product_brief.strip()) < 40:
        questions.append(
            {
                "question": "What is the product name and the one-line user value we should anchor the launch on?",
                "why_it_matters": "A short brief leaves the launch message too vague to prioritize work or draft copy.",
                "blocking": True,
            }
        )
        blocking.append("brief is too short")
    else:
        assumptions.append("The product brief is detailed enough to infer scope.")

    if len(audience.strip()) < 6 or audience.lower() in {"everyone", "users", "customers"}:
        questions.append(
            {
                "question": "Who is the primary launch audience and who is secondary?",
                "why_it_matters": "Audience drives copy, sequencing, and which owners need to review the plan.",
                "blocking": True,
            }
        )
        blocking.append("audience is underspecified")
    else:
        assumptions.append(f"Primary audience is {audience.strip()!r}.")

    if launch_date is None:
        questions.append(
            {
                "question": "What launch date or window are we targeting?",
                "why_it_matters": "The launch date drives QA, approvals, comms, and rollback timing.",
                "blocking": True,
            }
        )
        blocking.append("launch date missing")
    else:
        assumptions.append(f"Launch date is {launch_date.isoformat()}.")

    if not constraints:
        questions.append(
            {
                "question": "Any constraints we should treat as hard stops, like legal, security, pricing, or platform limits?",
                "why_it_matters": "Constraints change the order of work and can turn a go decision into a hold.",
                "blocking": False,
            }
        )
    if not assets:
        questions.append(
            {
                "question": "Which launch assets already exist, and which ones still need to be created?",
                "why_it_matters": "Assets determine whether the launch is ready to announce or still needs packaging work.",
                "blocking": False,
            }
        )

    return {
        "questions": questions,
        "assumptions": assumptions,
        "blocking_gaps": blocking,
    }


def extract_tasks_from_brief_data(
    *,
    product_brief: str,
    audience: str,
    launch_date: date | None,
    constraints: list[str] | None = None,
    assets: list[str] | None = None,
) -> dict[str, Any]:
    constraints = _normalize_lines(constraints)
    assets = _normalize_lines(assets)
    missing = identify_missing_details_data(
        product_brief=product_brief,
        audience=audience,
        launch_date=launch_date,
        constraints=constraints,
        assets=assets,
    )

    tasks: list[dict[str, Any]] = [
        {
            "priority": 1,
            "owner": "PM",
            "action": "Lock the launch scope and success criteria.",
            "reason": "The team needs one source of truth before scheduling execution work.",
        },
        {
            "priority": 2,
            "owner": "Engineering",
            "action": "Confirm the last integration, QA, and release branch dependencies.",
            "reason": "Release blockers usually surface in late integration or environment drift.",
        },
        {
            "priority": 3,
            "owner": "Design",
            "action": "Verify the launch narrative, screenshots, and in-product surfaces.",
            "reason": "Audience clarity and asset quality determine whether the launch feels ready.",
        },
        {
            "priority": 4,
            "owner": "Marketing",
            "action": "Draft channel-specific launch copy and timing.",
            "reason": "Copy should match audience, tone, and whether the launch is public or internal.",
        },
        {
            "priority": 5,
            "owner": "Support",
            "action": "Prepare FAQ, escalation paths, and known-issue responses.",
            "reason": "Support readiness is the fastest way to reduce launch friction.",
        },
        {
            "priority": 6,
            "owner": "QA",
            "action": "Run the readiness rubric and verify rollback criteria.",
            "reason": "A launch without a rollback path is still a risk, not a plan.",
        },
    ]

    if launch_date is None or _days_until(launch_date) is not None and _days_until(launch_date) <= 7:
        tasks.insert(
            1,
            {
                "priority": 1,
                "owner": "PM",
                "action": "Confirm the exact launch window and decision owner.",
                "reason": "Near-term launches need a decision point and a named approver.",
            },
        )

    lower_brief = product_brief.lower()
    if _contains(lower_brief, "security", "privacy", "legal", "compliance"):
        tasks.append(
            {
                "priority": 2,
                "owner": "Security / Legal",
                "action": "Review the release for policy, privacy, and compliance risks.",
                "reason": "Sensitive launches should not rely on last-minute approval assumptions.",
            }
        )

    if _contains(lower_brief, "beta", "experimental", "pilot", "rollout", "phased"):
        tasks.append(
            {
                "priority": 2,
                "owner": "Engineering",
                "action": "Define the rollout sequence and rollback thresholds.",
                "reason": "Phased launches need explicit stop conditions and blast-radius control.",
            }
        )

    if not assets:
        tasks.append(
            {
                "priority": 3,
                "owner": "Design / Marketing",
                "action": "Assemble or create the missing launch assets.",
                "reason": "Copy and visuals should not block the release the day of launch.",
            }
        )

    if constraints:
        tasks.append(
            {
                "priority": 4,
                "owner": "Program Lead",
                "action": "Work through the stated constraints one by one.",
                "reason": "Constraints often become the hidden critical path if they are not assigned early.",
            }
        )

    return {
        "tasks": _unique([task["action"] for task in tasks]),
        "task_details": tasks,
        "missing_details": missing,
    }


def check_launch_readiness_data(
    *,
    product_brief: str,
    audience: str,
    launch_date: date | None,
    constraints: list[str] | None = None,
    assets: list[str] | None = None,
) -> dict[str, Any]:
    constraints = _normalize_lines(constraints)
    assets = _normalize_lines(assets)
    missing = identify_missing_details_data(
        product_brief=product_brief,
        audience=audience,
        launch_date=launch_date,
        constraints=constraints,
        assets=assets,
    )

    rubric: list[dict[str, Any]] = []
    score = 100

    brief_ready = len(product_brief.strip()) >= 40
    rubric.append(
        {
            "dimension": "brief clarity",
            "status": "ready" if brief_ready else "partial",
            "notes": "The brief is specific enough to guide execution." if brief_ready else "The brief needs more detail.",
        }
    )
    score -= 0 if brief_ready else 15

    audience_ready = len(audience.strip()) >= 6 and audience.lower() not in {"everyone", "users", "customers"}
    rubric.append(
        {
            "dimension": "audience definition",
            "status": "ready" if audience_ready else "blocked",
            "notes": "Audience is concrete." if audience_ready else "Audience is too broad for launch copy and routing.",
        }
    )
    score -= 0 if audience_ready else 20

    days_until = _days_until(launch_date)
    if launch_date is None:
        launch_status = "blocked"
        launch_notes = "Launch date is missing."
        score -= 20
    elif days_until is not None and days_until < 0:
        launch_status = "blocked"
        launch_notes = "Launch date is already in the past."
        score -= 25
    elif days_until is not None and days_until <= 7:
        launch_status = "partial"
        launch_notes = f"Launch is close ({days_until} day(s) away)."
        score -= 10
    else:
        launch_status = "ready"
        launch_notes = f"Launch window is {days_until} day(s) away."
    rubric.append(
        {
            "dimension": "launch timing",
            "status": launch_status,
            "notes": launch_notes,
        }
    )

    assets_ready = len(assets) >= 2
    rubric.append(
        {
            "dimension": "assets",
            "status": "ready" if assets_ready else "partial",
            "notes": "Enough launch assets are listed." if assets_ready else "Missing assets or asset details need attention.",
        }
    )
    score -= 0 if assets_ready else 10

    constraints_ready = bool(constraints)
    rubric.append(
        {
            "dimension": "constraints",
            "status": "ready" if constraints_ready else "partial",
            "notes": "Constraints are named." if constraints_ready else "No hard constraints were provided.",
        }
    )
    score -= 0 if constraints_ready else 5

    qa_ready = _contains(product_brief, "qa", "test", "rollback", "rollout", "monitor") or assets_ready
    rubric.append(
        {
            "dimension": "qa and rollback",
            "status": "ready" if qa_ready else "partial",
            "notes": "A release safety path is visible." if qa_ready else "QA or rollback details still need to be added.",
        }
    )
    score -= 0 if qa_ready else 10

    copy_ready = audience_ready and bool(assets)
    rubric.append(
        {
            "dimension": "comms readiness",
            "status": "ready" if copy_ready else "partial",
            "notes": "Copy can be tailored." if copy_ready else "Channel copy still needs grounding.",
        }
    )
    score -= 0 if copy_ready else 10

    score = max(0, min(100, score))
    blocked = any(item["status"] == "blocked" for item in rubric)
    verdict = "hold" if blocked or score < 60 else ("go" if score >= 80 else "go_with_risks")

    top_gaps = [item["dimension"] for item in rubric if item["status"] != "ready"]
    if missing["blocking_gaps"]:
        top_gaps = _unique(top_gaps + missing["blocking_gaps"])

    return {
        "score": score,
        "verdict": verdict,
        "top_gaps": top_gaps,
        "rubric": rubric,
    }


def generate_owner_checklist_data(
    *,
    product_brief: str,
    audience: str,
    launch_date: date | None,
    constraints: list[str] | None = None,
    assets: list[str] | None = None,
) -> dict[str, Any]:
    constraints = _normalize_lines(constraints)
    assets = _normalize_lines(assets)
    days_until = _days_until(launch_date)

    items: list[dict[str, Any]] = [
        {
            "owner": "PM",
            "checklist": [
                "Confirm launch scope and decision owner.",
                "Lock the go/no-go criteria.",
            ],
        },
        {
            "owner": "Engineering",
            "checklist": [
                "Verify deployment steps and monitoring.",
                "Confirm rollback and rollback owner.",
            ],
        },
        {
            "owner": "QA",
            "checklist": [
                "Execute the final smoke test plan.",
                "Log any open defects with a release decision.",
            ],
        },
        {
            "owner": "Marketing",
            "checklist": [
                "Finalize the main launch message.",
                "Adapt copy for each required channel.",
            ],
        },
        {
            "owner": "Support",
            "checklist": [
                "Prepare the support handoff note.",
                "Share the customer-facing FAQ or issue response plan.",
            ],
        },
    ]

    if assets:
        items.append(
            {
                "owner": "Design",
                "checklist": [
                    "Validate screenshots, visuals, and launch artifacts.",
                    "Confirm the assets match the latest product scope.",
                ],
            }
        )
    if constraints:
        items.append(
            {
                "owner": "Program Lead",
                "checklist": [
                    "Review each constraint and assign a direct owner.",
                    "Confirm any missing approvals or dependencies.",
                ],
            }
        )
    if days_until is not None and days_until <= 7:
        items.append(
            {
                "owner": "Launch Commander",
                "checklist": [
                    "Schedule the final readiness checkpoint.",
                    "Make the rollback trigger explicit.",
                ],
            }
        )

    return {"items": items}


def draft_launch_copy_data(
    *,
    product_brief: str,
    audience: str,
    launch_date: date | None,
    constraints: list[str] | None = None,
    assets: list[str] | None = None,
    channels: list[str] | None = None,
) -> dict[str, Any]:
    constraints = _normalize_lines(constraints)
    assets = _normalize_lines(assets)
    channels = _unique(_normalize_lines(channels)) or ["Slack", "Email", "Release notes"]
    tone = "clear, confident, and practical"

    product_line = product_brief.strip().splitlines()[0][:160]
    audience_line = audience.strip()
    launch_phrase = launch_date.isoformat() if launch_date else "the launch window"
    asset_phrase = ", ".join(assets[:3]) if assets else "the core launch assets"
    constraint_phrase = "; ".join(constraints[:2]) if constraints else "the launch constraints"

    drafts: list[dict[str, Any]] = []
    for channel in channels:
        channel_lower = channel.lower()
        if "slack" in channel_lower:
            draft = (
                f"Launch Desk update: {product_line}. Audience: {audience_line}. "
                f"We are targeting {launch_phrase} and have {asset_phrase} ready to go. "
                f"Key constraint watchouts: {constraint_phrase}. Please review owners and reply with blockers."
            )
        elif "email" in channel_lower:
            draft = (
                f"Subject: Launch plan for {product_line}\n\n"
                f"Team, we are shaping the release for {audience_line}. "
                f"Target launch: {launch_phrase}.\n\n"
                f"Highlights:\n- {asset_phrase}\n- Constraints to watch: {constraint_phrase}\n\n"
                "Reply with any launch risks, gaps, or owner updates before the readiness review."
            )
        elif "release" in channel_lower or "notes" in channel_lower:
            draft = (
                f"{product_line}\n\n"
                f"This release is intended for {audience_line}. "
                f"Planned launch timing: {launch_phrase}. "
                f"Included assets: {asset_phrase}. "
                f"Release note guardrails: {constraint_phrase}."
            )
        else:
            draft = (
                f"{product_line} is launching for {audience_line} around {launch_phrase}. "
                f"Use a {tone} tone and make sure {asset_phrase} are attached."
            )

        drafts.append(
            {
                "channel": channel,
                "audience": audience_line,
                "tone": tone,
                "draft": draft,
            }
        )

    return {"drafts": drafts, "tone": tone}


@function_tool
def extract_tasks_from_brief(
    product_brief: str,
    audience: str,
    launch_date: date | None = None,
    constraints: list[str] | None = None,
    assets: list[str] | None = None,
) -> dict[str, Any]:
    """Extract the launch tasks and the missing-detail signals from the brief."""

    return extract_tasks_from_brief_data(
        product_brief=product_brief,
        audience=audience,
        launch_date=launch_date,
        constraints=constraints,
        assets=assets,
    )


@function_tool
def check_launch_readiness(
    product_brief: str,
    audience: str,
    launch_date: date | None = None,
    constraints: list[str] | None = None,
    assets: list[str] | None = None,
) -> dict[str, Any]:
    """Score the launch against a simple readiness rubric."""

    return check_launch_readiness_data(
        product_brief=product_brief,
        audience=audience,
        launch_date=launch_date,
        constraints=constraints,
        assets=assets,
    )


@function_tool
def generate_owner_checklist(
    product_brief: str,
    audience: str,
    launch_date: date | None = None,
    constraints: list[str] | None = None,
    assets: list[str] | None = None,
) -> dict[str, Any]:
    """Generate the owner checklist for the launch plan."""

    return generate_owner_checklist_data(
        product_brief=product_brief,
        audience=audience,
        launch_date=launch_date,
        constraints=constraints,
        assets=assets,
    )


@function_tool
def draft_channel_copy(
    product_brief: str,
    audience: str,
    launch_date: date | None = None,
    constraints: list[str] | None = None,
    assets: list[str] | None = None,
    channels: list[str] | None = None,
) -> dict[str, Any]:
    """Draft channel-specific launch copy suggestions."""

    return draft_launch_copy_data(
        product_brief=product_brief,
        audience=audience,
        launch_date=launch_date,
        constraints=constraints,
        assets=assets,
        channels=channels,
    )


@function_tool
def identify_missing_details(
    product_brief: str,
    audience: str,
    launch_date: date | None = None,
    constraints: list[str] | None = None,
    assets: list[str] | None = None,
) -> dict[str, Any]:
    """Identify the follow-up questions needed before the launch plan is final."""

    return identify_missing_details_data(
        product_brief=product_brief,
        audience=audience,
        launch_date=launch_date,
        constraints=constraints,
        assets=assets,
    )


def build_launch_tools() -> list[Any]:
    return [
        extract_tasks_from_brief,
        check_launch_readiness,
        generate_owner_checklist,
        draft_channel_copy,
        identify_missing_details,
    ]
