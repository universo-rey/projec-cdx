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


def _commit_all(repo: Path, message: str) -> None:
    _git(repo, "add", ".")
    _git(repo, "commit", "-m", message)


def test_save_snapshot_records_commit_and_hash(tmp_path: Path) -> None:
    _seed_repo(tmp_path)
    payload = cli.save_snapshot(root=tmp_path)

    snapshot_path = tmp_path / payload["path"]
    saved = json.loads(snapshot_path.read_text(encoding="utf-8"))

    assert saved["git"]["commit"] == _git(tmp_path, "rev-parse", "HEAD").stdout.strip()
    assert saved["global_hash"]
    assert saved["tree"]["tracked_file_count"] >= 4
    assert saved["version"]
    assert (tmp_path / "operativa" / "snapshots" / "SNAPSHOT_INDEX.json").exists()
    assert (tmp_path / "VERSION_STATE.json").exists()


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
    _commit_all(tmp_path, "snapshot")
    result = cli.restore_snapshot(str(payload["snapshot_id"]), root=tmp_path)

    assert result["mode"] == "DRY_RUN"
    assert result["commit"] == payload["git"]["commit"]


def test_snapshot_index_records_nested_snapshots(tmp_path: Path) -> None:
    _seed_repo(tmp_path)
    payload = cli.save_snapshot(root=tmp_path, version="v0.6.0-rc1", event_type="pre-merge")
    index = cli.build_snapshot_index(root=tmp_path)

    assert index["total"] == 1
    assert index["snapshots"][0]["snapshot_id"] == payload["snapshot_id"]
    assert index["snapshots"][0]["version"] == "v0.6.0-rc1"
    assert "v0.6.0-rc1" in index["snapshots"][0]["path"]


def test_version_state_records_governance_rules(tmp_path: Path) -> None:
    _seed_repo(tmp_path)
    state = cli.write_version_state(root=tmp_path, version="v0.6.0-rc1")

    assert state["mode"] == "OPERACION_CONTINUA_GOBERNADA"
    assert state["version_actual"] == "v0.6.0-rc1"
    assert state["rules"]["no_version_without_snapshot"] is True
    assert "sentinel-runtime" in state["agents_active"]


def test_runtime_status_outputs_core_fields(tmp_path: Path) -> None:
    _seed_repo(tmp_path)
    payload = cli.save_snapshot(root=tmp_path, version="v0.6.0-rc1")
    _commit_all(tmp_path, "snapshot")
    status = cli.runtime_status(root=tmp_path)

    assert status["status"] == "OK"
    assert status["version"] == "v0.6.0-rc1"
    assert status["workspace"]["clean"] is True
    assert status["latest_snapshot"]["snapshot_id"] == payload["snapshot_id"]
    assert status["drift_detected"] is False


def test_continuous_cycle_creates_snapshot_and_g7_evidence(tmp_path: Path) -> None:
    _seed_repo(tmp_path)
    result = cli.run_continuous_cycle(
        root=tmp_path,
        event="workflow_dispatch",
        version="v0.6.0-rc1",
    )

    assert result["modo"] == "G7_MEJORA_CONTINUA_ACTIVO"
    assert result["drift"] == "NO_DRIFT"
    assert result["snapshot_base"].startswith("CEORUNTIME_")
    assert result["frontera"]["external_writes"] is False
    assert result["evidencia"]["report"].startswith("operativa/g7/")
    assert (tmp_path / result["evidencia"]["report"]).exists()
    assert (tmp_path / "operativa" / "HISTORY_CONTINUOUS_EVOLUTION.md").exists()


def test_powershell_wrappers_exist_or_documented() -> None:
    root = Path(__file__).resolve().parents[1]
    expected = [
        "ceo-runtime-save.ps1",
        "ceo-runtime-list.ps1",
        "ceo-runtime-restore.ps1",
        "ceo-runtime-sentinel.ps1",
        "ceo-runtime-status.ps1",
        "ceo-runtime-index.ps1",
        "ceo-runtime-state.ps1",
        "ceo-runtime-continuous.ps1",
    ]

    for name in expected:
        path = root / "tools" / name
        assert path.exists(), f"missing wrapper: {name}"
        content = path.read_text(encoding="utf-8")
        assert ".venv\\Scripts\\python.exe" in content
        assert "runtime_versioning.cli" in content
