from __future__ import annotations

import os
from typing import Any
from uuid import uuid4

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse, PlainTextResponse, Response, StreamingResponse

from .config import api_key_present, load_local_env, model_profile, resolve_model
from .schemas import LaunchDeskRequest
from .service import _public_error_message, run_launch_desk, stream_launch_desk
from .store import get_history_record, list_history, render_history_record_markdown


def _frontend_origins() -> list[str]:
    base = os.environ.get("LAUNCH_DESK_FRONTEND_ORIGIN", "http://127.0.0.1:3000")
    aliases = [
        base,
        base.replace("127.0.0.1", "localhost"),
    ]
    return list(dict.fromkeys(aliases))


def create_app() -> FastAPI:
    load_local_env()
    app = FastAPI(title="Launch Desk API", version="0.1.0")
    app.add_middleware(
        CORSMiddleware,
        allow_origins=_frontend_origins(),
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

    @app.get("/api/health")
    async def health() -> dict[str, Any]:
        return {
            "status": "ok",
            "model": resolve_model(),
            "model_profile": model_profile(),
            "openai_api_key_present": api_key_present(),
        }

    @app.post("/api/launch-plan")
    async def launch_plan(request: LaunchDeskRequest) -> JSONResponse:
        if not api_key_present():
            raise HTTPException(status_code=400, detail="OPENAI_API_KEY is required")
        request_id = uuid4().hex
        try:
            result = await run_launch_desk(request, request_id=request_id)
        except Exception as exc:
            raise HTTPException(status_code=502, detail=_public_error_message(exc)) from exc
        return JSONResponse(
            {
                "type": "final",
                "request_id": result.request_id,
                "model": result.model,
                "cached": result.cached,
                "report": result.report.model_dump(mode="json"),
            }
        )

    @app.post("/api/launch-plan/stream")
    async def launch_plan_stream(request: LaunchDeskRequest) -> StreamingResponse:
        if not api_key_present():
            raise HTTPException(status_code=400, detail="OPENAI_API_KEY is required")
        request_id = uuid4().hex

        async def generator():
            async for line in stream_launch_desk(request, request_id=request_id):
                yield line

        return StreamingResponse(generator(), media_type="application/x-ndjson")

    @app.get("/api/history")
    async def history(
        limit: int = 10,
        query: str | None = None,
        verdict: str | None = None,
        audience: str | None = None,
    ) -> dict[str, Any]:
        return list_history(
            limit=limit, query=query, verdict=verdict, audience=audience
        ).model_dump(mode="json")

    @app.get("/api/history/{request_id}")
    async def history_item(request_id: str) -> dict[str, Any]:
        record = get_history_record(request_id)
        if record is None:
            raise HTTPException(status_code=404, detail="History item not found")
        return record

    @app.get("/api/history/{request_id}/export", response_model=None)
    async def history_item_export(request_id: str, format: str = "markdown") -> Response:
        record = get_history_record(request_id)
        if record is None:
            raise HTTPException(status_code=404, detail="History item not found")

        if format == "json":
            return JSONResponse(record)

        if format != "markdown":
            raise HTTPException(status_code=400, detail="format must be markdown or json")

        markdown = render_history_record_markdown(record)
        return PlainTextResponse(markdown, media_type="text/markdown")

    return app
