from __future__ import annotations

import sys
from pathlib import Path
from typing import Iterable

ROOT = Path(__file__).resolve().parent
SRC = ROOT / "src"
if str(SRC) not in sys.path:
    sys.path.insert(0, str(SRC))

from metadata.cli import main as metadata_main
from projec_cdx_cloud.cli import main as cloud_main
from runtime_versioning.cli import main as runtime_main

METADATA_COMMANDS = {"validate", "build-index", "graph", "promote"}


def main(argv: Iterable[str] | None = None) -> int:
    args = list(argv) if argv is not None else sys.argv[1:]
    if args and args[0] in METADATA_COMMANDS:
        return metadata_main(args)
    if args and args[0] == "runtime":
        return runtime_main(args[1:])
    return cloud_main(args)


if __name__ == "__main__":
    raise SystemExit(main())
