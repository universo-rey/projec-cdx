from __future__ import annotations

import ctypes
import os
import subprocess
import sys
from functools import lru_cache
from typing import TextIO

_WARNED_NON_ELEVATED = False


@lru_cache(maxsize=1)
def is_elevated_terminal() -> bool:
    if os.name != "nt":
        return True

    try:
        if bool(ctypes.windll.shell32.IsUserAnAdmin()):  # type: ignore[attr-defined]
            return True
    except Exception:
        pass

    try:
        result = subprocess.run(
            ["net", "session"],
            capture_output=True,
            text=True,
            timeout=5,
            check=False,
        )
        return result.returncode == 0
    except Exception:
        return False


def check_elevation(
    required: bool = False,
    context: str = "startup",
    stream: TextIO | None = None,
) -> bool:
    global _WARNED_NON_ELEVATED
    if stream is None:
        stream = sys.stderr
    if is_elevated_terminal():
        return True

    if required:
        print(
            f"ERROR[{context}]: se requiere una terminal elevada. Reabre la sesion como Administrador y reintenta.",
            file=stream,
        )
        return False

    if _WARNED_NON_ELEVATED:
        return False

    _WARNED_NON_ELEVATED = True
    print(
        f"AVISO[{context}]: la terminal no esta elevada. Ejecuta esta sesion como Administrador para evitar bloqueos de acceso.",
        file=stream,
    )
    print(
        "Se detecto un token estandar; algunas acciones pueden fallar o quedar limitadas.",
        file=stream,
    )
    return True


def warn_if_not_elevated(context: str = "startup", stream: TextIO | None = None) -> bool:
    return check_elevation(False, context=context, stream=stream)
