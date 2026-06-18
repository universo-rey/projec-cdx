from __future__ import annotations

import json
from dataclasses import dataclass
from typing import Any

from agents import Agent

from .config import DEFAULT_MODEL, ENABLE_SDK_TOOLS
from .schemas import LaunchDeskRequest, LaunchDeskReport
from .tools import build_launch_tools

SYSTEM_INSTRUCTIONS = (
    "You are Launch Desk, an engineering launch planning agent.\n"
    "Outcome: turn the launch brief into one practical release plan the engineering team can execute.\n"
    "Use only the provided brief, audience, launch timing, constraints, assets, and prepared tool context.\n"
    "Prioritize concrete owners, launch risk reduction, readiness evidence, and channel-ready copy.\n"
    "If important details are missing, ask follow-up questions and mark blockers honestly.\n"
    "Keep the tone direct, practical, and teammate-friendly.\n"
    "Do not invent dependencies or approvals. If something is unknown, call it out.\n"
    "Return only data that matches the structured LaunchDeskReport schema."
)


@dataclass(frozen=True)
class LaunchDeskRuntimeContext:
    request_id: str
    source: str = "frontend"


def build_launch_prompt(request: LaunchDeskRequest, tool_context: dict[str, Any] | None = None) -> str:
    payload = json.dumps(request.model_dump(mode="json"), indent=2, ensure_ascii=False)
    context = json.dumps(tool_context or {}, indent=2, ensure_ascii=False)
    return (
        "Plan this launch.\n\n"
        "Success criteria: prioritized plan, risk register, owner checklist, launch copy, readiness summary, and follow-up questions.\n"
        "Use the prepared tool context as grounding data. Do not repeat raw tool context unless it belongs in the final schema.\n\n"
        f"Launch request:\n{payload}\n"
        f"\nPrepared tool context:\n{context}\n"
    )


def build_launch_desk_agent(
    model: str | None = None,
    *,
    include_sdk_tools: bool = ENABLE_SDK_TOOLS,
) -> Agent[LaunchDeskRuntimeContext]:
    return Agent(
        name="Launch Desk Planner",
        instructions=SYSTEM_INSTRUCTIONS,
        model=model or DEFAULT_MODEL,
        tools=build_launch_tools() if include_sdk_tools else [],
        output_type=LaunchDeskReport,
    )
