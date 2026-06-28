from __future__ import annotations

import re
from pathlib import Path
from typing import Any

LONG_PATH_PREFIX = "\\\\?\\"
LONG_UNC_PREFIX = "\\\\?\\UNC\\"
WINDOWS_OLD_ROOT = "C:/Windows.old"


def normalize_path(path: str | Path | None) -> str | None:
    if path is None:
        return None

    text = str(path).strip().strip('"')
    if text.startswith(LONG_UNC_PREFIX):
        text = "//" + text[len(LONG_UNC_PREFIX) :]
    elif text.startswith(LONG_PATH_PREFIX):
        text = text[len(LONG_PATH_PREFIX) :]

    text = text.replace("\\", "/")
    if text.startswith("//"):
        return "//" + "/".join(part for part in text[2:].split("/") if part)
    return "/".join(part for part in text.split("/") if part)


def canonical_path(path: str | Path | None) -> str | None:
    return normalize_path(path)


def is_windows_old_path(path: str | Path | None) -> bool:
    candidate = canonical_path(path)
    if not candidate:
        return False
    prefix = WINDOWS_OLD_ROOT
    return candidate == prefix or candidate.startswith(f"{prefix}/")


def _looks_like_path_like(value: str) -> bool:
    if "://" in value:
        return False
    return (
        value.startswith(LONG_PATH_PREFIX)
        or value.startswith(LONG_UNC_PREFIX)
        or value.startswith("//")
        or "\\" in value
        or bool(re.match(r"^[A-Za-z]:[\\/]", value))
        or value.startswith("./")
        or value.startswith("../")
        or value.startswith(".\\")
        or value.startswith("..\\")
    )


def normalize_path_value(value: Any) -> Any:
    if isinstance(value, dict):
        return {key: normalize_path_value(item) for key, item in value.items()}
    if isinstance(value, list):
        return [normalize_path_value(item) for item in value]
    if isinstance(value, str):
        if _looks_like_path_like(value):
            normalized = normalize_path(value)
            if normalized:
                return normalized
    return value
