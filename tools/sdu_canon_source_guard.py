from __future__ import annotations

import argparse
import json
from collections.abc import Iterable

NOT_CANON_STATES = {"pr_open", "draft", "branch", "smoke_only", "local_smoke"}
CANON_STATES = {"canon_merged", "pr_merged"}
EVIDENCE_STATES = {"readback_validated", "evidence_only", "local_draft"}


def classify_source_authority(state: str) -> str:
    normalized = state.strip().lower().replace(" ", "_").replace("-", "_")
    if normalized in CANON_STATES:
        return normalized.upper()
    if normalized in NOT_CANON_STATES:
        return "NOT_CANON"
    if normalized in EVIDENCE_STATES:
        return "EVIDENCE_ONLY"
    return "OPERATOR_DECISION_REQUIRED"


def main(argv: Iterable[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Clasifica autoridad canonica de una fuente.")
    parser.add_argument(
        "state", help="Estado de fuente: PR_OPEN, PR_MERGED, DRAFT, BRANCH, SMOKE_ONLY."
    )
    args = parser.parse_args(list(argv) if argv is not None else None)
    print(
        json.dumps({"state": args.state, "classification": classify_source_authority(args.state)})
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
