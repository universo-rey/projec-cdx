from __future__ import annotations

from tools.sdu_canon_source_guard import classify_source_authority


def test_open_pr_and_draft_are_not_canon() -> None:
    assert classify_source_authority("PR_OPEN") == "NOT_CANON"
    assert classify_source_authority("draft") == "NOT_CANON"
    assert classify_source_authority("branch") == "NOT_CANON"
    assert classify_source_authority("smoke_only") == "NOT_CANON"


def test_merged_sources_can_be_canon() -> None:
    assert classify_source_authority("CANON_MERGED") == "CANON_MERGED"
    assert classify_source_authority("PR_MERGED") == "PR_MERGED"


def test_validated_readback_is_evidence_only() -> None:
    assert classify_source_authority("READBACK_VALIDATED") == "EVIDENCE_ONLY"
