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

SDU_AGENT_PROFILES: dict[str, str] = {
    "seshat-normativa": (
        "Lee el canon, fija evidencia base y responde con trazabilidad. "
        "No inventes activaciones live ni mezcles metadata con runtime."
    ),
    "thot-tecnico": (
        "Ordena el esquema, convierte la orden en movimiento util y deja la estructura legible."
    ),
    "anubis-gate": (
        "Cuida frontera, gate, rollback y postcheck. Si falta target, detente."
    ),
    "maat-cumplimiento": (
        "Vigila coherencia, RACI y condiciones de cierre. No cierres sin evidencia."
    ),
    "horus-riesgo": (
        "Observa riesgo, contradicciones y exposicion. Señala rollback si algo no cuadra."
    ),
    "narrador-normativo": (
        "Redacta el readback final y el siguiente paso unico, sin agregar ruido."
    ),
}


@dataclass(frozen=True)
class AgentRun:
    prompt: str
    model: str
    final_output: str


def build_agent(name: str = "CodexCloudAtomic", instructions: str | None = None, model: str | None = None) -> Any:
    try:
        from agents import Agent
    except ImportError as exc:  # pragma: no cover - runtime guard
        raise RuntimeError(
            "openai-agents is not installed; install the agents-sdk optional dependency"
        ) from exc

    return Agent(
        name=name,
        model=model or DEFAULT_MODEL,
        instructions=instructions or SYSTEM_INSTRUCTIONS,
    )


def build_sdu_agents(model: str | None = None) -> dict[str, Any]:
    """Build the six SDK-SDU agents as concrete runtime objects."""
    return {
        name: build_agent(
            name=name,
            instructions=f"{SYSTEM_INSTRUCTIONS} {role_instructions}",
            model=model,
        )
        for name, role_instructions in SDU_AGENT_PROFILES.items()
    }


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
            r"C:\Users\enzo1\PROJEC CDX",
        ),
        "branch": os.environ.get("CODEX_CLOUD_BRANCH", "main"),
        "model": os.environ.get("OPENAI_MODEL", DEFAULT_MODEL),
        "openai_api_key_present": bool(os.environ.get("OPENAI_API_KEY")),
        "agents_sdk_installed": agents_installed,
        "agents_sdk_version": agents_version,
        "gate": os.environ.get("CODEX_CLOUD_GATE", "metadata-only"),
        "mode": os.environ.get("CODEX_CLOUD_MODE", "cloud"),
        "sdu_sdk_agents_defined": len(SDU_AGENT_PROFILES),
        "sdu_sdk_agents": list(SDU_AGENT_PROFILES.keys()),
    }
