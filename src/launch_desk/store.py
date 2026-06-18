from __future__ import annotations

import json
import os
from hashlib import sha256
from pathlib import Path

from .config import ROOT
from .schemas import (
    LaunchDeskHistoryItem,
    LaunchDeskHistoryResponse,
    LaunchDeskRequest,
    LaunchDeskReport,
)

HISTORY_PATH = Path(
    os.environ.get("LAUNCH_DESK_HISTORY_PATH", str(ROOT / "launch-desk" / "data" / "history.jsonl"))
)


def _ensure_parent(path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)


def _read_jsonl(path: Path) -> list[dict]:
    if not path.exists():
        return []

    rows: list[dict] = []
    for raw_line in path.read_text(encoding="utf-8").splitlines():
        line = raw_line.strip()
        if not line:
            continue
        try:
            rows.append(json.loads(line))
        except json.JSONDecodeError:
            continue
    return rows


def request_cache_key(request: LaunchDeskRequest, *, model: str) -> str:
    payload = {
        "model": model,
        "request": request.model_dump(mode="json"),
    }
    canonical = json.dumps(payload, ensure_ascii=False, sort_keys=True, separators=(",", ":"))
    return sha256(canonical.encode("utf-8")).hexdigest()


def persist_run_record(
    *,
    request_id: str,
    created_at: str,
    model: str,
    request: LaunchDeskRequest,
    report: LaunchDeskReport,
) -> dict:
    cache_key = request_cache_key(request, model=model)
    record = {
        "request_id": request_id,
        "created_at": created_at,
        "model": model,
        "cache_key": cache_key,
        "request": request.model_dump(mode="json"),
        "report": report.model_dump(mode="json"),
    }
    _ensure_parent(HISTORY_PATH)
    with HISTORY_PATH.open("a", encoding="utf-8") as handle:
        handle.write(json.dumps(record, ensure_ascii=False) + "\n")
    return record


def _record_to_history_item(record: dict) -> LaunchDeskHistoryItem:
    request = record.get("request", {})
    report = record.get("report", {})
    readiness = report.get("readiness", {})
    return LaunchDeskHistoryItem(
        request_id=record.get("request_id", ""),
        created_at=record.get("created_at", ""),
        model=record.get("model", ""),
        title=report.get("title", "Launch plan"),
        summary=report.get("summary", ""),
        score=int(readiness.get("score", 0) or 0),
        verdict=readiness.get("verdict", "hold"),
        audience=request.get("audience", ""),
        launch_date=request.get("launch_date"),
    )


def _record_search_text(record: dict) -> str:
    request = record.get("request", {})
    report = record.get("report", {})
    readiness = report.get("readiness", {})
    parts = [
        record.get("request_id", ""),
        record.get("created_at", ""),
        record.get("model", ""),
        request.get("product_brief", ""),
        request.get("audience", ""),
        " ".join(request.get("constraints", []) or []),
        " ".join(request.get("assets", []) or []),
        " ".join(request.get("desired_channels", []) or []),
        report.get("title", ""),
        report.get("summary", ""),
        report.get("next_action", ""),
        " ".join(report.get("assumptions", []) or []),
        " ".join(item.get("question", "") for item in report.get("follow_up_questions", []) or []),
        " ".join(item.get("risk", "") for item in report.get("risk_register", []) or []),
        " ".join(item.get("owner", "") for item in report.get("owner_checklist", []) or []),
        " ".join(item.get("channel", "") for item in report.get("launch_copy_suggestions", []) or []),
        str(readiness.get("score", "")),
        readiness.get("verdict", ""),
    ]
    return " ".join(str(part) for part in parts if part).lower()


def _matches_filters(
    record: dict,
    *,
    query: str | None = None,
    verdict: str | None = None,
    audience: str | None = None,
) -> bool:
    if verdict and record.get("report", {}).get("readiness", {}).get("verdict") != verdict:
        return False
    if audience:
        record_audience = str(record.get("request", {}).get("audience", "")).lower()
        if audience.lower() not in record_audience:
            return False
    if query:
        text = _record_search_text(record)
        if query.lower() not in text:
            return False
    return True


def list_history(
    limit: int = 10,
    *,
    query: str | None = None,
    verdict: str | None = None,
    audience: str | None = None,
) -> LaunchDeskHistoryResponse:
    rows = _read_jsonl(HISTORY_PATH)
    filtered_rows = [
        row
        for row in reversed(rows)
        if _matches_filters(row, query=query, verdict=verdict, audience=audience)
    ]
    items = [_record_to_history_item(row) for row in filtered_rows[:limit]]
    return LaunchDeskHistoryResponse(items=items)


