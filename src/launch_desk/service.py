from __future__ import annotations

import asyncio
import json
from collections.abc import AsyncIterator
from dataclasses import dataclass
from datetime import datetime, timezone
from typing import Any

from agents import Runner
from openai.types.responses.response_text_delta_event import ResponseTextDeltaEvent
from pydantic import ValidationError

from projec_cdx_common.safe_errors import sanitize_exception_message

from .agent import LaunchDeskRuntimeContext, build_launch_desk_agent, build_launch_prompt
from .config import ENABLE_RESPONSE_CACHE, RUN_TIMEOUT_SECONDS, resolve_model
from .observability import LaunchDeskRunHooks
from .schemas import LaunchDeskReport, LaunchDeskRequest
from .store import get_cached_run_record, persist_run_record
from .tools import (
    check_launch_readiness_data,
    draft_launch_copy_data,
    extract_tasks_from_brief_data,
    generate_owner_checklist_data,
    identify_missing_details_data,
)


@dataclass(frozen=True)
class LaunchDeskRunResult:
    request_id: str
    model: str
    report: LaunchDeskReport
    cached: bool = False


def _serialize_event(event_type: str, **payload: Any) -> str:
    return json.dumps({"type": event_type, **payload}, ensure_ascii=False) + "\n"


def _public_error_message(exc: BaseException) -> str:
    raw = sanitize_exception_message(exc)
    lowered = raw.lower()
    if isinstance(exc, TimeoutError) or isinstance(exc, asyncio.TimeoutError):
        return "The launch plan took too long to finish. Try a shorter brief or use a faster model profile."
    if "rate limit" in lowered or "429" in lowered:
        return "OpenAI rate limits were reached. Please wait a moment and try again."
    if "api key" in lowered or "authentication" in lowered or "401" in lowered:
        return (
            "The server could not authenticate with OpenAI. Check the OPENAI_API_KEY configuration."
        )
    if "model" in lowered and ("not found" in lowered or "does not exist" in lowered):
        return "The configured OpenAI model is not available for this project. Choose another Launch Desk model profile."
    if isinstance(exc, ValidationError):
        return "The model response did not match the Launch Desk report schema. Please retry or simplify the brief."
    return raw or "The launch plan could not be completed."


def _tool_name_from_item(item: Any) -> str:
    origin = getattr(item, "tool_origin", None)
    agent_tool_name = getattr(origin, "agent_tool_name", None) if origin else None
    if agent_tool_name:
        return agent_tool_name
    return getattr(item, "title", None) or getattr(item, "description", None) or "tool"


def _map_stream_event(event: Any) -> dict[str, Any] | None:
    if getattr(event, "type", None) == "raw_response_event":
        data = getattr(event, "data", None)
        if (
            isinstance(data, ResponseTextDeltaEvent)
            or getattr(data, "type", None) == "response.output_text.delta"
        ):
            return {"type": "text_delta", "delta": getattr(data, "delta", "")}
        if getattr(data, "type", None) == "response.reasoning_text.delta":
            return {"type": "reasoning_delta", "delta": getattr(data, "delta", "")}
        return None

    if getattr(event, "type", None) == "run_item_stream_event":
        if getattr(event, "name", None) in {"tool_called", "tool_output", "tool_search_called"}:
            item = getattr(event, "item", None)
            return {
                "event_name": "tool_progress",
                "phase": getattr(event, "name", "tool_called"),
                "tool": _tool_name_from_item(item) if item is not None else "tool",
            }
        if getattr(event, "name", None) == "message_output_created":
            return {"event_name": "message_chunk"}
        return None

    if getattr(event, "type", None) == "agent_tool_stream_event":
        tool_call = getattr(event, "tool_call", None)
        tool_name = getattr(tool_call, "name", None) if tool_call else None
        return {
            "event_name": "tool_progress",
            "phase": "agent_tool",
            "tool": tool_name or "tool",
        }

    return None


def _build_tool_context(request: LaunchDeskRequest) -> dict[str, Any]:
    return {
        "extract_tasks_from_brief": extract_tasks_from_brief_data(
            product_brief=request.product_brief,
            audience=request.audience,
            launch_date=request.launch_date,
            constraints=request.constraints,
            assets=request.assets,
        ),
        "check_launch_readiness": check_launch_readiness_data(
            product_brief=request.product_brief,
            audience=request.audience,
            launch_date=request.launch_date,
            constraints=request.constraints,
            assets=request.assets,
        ),
        "generate_owner_checklist": generate_owner_checklist_data(
            product_brief=request.product_brief,
            audience=request.audience,
            launch_date=request.launch_date,
            constraints=request.constraints,
            assets=request.assets,
        ),
        "draft_channel_copy": draft_launch_copy_data(
            product_brief=request.product_brief,
            audience=request.audience,
            launch_date=request.launch_date,
            constraints=request.constraints,
            assets=request.assets,
            channels=request.desired_channels,
        ),
        "identify_missing_details": identify_missing_details_data(
            product_brief=request.product_brief,
            audience=request.audience,
            launch_date=request.launch_date,
            constraints=request.constraints,
            assets=request.assets,
        ),
    }


