from __future__ import annotations

import sys
from collections.abc import Iterable
from pathlib import Path

ROOT = Path(__file__).resolve().parent
SRC = ROOT / "src"
if str(SRC) not in sys.path:
    sys.path.insert(0, str(SRC))

from metadata.cli import main as metadata_main
from metadata.runtime_checks import check_elevation
from projec_cdx_cloud.cli import main as cloud_main
from runtime_versioning.cli import main as runtime_main

METADATA_COMMANDS = {"validate", "build-index", "graph", "promote"}


def _strip_require_elevated(args: list[str]) -> tuple[bool, list[str]]:
    require_elevated = False
    forwarded: list[str] = []
    for arg in args:
        if arg == "--require-elevated":
            require_elevated = True
            continue
        forwarded.append(arg)
    return require_elevated, forwarded


def main(argv: Iterable[str] | None = None) -> int:
    args = list(argv) if argv is not None else sys.argv[1:]
    require_elevated, args = _strip_require_elevated(args)
    if require_elevated and not check_elevation(True, "root"):
        return 2
    if args and args[0] in METADATA_COMMANDS:
        return metadata_main(args)
    if args and args[0] == "runtime":
        return runtime_main(args[1:])
    return cloud_main(args)


if __name__ == "__main__":
    raise SystemExit(main())