def get_history_record(request_id: str) -> dict | None:
    rows = _read_jsonl(HISTORY_PATH)
    for row in reversed(rows):
        if row.get("request_id") == request_id:
            return row
    return None


def get_cached_run_record(request: LaunchDeskRequest, *, model: str) -> dict | None:
    cache_key = request_cache_key(request, model=model)
    rows = _read_jsonl(HISTORY_PATH)
    for row in reversed(rows):
        if row.get("cache_key") == cache_key:
            return row
    return None


def render_history_record_markdown(record: dict) -> str:
    request = record.get("request", {})
    report = record.get("report", {})
    readiness = report.get("readiness", {})

    def _bullet_lines(values: list[str]) -> str:
        return "\n".join(f"- {value}" for value in values) if values else "- None"

    lines: list[str] = [
        f"# {report.get('title', 'Launch plan')}",
        "",
        f"- Request ID: `{record.get('request_id', '')}`",
        f"- Created at: `{record.get('created_at', '')}`",
        f"- Model: `{record.get('model', '')}`",
        f"- Audience: `{request.get('audience', '')}`",
    ]
    if request.get("launch_date"):
        lines.append(f"- Launch date: `{request.get('launch_date')}`")

    lines.extend(
        [
            "",
            "## Summary",
            "",
            report.get("summary", "No summary available."),
            "",
            "## Next Action",
            "",
            report.get("next_action", "No next action available."),
            "",
            "## Prioritized Plan",
        ]
    )
    plan = report.get("prioritized_plan", []) or []
    if plan:
        for step in plan:
            due = f" Due: {step.get('due')}" if step.get("due") else ""
            lines.append(
                f"- #{step.get('priority', '?')} {step.get('owner', '')}: {step.get('action', '')} ({step.get('reason', '')}){due}"
            )
    else:
        lines.append("- None")

    lines.extend(["", "## Risk Register"])
    risks = report.get("risk_register", []) or []
    if risks:
        for risk in risks:
            lines.append(
                f"- {risk.get('risk', '')} [{risk.get('severity', '')}/{risk.get('likelihood', '')}] Owner: {risk.get('owner', '')}. Mitigation: {risk.get('mitigation', '')}"
            )
    else:
        lines.append("- None")

    lines.extend(["", "## Owner Checklist"])
    checklist = report.get("owner_checklist", []) or []
    if checklist:
        for item in checklist:
            lines.append(f"- {item.get('owner', '')}")
            for entry in item.get("checklist", []) or []:
                lines.append(f"  - {entry}")
    else:
        lines.append("- None")

    lines.extend(["", "## Launch Copy"])
    copy_suggestions = report.get("launch_copy_suggestions", []) or []
    if copy_suggestions:
        for copy in copy_suggestions:
            lines.extend(
                [
                    f"- {copy.get('channel', '')} ({copy.get('tone', '')})",
                    f"  - Audience: {copy.get('audience', '')}",
                    f"  - Draft: {copy.get('draft', '')}",
                ]
            )
    else:
        lines.append("- None")

    lines.extend(["", "## Follow-up Questions"])
    questions = report.get("follow_up_questions", []) or []
    if questions:
        for item in questions:
            lines.append(
                f"- {'Blocking' if item.get('blocking', True) else 'Helpful'}: {item.get('question', '')} ({item.get('why_it_matters', '')})"
            )
    else:
        lines.append("- None")

    lines.extend(
        [
            "",
            "## Readiness",
            "",
            f"- Score: `{readiness.get('score', 0)}`",
            f"- Verdict: `{readiness.get('verdict', '')}`",
            "",
            "### Top Gaps",
            "",
            _bullet_lines(readiness.get("top_gaps", []) or []),
            "",
            "### Rubric",
        ]
    )
    rubric = readiness.get("rubric", []) or []
    if rubric:
        for item in rubric:
            lines.append(f"- {item.get('dimension', '')}: {item.get('status', '')} - {item.get('notes', '')}")
    else:
        lines.append("- None")

    lines.extend(
        [
            "",
            "## Assumptions",
            "",
            _bullet_lines(report.get("assumptions", []) or []),
        ]
    )
    return "\n".join(lines).strip() + "\n"