async def stream_launch_desk(
    request: LaunchDeskRequest,
    *,
    request_id: str,
    model: str | None = None,
) -> AsyncIterator[str]:
    model = model or resolve_model()
    created_at = datetime.now(timezone.utc).isoformat()
    tool_context = _build_tool_context(request)

    yield _serialize_event(
        "run_started",
        request_id=request_id,
        model=model,
        audience=request.audience,
    )

    for tool_name, tool_output in tool_context.items():
        yield _serialize_event(
            "event",
            request_id=request_id,
            event_name="tool_progress",
            phase="backend_preflight",
            tool=tool_name,
            summary_keys=list(tool_output.keys()),
        )

    cached_record = get_cached_run_record(request, model=model) if ENABLE_RESPONSE_CACHE else None
    if cached_record is not None:
        yield _serialize_event(
            "event",
            request_id=request_id,
            event_name="cache_hit",
            phase="cache",
            tool="history_cache",
        )
        yield _serialize_event(
            "text_delta", request_id=request_id, delta="Loaded cached launch plan."
        )
        yield _serialize_event(
            "final",
            request_id=request_id,
            created_at=created_at,
            model=model,
            request=request.model_dump(mode="json"),
            report=cached_record["report"],
            cached=True,
            cached_from_request_id=cached_record.get("request_id"),
        )
        return

    agent = build_launch_desk_agent(model=model)
    prompt = build_launch_prompt(request, tool_context=tool_context)
    runtime_context = LaunchDeskRuntimeContext(request_id=request_id)
    hooks = LaunchDeskRunHooks(request_id=request_id)
    stream = Runner.run_streamed(agent, prompt, context=runtime_context, hooks=hooks)

    try:
        async with asyncio.timeout(RUN_TIMEOUT_SECONDS):
            async for event in stream.stream_events():
                mapped = _map_stream_event(event)
                if mapped is not None:
                    yield _serialize_event("event", request_id=request_id, **mapped)
    except Exception as exc:
        yield _serialize_event("error", request_id=request_id, message=_public_error_message(exc))
        return

    if stream.run_loop_exception is not None:
        yield _serialize_event(
            "error",
            request_id=request_id,
            message=_public_error_message(stream.run_loop_exception),
        )
        return

    try:
        final = stream.final_output
        report = (
            final if isinstance(final, LaunchDeskReport) else LaunchDeskReport.model_validate(final)
        )
    except Exception as exc:
        yield _serialize_event("error", request_id=request_id, message=_public_error_message(exc))
        return

    persist_run_record(
        request_id=request_id,
        created_at=created_at,
        model=model,
        request=request,
        report=report,
    )
    yield _serialize_event(
        "final",
        request_id=request_id,
        created_at=created_at,
        model=model,
        request=request.model_dump(mode="json"),
        report=report.model_dump(mode="json"),
    )


async def run_launch_desk(
    request: LaunchDeskRequest,
    *,
    request_id: str,
    model: str | None = None,
) -> LaunchDeskRunResult:
    model = model or resolve_model()
    created_at = datetime.now(timezone.utc).isoformat()
    cached_record = get_cached_run_record(request, model=model) if ENABLE_RESPONSE_CACHE else None
    if cached_record is not None:
        report = LaunchDeskReport.model_validate(cached_record["report"])
        return LaunchDeskRunResult(request_id=request_id, model=model, report=report, cached=True)

    tool_context = _build_tool_context(request)
    agent = build_launch_desk_agent(model=model)
    prompt = build_launch_prompt(request, tool_context=tool_context)
    runtime_context = LaunchDeskRuntimeContext(request_id=request_id)
    hooks = LaunchDeskRunHooks(request_id=request_id)
    async with asyncio.timeout(RUN_TIMEOUT_SECONDS):
        result = await Runner.run(agent, prompt, context=runtime_context, hooks=hooks)
    report = (
        result.final_output
        if isinstance(result.final_output, LaunchDeskReport)
        else LaunchDeskReport.model_validate(result.final_output)
    )
    persist_run_record(
        request_id=request_id,
        created_at=created_at,
        model=model,
        request=request,
        report=report,
    )
    return LaunchDeskRunResult(request_id=request_id, model=model, report=report)
