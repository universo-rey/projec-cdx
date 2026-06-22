from __future__ import annotations

import json
import subprocess
from pathlib import Path

from tools import sdu_auto_remediation


def _git(repo: Path, *args: str) -> subprocess.CompletedProcess[str]:
    return subprocess.run(["git", *args], cwd=repo, text=True, capture_output=True, check=True)


def test_auto_remediation_loads_config() -> None:
    config = sdu_auto_remediation.load_config()
    assert config["mode"] == "LOCAL_ONLY"
    assert config["policies"]["secret_risk"] == "BLOCK_HARD"


def test_analyze_maps_clean_repo_to_no_drift(monkeypatch) -> None:
    monkeypatch.setattr(sdu_auto_remediation, "_git_status", lambda root: [])
    payload = sdu_auto_remediation.analyze()
    assert payload["drift"] == "NO_DRIFT"
    assert payload["recommended_action"] == "none"


def test_secret_risk_blocks_without_mutation(tmp_path: Path, monkeypatch) -> None:
    event_path = tmp_path / "events.jsonl"
    monkeypatch.setattr(sdu_auto_remediation.sdu_sentinel, "EVENTS_PATH", event_path)
    payload = sdu_auto_remediation.remediate("SECRET_RISK_DRIFT", root=tmp_path, apply=True)
    assert payload["status"] == "BLOCK"
    assert payload["action"] == "block"


def test_simulate_logs_remediation_event(tmp_path: Path, monkeypatch) -> None:
    event_path = tmp_path / "events.jsonl"
    monkeypatch.setattr(sdu_auto_remediation.sdu_sentinel, "EVENTS_PATH", event_path)
    payload = sdu_auto_remediation.simulate("EVIDENCE_GAP_DRIFT")
    assert payload["action"] == "regenerate_readback"
    parsed = json.loads(event_path.read_text(encoding="utf-8").splitlines()[-1])
    assert parsed["remediation"]["action"] == "regenerate_readback"


def test_rollback_restores_tracked_file(tmp_path: Path) -> None:
    repo = tmp_path / "repo"
    repo.mkdir()
    _git(repo, "init")
    _git(repo, "config", "user.email", "sdu@example.local")
    _git(repo, "config", "user.name", "SDU Test")
    target = repo / "file.txt"
    target.write_text("stable\n", encoding="utf-8")
    _git(repo, "add", "file.txt")
    _git(repo, "commit", "-m", "baseline")
    target.write_text("drift\n", encoding="utf-8")

    payload = sdu_auto_remediation.rollback_target("file.txt", repo, apply=True)

    assert payload["result"] == "success"
    assert target.read_text(encoding="utf-8") == "stable\n"


def test_rollback_blocks_untracked_target(tmp_path: Path) -> None:
    repo = tmp_path / "repo"
    repo.mkdir()
    _git(repo, "init")
    target = repo / "new.txt"
    target.write_text("new\n", encoding="utf-8")
    payload = sdu_auto_remediation.rollback_target("new.txt", repo, apply=True)
    assert payload["status"] == "BLOCK"
    assert payload["result"] == "untracked_target"
