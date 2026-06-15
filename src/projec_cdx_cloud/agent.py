from __future__ import annotations

import asyncio
import os
from dataclasses import dataclass
from typing import Any

DEFAULT_MODEL = os.environ.get("OPENAI_MODEL", "gpt-5.4-mini")

SYSTEM_INSTRUCTIONS = (
    "Eres el carril Codex Cloud de PROJEC CDX. "
    "Trabajas con atomicidad, un solo lane, sin live write sin gate, "
    "y con Dataverse solo en metadata-only hasta nueva orden. "
    "El root canonico es C:\\Users\\enzo1\\PROJEC CDX. "
    "Cuando respondas, prioriza estado, superficie, lanes, gate, evidencia, bloqueos y proximo paso unico. "
    "No inventes configuraciones, no expongas secretos y no mezcles limpieza local con bootstrap cloud."
)


@dataclass(frozen=True)
class AgentRun:
    prompt: str
    model: str
    final_output: str


def build_agent(model: str | None = None) -> Any:
    try:
        from agents import Agent
    except ImportError as exc:  # pragma: no cover - runtime guard
        raise RuntimeError(
            "openai-agents is not installed; install the agents-sdk optional dependency"
        ) from exc

    return Agent(
        name="CodexCloudAtomic",
        model=model or DEFAULT_MODEL,
        instructions=SYSTEM_INSTRUCTIONS,
    )


async def run_agent(prompt: str, model: str | None = None) -> AgentRun:
    if not os.environ.get("OPENAI_API_KEY"):
        raise RuntimeError("OPENAI_API_KEY is required for live Agents SDK runs")

    try:
        from agents import Runner
    except ImportError as exc:  # pragma: no cover - runtime guard
        raise RuntimeError(
            "openai-agents is not installed; install the agents-sdk optional dependency"
        ) from exc

    agent = build_agent(model=model)
    result = await Runner.run(agent, prompt)
    return AgentRun(prompt=prompt, model=model or DEFAULT_MODEL, final_output=result.final_output)


def smoke_report() -> dict[str, Any]:
    try:
        import agents  # type: ignore[import-not-found]
        agents_installed = True
        agents_version = getattr(agents, "__version__", "unknown")
    except Exception:
        agents_installed = False
        agents_version = "missing"

    return {
        "status": "prepared",
        "repo_root": r"C:\Users\enzo1\PROJEC CDX",
        "worktree": os.environ.get(
            "CODEX_CLOUD_WORKTREE",
            r"C:\Users\enzo1\.codex\worktrees\49ea\PROJEC CDX",
        ),
        "branch": os.environ.get("CODEX_CLOUD_BRANCH", "codex/revisar-procesos-del-equipo"),
        "model": os.environ.get("OPENAI_MODEL", DEFAULT_MODEL),
        "openai_api_key_present": bool(os.environ.get("OPENAI_API_KEY")),
        "agents_sdk_installed": agents_installed,
        "agents_sdk_version": agents_version,
        "gate": os.environ.get("CODEX_CLOUD_GATE", "metadata-only"),
        "mode": os.environ.get("CODEX_CLOUD_MODE", "hybrid"),
    }
