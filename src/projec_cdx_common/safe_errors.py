from __future__ import annotations

import re

SECRET_PATTERNS = {
    "openai_key": re.compile(r"sk-[A-Za-z0-9_-]{20,}"),
    "github_token": re.compile(r"gh[pousr]_[A-Za-z0-9_]{20,}"),
    "jwt": re.compile(r"eyJ[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}"),
    "aws_access_key": re.compile(r"AKIA[0-9A-Z]{16}"),
    "bearer": re.compile(r"(?i)\bBearer\s+[A-Za-z0-9._~+/=-]{12,}"),
    "sensitive_assignment": re.compile(
        r"(?i)\b(OPENAI_API_KEY|api_key|client_secret|access_token|refresh_token|password|secret|token)\s*[:=]\s*([^\s,;]+)"
    ),
}


def sanitize_exception_message(
    exc: BaseException | str,
    *,
    fallback: str = "The operation could not be completed.",
) -> str:
    """Return a short error message with token-like values redacted."""

    raw = str(exc).strip()
    if not raw:
        return fallback

    sanitized = raw
    for name, pattern in SECRET_PATTERNS.items():
        replacement = r"\1=[REDACTED_VALUE]" if name == "sensitive_assignment" else "[REDACTED_SECRET]"
        sanitized = pattern.sub(replacement, sanitized)

    sanitized = sanitized.strip()
    return sanitized or fallback

