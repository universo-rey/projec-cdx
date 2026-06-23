from __future__ import annotations

import json
import subprocess
from pathlib import Path

from runtime_versioning import cli


def _git(repo: Path, *args: str) -> subprocess.CompletedProcess[str]:
    return subprocess.run(["git", *args], cwd=repo, text=True, capture_output=True, check=True)


def _seed_repo(repo: Path) -> None:
    (repo / ".github" / "workflows").mkdir(parents=True)
    (repo / "operativa").mkdir()
    (repo / "schema.json").write_text("{}", encoding="utf-8")
    (repo / "index.json").write_text("[]", encoding="utf-8")
    (repo / "live-manifest.json").write_text('{"artifacts":[]}', encoding="utf-8")
    (repo / "pyproject.toml").write_text("[project]\nname='x'\n", encoding="utf-8")
    (repo / ".github" / "workflows" / "quality.yml").write_text("on: [push]\n", encoding="utf-8")
    _git(repo, "init")
    _git(repo, "config", "user.email", "sdu@example.local")
    _git(repo, "config", "user.name", "SDU Test")
    _git(repo, "add", ".")
    _git(repo, "commit", "-m", "baseline")


def test_save_snapshot_records_commit_and_hash(tmp_path: Path) -> None:
    _seed_repo(tmp_path)
    payload = cli.save_snapshot(root=tmp_path)

    snapshot_path = tmp_path / payload["path"]
    saved = json.loads(snapshot_path.read_text(encoding="utf-8"))

    assert saved["git"]["commit"] == _git(tmp_path, "rev-parse", "HEAD").stdout.strip()
    assert saved["global_hash"]
    assert saved["tree"]["tracked_file_count"] >= 4


def test_list_snapshots_reads_saved_payload(tmp_path: Path) -> None:
    _seed_repo(tmp_path)
    payload = cli.save_snapshot(root=tmp_path)
    rows = cli.list_snapshots(root=tmp_path)

    assert rows[0]["snapshot_id"] == payload["snapshot_id"]
    assert rows[0]["commit"] == payload["git"]["commit"]


def test_restore_blocks_dirty_workspace(tmp_path: Path) -> None:
    _seed_repo(tmp_path)
    payload = cli.save_snapshot(root=tmp_path)
    (tmp_path / "dirty.txt").write_text("dirty\n", encoding="utf-8")

    try:
        cli.restore_snapshot(str(payload["snapshot_id"]), root=tmp_path)
    except cli.RuntimeErrorMessage as exc:
        assert "DIRTY_WORKSPACE" in str(exc)
    else:
        raise AssertionError("restore must block dirty workspace")


def test_restore_dry_run_reports_commit(tmp_path: Path) -> None:
    _seed_repo(tmp_path)
    payload = cli.save_snapshot(root=tmp_path)
    _git(tmp_path, "add", payload["path"])
    _git(tmp_path, "commit", "-m", "snapshot")
    result = cli.restore_snapshot(str(payload["snapshot_id"]), root=tmp_path)

    assert result["mode"] == "DRY_RUN"
    assert result["commit"] == payload["git"]["commit"]
