from __future__ import annotations

import logging
from typing import Any

from agents import Agent
from agents.lifecycle import RunHooksBase

logger = logging.getLogger("launch_desk")


class LaunchDeskRunHooks(RunHooksBase[Any, Agent[Any]]):
    def __init__(self, request_id: str) -> None:
        self.request_id = request_id

    def _log(self, event: str, **fields: Any) -> None:
        payload = {"request_id": self.request_id, "event": event, **fields}
        logger.info("%s", payload)

    async def on_agent_start(self, context: Any, agent: Agent[Any]) -> None:
        self._log("agent_start", agent=agent.name)

    async def on_agent_end(self, context: Any, agent: Agent[Any], output: Any) -> None:
        self._log("agent_end", agent=agent.name)

    async def on_llm_start(
        self,
        context: Any,
        agent: Agent[Any],
        system_prompt: str | None,
        input_items: list[Any],
    ) -> None:
        self._log("llm_start", agent=agent.name, input_items=len(input_items))

    async def on_llm_end(self, context: Any, agent: Agent[Any], response: Any) -> None:
        self._log("llm_end", agent=agent.name)

    async def on_tool_start(self, context: Any, agent: Agent[Any], tool: Any) -> None:
        self._log("tool_start", agent=agent.name, tool=getattr(tool, "name", "unknown"))

    async def on_tool_end(self, context: Any, agent: Agent[Any], tool: Any, result: Any) -> None:
        self._log("tool_end", agent=agent.name, tool=getattr(tool, "name", "unknown"))
