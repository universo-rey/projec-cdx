from __future__ import annotations

import json
import os
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

from .agent import DEFAULT_MODEL, git_context
from metadata.path_policy import canonical_path

ROOT = Path(__file__).parents[2]
DEFAULT_BRANCH = "codex/consume-bound-workbook-next-delta"
TASK_PATH = ROOT / "operativa" / "CODEX_CLOUD_SMOKE_TASK_20260617.md"


def _run(args: list[str], timeout: int = 60) -> dict[str, Any]:
    result = subprocess.run(
        args,
        cwd=ROOT,
        capture_output=True,
        text=True,
        check=False,
        timeout=timeout,
    )
    return {
        "args": args,
        "returncode": result.returncode,
        "stdout": result.stdout.strip(),
        "stderr": result.stderr.strip(),
    }


def _git(*args: str) -> dict[str, Any]:
    return _run(["git", *args], timeout=60)


def load_cloud_smoke_task() -> dict[str, Any]:
    if not TASK_PATH.exists():
        return {
            "exists": False,
            "path": canonical_path(TASK_PATH) or str(TASK_PATH),
            "content": "",
            "error": "task file missing",
        }
    return {
        "exists": True,
        "path": canonical_path(TASK_PATH) or str(TASK_PATH),
        "content": TASK_PATH.read_text(encoding="utf-8"),
        "error": None,
    }


def remote_branch_head(branch: str = DEFAULT_BRANCH) -> dict[str, Any]:
    result = _git("ls-remote", "--heads", "origin", branch)
    head = ""
    ref = ""
    if result["returncode"] == 0 and result["stdout"]:
        parts = result["stdout"].split()
        if len(parts) >= 2:
            head, ref = parts[0], parts[1]
    return {
        "branch": branch,
        "head": head,
        "ref": ref,
        "found": bool(head),
        "returncode": result["returncode"],
        "stderr": result["stderr"],
    }


def local_smoke_report() -> dict[str, Any]:
    result = _run([sys.executable, "-m", "projec_cdx_cloud", "--smoke", "--json"], timeout=90)
    if result["returncode"] != 0:
        return {
            "ok": False,
            "returncode": result["returncode"],
            "error": result["stderr"] or result["stdout"],
            "report": {},
        }
    try:
        report = json.loads(result["stdout"])
    except json.JSONDecodeError as exc:
        return {
            "ok": False,
            "returncode": result["returncode"],
            "error": f"smoke output was not JSON: {exc}",
            "report": {},
        }
    return {
        "ok": True,
        "returncode": result["returncode"],
        "error": None,
        "report": report,
    }


def cloud_bridge_packet(branch: str = DEFAULT_BRANCH) -> dict[str, Any]:
    git_root, git_branch = git_context()
    task = load_cloud_smoke_task()
    remote = remote_branch_head(branch)
    smoke = local_smoke_report()
    smoke_report = smoke.get("report", {})

    checks = {
        "task_file_exists": bool(task["exists"]),
        "remote_branch_found": bool(remote["found"]),
        "local_smoke_ok": bool(smoke["ok"]),
        "context_ok": bool(smoke_report.get("context_ok")),
        "sdu_agents_defined": smoke_report.get("sdu_sdk_agents_defined") == 6,
        "gate_metadata_only": smoke_report.get("gate") == "metadata-only",
    }

    if all(checks.values()):
        status = "PASS"
    elif checks["task_file_exists"] and checks["remote_branch_found"] and checks["local_smoke_ok"]:
        status = "OBSERVED"
    else:
        status = "FAIL"

    return {
        "status": status,
        "created_at": datetime.now(timezone.utc).isoformat(),
        "repo_root": canonical_path(git_root) or git_root,
        "local_branch": git_branch,
        "target_branch": branch,
        "remote": remote,
        "task": {
            "exists": task["exists"],
            "path": canonical_path(task["path"]) or task["path"],
            "content_chars": len(task["content"]),
        },
        "smoke": smoke,
        "checks": checks,
        "systems_touched": ["local filesystem", "local git", "origin git read"],
        "systems_not_touched": [
            "Codex Cloud task create API",
            "Microsoft live write",
            "SharePoint write",
            "Dataverse write",
            "Power Automate flow run",
            "secrets output",
        ],
        "next_delta": "launch_prompt_in_codex_cloud_ui_or_codex_sdk_local_thread",
    }


