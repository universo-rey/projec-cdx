from __future__ import annotations

import os
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
FRONTEND_DIR = ROOT / "launch-desk" / "frontend"
DEFAULT_MODEL = os.environ.get("LAUNCH_DESK_MODEL", "gpt-5.5")
MODEL_PROFILES = {
    "quality": "gpt-5.5",
    "balanced": "gpt-5.4",
    "fast": "gpt-5.4-mini",
    "nano": "gpt-5.4-nano",
}
DEFAULT_MODEL_PROFILE = os.environ.get("LAUNCH_DESK_MODEL_PROFILE", "quality")
RUN_TIMEOUT_SECONDS = float(os.environ.get("LAUNCH_DESK_RUN_TIMEOUT_SECONDS", "90"))
ENABLE_RESPONSE_CACHE = os.environ.get("LAUNCH_DESK_ENABLE_CACHE", "1") != "0"
ENABLE_SDK_TOOLS = os.environ.get("LAUNCH_DESK_ENABLE_SDK_TOOLS", "0") == "1"


def load_env_file(path: Path) -> None:
    if not path.exists():
        return

    for raw_line in path.read_text(encoding="utf-8").splitlines():
        line = raw_line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue

        key, value = line.split("=", 1)
        key = key.strip()
        value = value.strip()
        if not key or key in os.environ:
            continue

        if value.startswith('"') and value.endswith('"'):
            value = value[1:-1]
        elif value.startswith("'") and value.endswith("'"):
            value = value[1:-1]

        os.environ[key] = value


def load_local_env() -> None:
    for candidate in (ROOT / ".env.local", ROOT / ".env"):
        load_env_file(candidate)


def api_key_present() -> bool:
    return bool(os.environ.get("OPENAI_API_KEY"))


def resolve_model(profile: str | None = None) -> str:
    if os.environ.get("LAUNCH_DESK_MODEL"):
        return os.environ["LAUNCH_DESK_MODEL"]

    selected_profile = (profile or DEFAULT_MODEL_PROFILE).strip().lower()
    return MODEL_PROFILES.get(selected_profile, DEFAULT_MODEL)


def model_profile() -> str:
    if os.environ.get("LAUNCH_DESK_MODEL"):
        return "custom"
    return DEFAULT_MODEL_PROFILE if DEFAULT_MODEL_PROFILE in MODEL_PROFILES else "quality"