def write_cloud_bridge_readback(packet: dict[str, Any]) -> Path:
    output_path = ROOT / "operativa" / "READBACK_CODEX_CLOUD_BRIDGE_20260617.md"
    remote_head = packet["remote"].get("head") or "NO_CONSTA"
    smoke_report = packet["smoke"].get("report", {})
    lines = [
        "# Readback Codex Cloud Bridge 20260617",
        "",
        f"Estado: `{packet['status']}`",
        "",
        "## Resultado",
        "",
        "Se preparo y verifico el puente local para lanzar el smoke gobernado en Codex Cloud.",
        "",
        "## Evidencia",
        "",
        f"- Rama local: `{packet['local_branch']}`",
        f"- Rama objetivo: `{packet['target_branch']}`",
        f"- HEAD remoto: `{remote_head}`",
        f"- Task file: `{packet['task']['path']}`",
        f"- context_ok: `{smoke_report.get('context_ok')}`",
        f"- context_drift: `{smoke_report.get('context_drift')}`",
        f"- sdu_sdk_agents_defined: `{smoke_report.get('sdu_sdk_agents_defined')}`",
        f"- gate: `{smoke_report.get('gate')}`",
        f"- mode: `{smoke_report.get('mode')}`",
        "",
        "## Sistemas No Tocados",
        "",
        "- No se creo una task Cloud por API.",
        "- No se imprimieron secretos.",
        "- No se ejecutaron flows.",
        "- No hubo writes Microsoft, SharePoint ni Dataverse.",
        "",
        "## Proximo Delta",
        "",
        "`launch_prompt_in_codex_cloud_ui_or_codex_sdk_local_thread`",
    ]
    output_path.write_text("\n".join(lines) + "\n", encoding="utf-8")
    return output_path


def build_cloud_bridge_agent(model: str | None = None) -> Any:
    try:
        from agents import Agent, function_tool
    except ImportError as exc:  # pragma: no cover - runtime guard
        raise RuntimeError(
            "openai-agents is not installed; install the agents-sdk optional dependency"
        ) from exc

    @function_tool
    def inspect_cloud_bridge() -> str:
        """Return the governed Codex Cloud bridge packet as JSON."""
        return json.dumps(cloud_bridge_packet(), ensure_ascii=False)

    instructions = (
        "Sos el agente puente Codex Cloud de PROJEC CDX. "
        "Debes llamar la herramienta inspect_cloud_bridge antes de responder. "
        "No inventes API de Codex Cloud. Si no hay API disponible, declaralo como frontera. "
        "Responde corto con PASS/OBSERVED/FAIL, evidencia, sistemas tocados/no tocados y proximo delta unico."
    )
    return Agent(
        name="codex-cloud-bridge",
        model=model or DEFAULT_MODEL,
        instructions=instructions,
        tools=[inspect_cloud_bridge],
    )


async def run_cloud_bridge_agent(prompt: str, model: str | None = None) -> str:
    if not os.environ.get("OPENAI_API_KEY"):
        raise RuntimeError("OPENAI_API_KEY is required for live Agents SDK bridge runs")

    try:
        from agents import Runner
    except ImportError as exc:  # pragma: no cover - runtime guard
        raise RuntimeError(
            "openai-agents is not installed; install the agents-sdk optional dependency"
        ) from exc

    agent = build_cloud_bridge_agent(model=model)
    result = await Runner.run(agent, prompt)
    return str(result.final_output)
