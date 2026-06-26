from __future__ import annotations

import argparse
import csv
import hashlib
import json
import os
import platform
import subprocess
import sys
from collections.abc import Iterable
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[2]
SNAPSHOT_DIR = ROOT / "operativa" / "snapshots"
SENTINEL_DIR = ROOT / "operativa" / "sentinel"
RUNTIME_EVENTS_DIR = ROOT / "operativa" / "runtime-events"
VERSION_STATE_PATH = ROOT / "VERSION_STATE.json"
SNAPSHOT_INDEX_PATH = SNAPSHOT_DIR / "SNAPSHOT_INDEX.json"
DRIFT_LOG_PATH = SENTINEL_DIR / "DRIFT_LOG.json"
HISTORY_PATH = ROOT / "operativa" / "HISTORY_RUNTIME_EVOLUTION.md"
CONTINUOUS_HISTORY_PATH = ROOT / "operativa" / "HISTORY_CONTINUOUS_EVOLUTION.md"
SNAPSHOT_PREFIX = "CEORUNTIME"
DEFAULT_VERSION = "v0.6.0-rc1"

ACTIVE_AGENTS = [
    "thot-tecnico",
    "maat-cumplimiento",
    "horus-riesgo",
    "anubis-gate",
    "seshat-normativa",
    "sentinel-runtime",
    "narrador-normativo",
    "EATOMIC",
]

WATCHED_RUNTIME_FILES = [
    "schema.json",
    "index.json",
    "live-manifest.json",
    "pyproject.toml",
    ".github/workflows/build-graph.yml",
    ".github/workflows/codeql.yml",
    ".github/workflows/meta-validate.yml",
    ".github/workflows/quality.yml",
]


class RuntimeErrorMessage(RuntimeError):
    """Expected CLI failure with a sanitized message."""


def _utc_now() -> datetime:
    return datetime.now(timezone.utc)


def _timestamp_id(now: datetime | None = None) -> str:
    return (now or _utc_now()).strftime("%Y%m%d_%H%M")


def _today_iso(now: datetime | None = None) -> str:
    return (now or _utc_now()).date().isoformat()


def _run(command: list[str], root: Path) -> subprocess.CompletedProcess[str]:
    return subprocess.run(command, cwd=root, text=True, capture_output=True)


def _git(root: Path, *args: str) -> str:
    result = _run(["git", *args], root)
    if result.returncode != 0:
        detail = result.stderr.strip() or result.stdout.strip() or "git command failed"
        raise RuntimeErrorMessage(detail)
    return result.stdout.strip()


def _git_status(root: Path) -> list[str]:
    result = _run(["git", "status", "--porcelain=v1"], root)
    if result.returncode != 0:
        raise RuntimeErrorMessage(result.stderr.strip() or "git status failed")
    return [line for line in result.stdout.splitlines() if line.strip()]


def _sha256_bytes(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def _sha256_file(path: Path) -> str | None:
    if not path.exists() or not path.is_file():
        return None
    return _sha256_bytes(path.read_bytes())


def _load_json(path: Path) -> Any:
    if not path.exists():
        return None
    return json.loads(path.read_text(encoding="utf-8"))


def _write_json(path: Path, payload: Any) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(payload, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")


def _write_csv(path: Path, rows: list[dict[str, Any]], fieldnames: list[str]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=fieldnames)
        writer.writeheader()
        for row in rows:
            writer.writerow({field: row.get(field, "") for field in fieldnames})


def _relative(path: Path, root: Path) -> str:
    return path.resolve().relative_to(root.resolve()).as_posix()


def _safe_version_segment(version: str) -> str:
    return "".join(ch if ch.isalnum() or ch in ".-_" else "_" for ch in version) or DEFAULT_VERSION


def _nearest_version(root: Path) -> str:
    exact_tags = [line for line in _git(root, "tag", "--points-at", "HEAD").splitlines() if line]
    version_tags = sorted(tag for tag in exact_tags if tag.startswith("v"))
    if version_tags:
        return version_tags[-1]
    result = _run(["git", "describe", "--tags", "--abbrev=0", "--match", "v*"], root)
    if result.returncode == 0 and result.stdout.strip():
        return result.stdout.strip()
    return DEFAULT_VERSION


def _snapshot_version_dir(root: Path, version: str) -> Path:
    return root / "operativa" / "snapshots" / _safe_version_segment(version)


def _current_branch(root: Path) -> str:
    return _git(root, "branch", "--show-current")


def _current_commit(root: Path) -> str:
    return _git(root, "rev-parse", "HEAD")


def _tracked_tree_hash(root: Path, ref: str) -> dict[str, Any]:
    lines = _git(root, "ls-tree", "-r", ref).splitlines()
    entries: list[dict[str, str]] = []
    digest = hashlib.sha256()
    for line in lines:
        if not line:
            continue
        meta, file_path = line.split("\t", 1)
        mode, object_type, object_hash = meta.split(" ", 2)
        normalized = file_path.replace("\\", "/")
        entries.append(
            {
                "path": normalized,
                "mode": mode,
                "type": object_type,
                "object": object_hash,
            }
        )
        digest.update(f"{mode} {object_type} {object_hash}\t{normalized}\n".encode())
    return {"tracked_file_count": len(entries), "tree_hash": digest.hexdigest()}


def _top_level_structure(root: Path, ref: str) -> dict[str, Any]:
    directories: set[str] = set()
    files: set[str] = set()
    for line in _git(root, "ls-tree", "-r", "--name-only", ref).splitlines():
        if not line:
            continue
        parts = line.replace("\\", "/").split("/")
        if len(parts) == 1:
            files.add(parts[0])
        else:
            directories.add(parts[0])
    return {"directories": sorted(directories), "files": sorted(files)}


def _metadata_summary(root: Path) -> dict[str, Any]:
    index_payload = _load_json(root / "index.json")
    manifest_payload = _load_json(root / "live-manifest.json")
    if isinstance(index_payload, list):
        index_items = index_payload
    elif isinstance(index_payload, dict) and isinstance(index_payload.get("items"), list):
        index_items = index_payload["items"]
    else:
        index_items = []
    artifact_ids = [
        str(item.get("artifact_id"))
        for item in index_items
        if isinstance(item, dict) and item.get("artifact_id")
    ]
    live_items = []
    if isinstance(manifest_payload, dict):
        live_items = [str(item) for item in manifest_payload.get("artifacts", []) if item]
    return {
        "index_sha256": _sha256_file(root / "index.json"),
        "live_manifest_sha256": _sha256_file(root / "live-manifest.json"),
        "metadata_count": len(index_items),
        "metadata_keys": sorted(artifact_ids),
        "live_artifacts": sorted(live_items),
    }


def _ci_summary(root: Path) -> dict[str, Any]:
    workflows_root = root / ".github" / "workflows"
    workflows: list[dict[str, str | None]] = []
    if workflows_root.exists():
        for path in sorted(workflows_root.glob("*.yml")):
            workflows.append({"path": _relative(path, root), "sha256": _sha256_file(path)})
        for path in sorted(workflows_root.glob("*.yaml")):
            workflows.append({"path": _relative(path, root), "sha256": _sha256_file(path)})
    return {"workflow_count": len(workflows), "workflows": workflows}


def _environment_summary(root: Path) -> dict[str, Any]:
    keys = [
        "CEO_ROOT",
        "CEO_PROJECT_ROOT",
        "CODEX_HOME",
        "CODEX_START_ROOT",
        "CODEX_PROJECT_ROOT",
        "CODEX_WORKBENCH_ROOT",
        "CODEX_METADATA_ROOT",
        "CODEX_SOURCE_TREE_PATH",
        "CODEX_WORKTREE_PATH",
        "CODEX_PAC_PATH",
    ]
    return {
        "platform": platform.platform(),
        "python_version": platform.python_version(),
        "python_executable": sys.executable,
        "cwd": str(root),
        "env_keys_present": {key: bool(os.environ.get(key)) for key in keys},
    }


def _version_state_payload(
    root: Path,
    version: str | None = None,
    latest_snapshot: dict[str, Any] | None = None,
) -> dict[str, Any]:
    root = root.resolve()
    status_lines = [
        line for line in _git_status(root) if not line.strip().endswith("VERSION_STATE.json")
    ]
    current_version = version or _nearest_version(root)
    branch = _current_branch(root)
    commit = _current_commit(root)
    baseline = _nearest_version(root)
    ahead_count = 0
    if baseline:
        ahead_result = _run(["git", "rev-list", "--count", f"{baseline}..HEAD"], root)
        if ahead_result.returncode == 0 and ahead_result.stdout.strip().isdigit():
            ahead_count = int(ahead_result.stdout.strip())
    return {
        "schema_version": "1.0",
        "mode": "OPERACION_CONTINUA_GOBERNADA",
        "version_actual": current_version,
        "baseline_version": baseline,
        "branch": branch,
        "commit": commit,
        "commits_ahead_baseline": ahead_count,
        "generated_at_utc": _utc_now().isoformat(timespec="seconds").replace("+00:00", "Z"),
        "dirty": bool(status_lines),
        "status": status_lines,
        "rules": {
            "merge_to_main": "PATCH",
            "structural_change_agents_gates_runtime": "MINOR",
            "architecture_model_change": "MAJOR",
            "codex_branch": "RC_AUTOMATICO",
            "no_version_without_snapshot": True,
            "no_merge_without_snapshot": True,
            "no_release_without_snapshot_and_checks": True,
        },
        "snapshot_policy": {
            "pre_merge": "REQUIRED",
            "post_merge": "REQUIRED",
            "pre_release": "REQUIRED",
            "pre_restore": "REQUIRED",
            "config_change": "REQUIRED",
        },
        "restore_policy": {
            "requires_clean_workspace": True,
            "requires_explicit_yes": True,
            "creates_pre_restore_backup": True,
            "validates_after_apply": True,
        },
        "watchdog": {
            "metadata_drift": "ALERTA_DRIFT",
            "structure_drift": "ALERTA_DRIFT",
            "ci_config_drift": "ALERTA_DRIFT",
            "dependency_drift": "ALERTA_DRIFT",
        },
        "agents_active": ACTIVE_AGENTS,
        "latest_snapshot": latest_snapshot,
    }


def write_version_state(
    root: Path = ROOT,
    version: str | None = None,
    latest_snapshot: dict[str, Any] | None = None,
) -> dict[str, Any]:
    payload = _version_state_payload(root.resolve(), version, latest_snapshot)
    _write_json(root / "VERSION_STATE.json", payload)
    payload["path"] = "VERSION_STATE.json"
    return payload


def _snapshot_payload(
    root: Path,
    ref: str,
    allow_dirty: bool,
    version: str | None = None,
    event_type: str = "manual",
) -> dict[str, Any]:
    status_lines = _git_status(root)
    if status_lines and not allow_dirty:
        raise RuntimeErrorMessage(
            "WORKSPACE_DIRTY: create a clean snapshot or pass --allow-dirty for diagnostic captures"
        )
    commit = _git(root, "rev-parse", ref)
    branch = _git(root, "branch", "--show-current")
    tags = [line for line in _git(root, "tag", "--points-at", commit).splitlines() if line]
    version_tags = sorted(tag for tag in tags if tag.startswith("v"))
    resolved_version = version or (version_tags[-1] if version_tags else _nearest_version(root))
    tree = _tracked_tree_hash(root, commit)
    watched = {
        path: _sha256_file(root / path) for path in WATCHED_RUNTIME_FILES if (root / path).exists()
    }

    payload: dict[str, Any] = {
        "schema_version": "1.0",
        "snapshot_id": f"{SNAPSHOT_PREFIX}_{_timestamp_id()}",
        "version": resolved_version,
        "event_type": event_type,
        "created_at_utc": _utc_now().isoformat(timespec="seconds").replace("+00:00", "Z"),
        "repo_root": str(root),
        "git": {
            "ref": ref,
            "commit": commit,
            "branch": branch,
            "tags": sorted(tags),
            "dirty": bool(status_lines),
            "status": status_lines,
        },
        "structure": _top_level_structure(root, commit),
        "metadata": _metadata_summary(root),
        "ci": _ci_summary(root),
        "watched_hashes": watched,
        "tree": tree,
        "environment": _environment_summary(root),
        "agents_active": ACTIVE_AGENTS,
        "gates": {
            "merge_requires_snapshot": True,
            "release_requires_snapshot_and_checks": True,
            "restore_requires_clean_workspace": True,
            "live_requires_explicit_gate": True,
        },
        "restore_policy": {
            "requires_clean_workspace": True,
            "requires_explicit_yes": True,
            "default_mode": "DRY_RUN",
            "pre_restore_backup": True,
        },
    }
    canonical = json.dumps(payload, sort_keys=True, ensure_ascii=False).encode("utf-8")
    payload["global_hash"] = _sha256_bytes(canonical)
    return payload


def _next_snapshot_path(snapshot_dir: Path, snapshot_id: str) -> Path:
    snapshot_dir.mkdir(parents=True, exist_ok=True)
    base = snapshot_dir / f"{snapshot_id}.json"
    if not base.exists():
        return base
    idx = 2
    while True:
        candidate = snapshot_dir / f"{snapshot_id}_{idx:02d}.json"
        if not candidate.exists():
            return candidate
        idx += 1


def _snapshot_files(root: Path, snapshot_dir: Path | None = None) -> list[Path]:
    directory = snapshot_dir or root / "operativa" / "snapshots"
    if not directory.exists():
        return []
    return sorted(
        path
        for path in directory.rglob(f"{SNAPSHOT_PREFIX}_*.json")
        if path.name != "SNAPSHOT_INDEX.json"
    )


def build_snapshot_index(root: Path = ROOT, write: bool = True) -> dict[str, Any]:
    root = root.resolve()
    rows: list[dict[str, Any]] = []
    for path in _snapshot_files(root):
        payload = _load_json(path)
        if not isinstance(payload, dict):
            continue
        rows.append(
            {
                "snapshot_id": payload.get("snapshot_id", path.stem),
                "version": payload.get("version"),
                "commit": payload.get("git", {}).get("commit"),
                "branch": payload.get("git", {}).get("branch"),
                "fecha": payload.get("created_at_utc"),
                "tipo": payload.get("event_type", "manual"),
                "dirty": payload.get("git", {}).get("dirty"),
                "global_hash": payload.get("global_hash"),
                "path": _relative(path, root),
            }
        )
    payload = {
        "schema_version": "1.0",
        "generated_at_utc": _utc_now().isoformat(timespec="seconds").replace("+00:00", "Z"),
        "total": len(rows),
        "snapshots": sorted(rows, key=lambda item: str(item.get("fecha") or "")),
    }
    if write:
        _write_json(root / "operativa" / "snapshots" / "SNAPSHOT_INDEX.json", payload)
    return payload


def _front_matter(
    artifact_id: str,
    tipo: str,
    descripcion: str,
    etiquetas: list[str],
    relacionados: list[str] | None = None,
    version: str = DEFAULT_VERSION,
) -> str:
    related = relacionados or []
    lines = [
        "---",
        f"artifact_id: {artifact_id}",
        "categoria: operativa",
        f"tipo: {tipo}",
        "estado: aprobado",
        f"version: {version}",
        f"fecha_evento: '{_today_iso()}'",
        "autoridad:",
        "  tipo: sistema",
        "  referencia: CABINA_GOBIERNO_TOTAL",
        "origen: GitHub",
        f"ubicacion_repo: {artifact_id}",
        "etiquetas:",
        *[f"  - {item}" for item in etiquetas],
        "relacionados:",
        *([f"  - {item}" for item in related] if related else []),
        f"descripcion: {descripcion}",
        "---",
        "",
    ]
    if not related:
        insert_at = lines.index("relacionados:") + 1
        lines.insert(insert_at, "  []")
    return "\n".join(lines)


def _write_runtime_event_acta(
    root: Path,
    event_name: str,
    title: str,
    body_lines: list[str],
    version: str,
    relacionados: list[str] | None = None,
) -> Path:
    safe_event = "".join(ch if ch.isalnum() or ch in "_-" else "_" for ch in event_name.upper())
    artifact_id = f"operativa/runtime-events/ACTA_{safe_event}.md"
    path = root / artifact_id
    path.parent.mkdir(parents=True, exist_ok=True)
    content = _front_matter(
        artifact_id=artifact_id,
        tipo="acta",
        descripcion=f"Acta runtime {event_name} generada por operacion continua.",
        etiquetas=["runtime", "snapshot", "watchdog"],
        relacionados=relacionados,
        version=version,
    )
    content += f"# {title}\n\n" + "\n".join(body_lines).rstrip() + "\n"
    path.write_text(content, encoding="utf-8")
    return path


def _append_history(root: Path, line: str, version: str) -> None:
    path = root / "operativa" / "HISTORY_RUNTIME_EVOLUTION.md"
    if not path.exists():
        content = _front_matter(
            artifact_id="operativa/HISTORY_RUNTIME_EVOLUTION.md",
            tipo="reporte",
            descripcion="Timeline de versiones, snapshots y eventos criticos del runtime gobernado.",
            etiquetas=["runtime", "historytelling", "snapshots"],
            relacionados=["VERSION_POLICY.md", "VERSION_STATE.json"],
            version=version,
        )
        content += "# HISTORY RUNTIME EVOLUTION\n\n"
    else:
        content = path.read_text(encoding="utf-8")
        if not content.endswith("\n"):
            content += "\n"
    content += line.rstrip() + "\n"
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content, encoding="utf-8")


def _append_continuous_history(root: Path, line: str, version: str) -> None:
    path = root / "operativa" / "HISTORY_CONTINUOUS_EVOLUTION.md"
    if not path.exists():
        content = _front_matter(
            artifact_id="operativa/HISTORY_CONTINUOUS_EVOLUTION.md",
            tipo="reporte",
            descripcion="Timeline de auditoria, divergencias, reconciliaciones y ajustes G7.",
            etiquetas=["runtime", "g7", "mejora-continua"],
            relacionados=["VERSION_STATE.json", "operativa/snapshots/SNAPSHOT_INDEX.json"],
            version=version,
        )
        content += "# HISTORY CONTINUOUS EVOLUTION\n\n"
    else:
        content = path.read_text(encoding="utf-8")
        if not content.endswith("\n"):
            content += "\n"
    content += line.rstrip() + "\n"
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content, encoding="utf-8")


def save_snapshot(
    root: Path = ROOT,
    ref: str = "HEAD",
    allow_dirty: bool = False,
    snapshot_dir: Path | None = None,
    version: str | None = None,
    event_type: str = "manual",
    write_acta: bool = True,
) -> dict[str, Any]:
    root = root.resolve()
    payload = _snapshot_payload(root, ref, allow_dirty, version=version, event_type=event_type)
    output_dir = snapshot_dir or _snapshot_version_dir(root, str(payload["version"]))
    path = _next_snapshot_path(output_dir, str(payload["snapshot_id"]))
    final_snapshot_id = path.stem
    if final_snapshot_id != payload["snapshot_id"]:
        payload["snapshot_id"] = final_snapshot_id
        payload.pop("global_hash", None)
        canonical = json.dumps(payload, sort_keys=True, ensure_ascii=False).encode("utf-8")
        payload["global_hash"] = _sha256_bytes(canonical)
    _write_json(path, payload)
    payload["path"] = _relative(path, root)
    index = build_snapshot_index(root, write=True)
    latest = index["snapshots"][-1] if index["snapshots"] else None
    write_version_state(root, version=str(payload["version"]), latest_snapshot=latest)
    if write_acta:
        acta_path = _write_runtime_event_acta(
            root=root,
            event_name=f"SNAPSHOT_{payload['snapshot_id']}",
            title=f"ACTA SNAPSHOT {payload['snapshot_id']}",
            body_lines=[
                "## Estado",
                "",
                "`SNAPSHOT_CREATED`",
                "",
                "## Version",
                "",
                f"`{payload['version']}`",
                "",
                "## Commit",
                "",
                f"`{payload['git']['commit']}`",
                "",
                "## Resultado",
                "",
                "`SNAPSHOT_INDEX_UPDATED`",
            ],
            version=str(payload["version"]),
            relacionados=[payload["path"], "operativa/snapshots/SNAPSHOT_INDEX.json"],
        )
        payload["acta_path"] = _relative(acta_path, root)
    _append_history(
        root,
        f"- `{payload['created_at_utc']}` snapshot `{payload['snapshot_id']}` version `{payload['version']}` commit `{payload['git']['commit']}`.",
        str(payload["version"]),
    )
    return payload


def list_snapshots(root: Path = ROOT, snapshot_dir: Path | None = None) -> list[dict[str, Any]]:
    rows: list[dict[str, Any]] = []
    for path in _snapshot_files(root.resolve(), snapshot_dir):
        payload = _load_json(path)
        if not isinstance(payload, dict):
            continue
        rows.append(
            {
                "snapshot_id": payload.get("snapshot_id", path.stem),
                "version": payload.get("version"),
                "created_at_utc": payload.get("created_at_utc"),
                "event_type": payload.get("event_type", "manual"),
                "commit": payload.get("git", {}).get("commit"),
                "branch": payload.get("git", {}).get("branch"),
                "tags": payload.get("git", {}).get("tags", []),
                "dirty": payload.get("git", {}).get("dirty"),
                "global_hash": payload.get("global_hash"),
                "path": _relative(path, root),
            }
        )
    return sorted(rows, key=lambda item: str(item.get("created_at_utc") or ""))


def _resolve_snapshot(root: Path, snapshot_id: str) -> Path:
    candidate = Path(snapshot_id)
    if candidate.exists():
        return candidate.resolve()
    if not candidate.is_absolute():
        repo_candidate = root / snapshot_id
        if repo_candidate.exists():
            return repo_candidate.resolve()
    for path in _snapshot_files(root):
        if path.stem == snapshot_id or path.name == snapshot_id:
            return path.resolve()
    raise RuntimeErrorMessage(f"SNAPSHOT_NOT_FOUND: {snapshot_id}")


def restore_snapshot(
    snapshot_id: str,
    root: Path = ROOT,
    apply: bool = False,
    yes: bool = False,
) -> dict[str, Any]:
    root = root.resolve()
    status_lines = _git_status(root)
    if status_lines:
        raise RuntimeErrorMessage("RESTORE_BLOCKED_DIRTY_WORKSPACE")
    path = _resolve_snapshot(root, snapshot_id)
    payload = _load_json(path)
    if not isinstance(payload, dict):
        raise RuntimeErrorMessage("SNAPSHOT_INVALID_JSON")
    commit = str(payload.get("git", {}).get("commit") or "")
    if not commit:
        raise RuntimeErrorMessage("SNAPSHOT_WITHOUT_COMMIT")
    object_check = _run(["git", "cat-file", "-t", commit], root)
    if object_check.returncode != 0 or object_check.stdout.strip() != "commit":
        raise RuntimeErrorMessage("RESTORE_BLOCKED_COMMIT_NOT_LOCAL")
    result = {
        "status": "PASS",
        "mode": "APPLY" if apply else "DRY_RUN",
        "snapshot_id": payload.get("snapshot_id", path.stem),
        "snapshot_path": _relative(path, root),
        "commit": commit,
        "would_checkout": commit,
        "requires_clean_workspace": True,
    }
    if not apply:
        result["result"] = "dry_run"
        return result
    if not yes:
        raise RuntimeErrorMessage("RESTORE_REQUIRES_EXPLICIT_YES")
    backup = save_snapshot(
        root=root,
        ref="HEAD",
        allow_dirty=False,
        version=str(payload.get("version") or _nearest_version(root)),
        event_type="pre-restore",
    )
    checkout = _run(["git", "checkout", "--detach", commit], root)
    if checkout.returncode != 0:
        raise RuntimeErrorMessage(checkout.stderr.strip() or "git checkout failed")
    result["result"] = "restored_detached_head"
    result["backup_snapshot_id"] = backup.get("snapshot_id")
    result["backup_snapshot_path"] = backup.get("path")
    post_validate = _run([sys.executable, "-m", "tools.validate"], root)
    result["post_restore_validation"] = {
        "metadata_validate": "PASS" if post_validate.returncode == 0 else "FAIL",
    }
    event_path = _write_runtime_event_acta(
        root=root,
        event_name=f"RESTORE_{payload.get('snapshot_id', path.stem)}",
        title=f"ACTA RESTORE {payload.get('snapshot_id', path.stem)}",
        body_lines=[
            "## Estado",
            "",
            "`RESTORE_APPLIED_DETACHED_HEAD`",
            "",
            "## Snapshot",
            "",
            f"`{payload.get('snapshot_id', path.stem)}`",
            "",
            "## Backup previo",
            "",
            f"`{backup.get('snapshot_id')}`",
            "",
            "## Validacion",
            "",
            f"`{result['post_restore_validation']['metadata_validate']}`",
        ],
        version=str(payload.get("version") or _nearest_version(root)),
        relacionados=[_relative(path, root), str(backup.get("path"))],
    )
    result["acta_path"] = _relative(event_path, root)
    return result


def _append_drift_log(root: Path, report: dict[str, Any]) -> None:
    log_path = root / "operativa" / "sentinel" / "DRIFT_LOG.json"
    existing = _load_json(log_path)
    if not isinstance(existing, dict):
        existing = {"schema_version": "1.0", "events": []}
    events = existing.setdefault("events", [])
    if isinstance(events, list):
        events.append(
            {
                "report_id": report.get("report_id"),
                "created_at_utc": report.get("created_at_utc"),
                "status": report.get("status"),
                "drift_detected": report.get("drift_detected"),
                "checks": report.get("checks"),
                "git_status": report.get("git_status", []),
                "alert": "ALERTA_DRIFT",
            }
        )
    _write_json(log_path, existing)


def build_sentinel_report(root: Path = ROOT, output: Path | None = None) -> dict[str, Any]:
    root = root.resolve()
    status_lines = _git_status(root)
    validate_result = _run([sys.executable, "-m", "tools.validate"], root)
    snapshots = list_snapshots(root)
    latest_snapshot = snapshots[-1] if snapshots else None
    version_state = _version_state_payload(root, latest_snapshot=latest_snapshot)
    report = {
        "report_id": f"SENTINEL_RUNTIME_{_timestamp_id()}",
        "created_at_utc": _utc_now().isoformat(timespec="seconds").replace("+00:00", "Z"),
        "status": "PASS" if validate_result.returncode == 0 and not status_lines else "WARN",
        "drift_detected": bool(status_lines),
        "checks": {
            "git_clean": "PASS" if not status_lines else "WARN",
            "metadata_validate": "PASS" if validate_result.returncode == 0 else "FAIL",
            "snapshot_available": "PASS" if latest_snapshot else "WARN",
        },
        "git_status": status_lines,
        "latest_snapshot": latest_snapshot,
        "version_state": {
            "version_actual": version_state.get("version_actual"),
            "branch": version_state.get("branch"),
            "commit": version_state.get("commit"),
        },
        "watched_hashes": {
            path: _sha256_file(root / path)
            for path in WATCHED_RUNTIME_FILES
            if (root / path).exists()
        },
        "no_external": True,
    }
    output_path = output or root / "operativa" / "sentinel" / "SENTINEL_REPORT.json"
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(
        json.dumps(report, indent=2, ensure_ascii=False) + "\n", encoding="utf-8"
    )
    if report["status"] != "PASS" or report["drift_detected"]:
        _append_drift_log(root, report)
    report["path"] = _relative(output_path, root)
    return report


def runtime_status(root: Path = ROOT) -> dict[str, Any]:
    root = root.resolve()
    status_lines = _git_status(root)
    snapshots = list_snapshots(root)
    latest_snapshot = snapshots[-1] if snapshots else None
    state_payload = _load_json(root / "VERSION_STATE.json")
    if not isinstance(state_payload, dict):
        state_payload = _version_state_payload(root, latest_snapshot=latest_snapshot)
    return {
        "status": "OK" if not status_lines else "WARN",
        "version": state_payload.get("version_actual") or _nearest_version(root),
        "branch": _current_branch(root),
        "commit": _current_commit(root),
        "workspace": {
            "root": str(root),
            "clean": not bool(status_lines),
            "status": status_lines,
        },
        "latest_snapshot": latest_snapshot,
        "drift_detected": bool(status_lines),
        "validaciones_disponibles": {
            "metadata": "python -m tools.validate",
            "sdu_sentinel_scan": "python tools/sdu_sentinel.py scan",
            "sdu_auto_remediation": "python tools/sdu_auto_remediation.py analyze",
            "sdu_sentinel_check": "python tools/sdu_sentinel.py check",
            "pytest": "python -m pytest -q",
            "git_diff_check": "git diff --check",
        },
        "frontera": {
            "no_external": True,
            "no_live": True,
            "no_secret_read": True,
            "status_is_read_only": True,
        },
    }


def _g7_event_policy(event: str) -> dict[str, Any]:
    normalized = event.strip() or "manual"
    trigger_map = {
        "pull_request": "PR_OPENED_OR_UPDATED",
        "push": "MERGE_OR_MAIN_PUSH",
        "release": "TAG_OR_RELEASE",
        "workflow_dispatch": "MANUAL_GOVERNED_AUDIT",
        "manual": "MANUAL_GOVERNED_AUDIT",
    }
    return {
        "event": normalized,
        "trigger": trigger_map.get(normalized, "MANUAL_GOVERNED_AUDIT"),
        "requires_snapshot": True,
        "requires_postcheck": True,
        "external_writes_allowed": False,
        "live_allowed": False,
    }


def _g7_divergences(root: Path, status_lines: list[str]) -> list[dict[str, Any]]:
    divergences: list[dict[str, Any]] = []
    if status_lines:
        divergences.append(
            {
                "divergence_case_id": "G7-DIV-001",
                "origenes": "git_status",
                "diferencias": "; ".join(status_lines),
                "severidad": "MEDIA",
                "version_dominante": "workspace_actual_con_snapshot",
                "version_obsoleta": "ultimo_commit_limpio",
                "unified_canonical_rule": (
                    "prevalece el estado limpio versionado; cambios locales requieren "
                    "readback, snapshot y commit logico"
                ),
                "decision": "REQUIERE_RECONCILIACION",
            }
        )
    state_payload = _load_json(root / "VERSION_STATE.json")
    if not isinstance(state_payload, dict):
        divergences.append(
            {
                "divergence_case_id": "G7-DIV-002",
                "origenes": "VERSION_STATE.json",
                "diferencias": "VERSION_STATE_MISSING_OR_INVALID",
                "severidad": "MAYOR",
                "version_dominante": "runtime_cli_state",
                "version_obsoleta": "missing_state_file",
                "unified_canonical_rule": "VERSION_STATE.json debe existir antes de merge/release",
                "decision": "REQUIERE_AJUSTE",
            }
        )
    return divergences


def _g7_indicators(divergence_count: int, adjustment_count: int, drift: str) -> dict[str, Any]:
    return {
        "drift_rate": 0 if drift == "NO_DRIFT" else 1,
        "divergence_count": divergence_count,
        "ajuste_rate": adjustment_count,
        "estabilidad_runtime": (
            "ALTA" if drift == "NO_DRIFT" and divergence_count == 0 else "CONTROLADA"
        ),
    }


def run_continuous_cycle(
    root: Path = ROOT,
    event: str = "manual",
    version: str | None = None,
    output: Path | None = None,
    persist: bool = True,
) -> dict[str, Any]:
    root = root.resolve()
    status_before = _git_status(root)
    if status_before:
        raise RuntimeErrorMessage("G7_BLOCKED_DIRTY_WORKSPACE")
    resolved_version = version or _nearest_version(root)
    cycle_id = f"G7_{_timestamp_id()}"
    event_policy = _g7_event_policy(event)
    snapshot = save_snapshot(
        root=root,
        ref="HEAD",
        allow_dirty=False,
        version=resolved_version,
        event_type=f"g7-{event_policy['trigger'].lower()}",
        write_acta=persist,
    )
    divergences = _g7_divergences(root, status_before)
    divergence_count = len(divergences)
    resolved_count = sum(1 for item in divergences if item.get("decision") == "AUTO_RESOLVED")
    adjustment_count = 0
    drift = "NO_DRIFT" if divergence_count == 0 else "CONTROLADO"
    indicators = _g7_indicators(divergence_count, adjustment_count, drift)
    risk = "Bajo" if drift == "NO_DRIFT" else "Medio"
    status = "ESTABLE" if drift == "NO_DRIFT" else "EN_AJUSTE"

    report = {
        "modo": "G7_MEJORA_CONTINUA_ACTIVO",
        "cycle_id": cycle_id,
        "event": event_policy,
        "snapshot_base": snapshot.get("snapshot_id"),
        "snapshot_path": snapshot.get("path"),
        "divergencias_detectadas": divergence_count,
        "divergencias_resueltas": resolved_count,
        "ajustes_aplicados": adjustment_count,
        "drift": drift,
        "estado_sistema": status,
        "riesgo_evolutivo": risk,
        "agentes": ACTIVE_AGENTS,
        "indicadores": indicators,
        "frontera": {
            "no_external": True,
            "no_live": True,
            "no_secret_read": True,
            "external_writes": False,
            "workflow_dispatch_controlled": event_policy["event"] == "workflow_dispatch",
        },
        "observaciones": [
            "G7 crea snapshot previo y clasifica divergencias antes de proponer ajustes.",
            "La regla canonica es prevalecer por estado actual con gates completos y evidencia.",
            "No se ejecutan writes externos, live surfaces ni lectura de secretos.",
        ],
    }

    if persist:
        g7_dir = root / "operativa" / "g7"
        report_path = g7_dir / f"{cycle_id}_CONTINUOUS_CYCLE.json"
        divergence_path = g7_dir / f"{cycle_id}_DIVERGENCE_MATRIX.csv"
        indicators_path = g7_dir / f"{cycle_id}_SYSTEM_INDICATORS.csv"
        _write_json(report_path, report)
        _write_csv(
            divergence_path,
            divergences,
            [
                "divergence_case_id",
                "origenes",
                "diferencias",
                "severidad",
                "version_dominante",
                "version_obsoleta",
                "unified_canonical_rule",
                "decision",
            ],
        )
        _write_csv(
            indicators_path,
            [indicators],
            ["drift_rate", "divergence_count", "ajuste_rate", "estabilidad_runtime"],
        )
        related = [
            _relative(report_path, root),
            _relative(divergence_path, root),
            _relative(indicators_path, root),
            str(snapshot.get("path")),
        ]
        audit_path = _write_runtime_event_acta(
            root=root,
            event_name=f"G7_AUDIT_{cycle_id}",
            title=f"ACTA G7 AUDIT {cycle_id}",
            body_lines=[
                "## Estado",
                "",
                "`G7_AUDIT_COMPLETED`",
                "",
                "## Snapshot base",
                "",
                f"`{snapshot.get('snapshot_id')}`",
                "",
                "## Divergencias detectadas",
                "",
                f"`{divergence_count}`",
            ],
            version=resolved_version,
            relacionados=related,
        )
        reconciliation_path = _write_runtime_event_acta(
            root=root,
            event_name=f"G7_RECONCILIATION_{cycle_id}",
            title=f"ACTA G7 RECONCILIATION {cycle_id}",
            body_lines=[
                "## Estado",
                "",
                "`G7_RECONCILIATION_COMPLETED`",
                "",
                "## Regla canonica",
                "",
                "`prevalece estado actual + gates completos + evidencia`",
                "",
                "## Divergencias resueltas",
                "",
                f"`{resolved_count}`",
            ],
            version=resolved_version,
            relacionados=related,
        )
        adjustment_path = _write_runtime_event_acta(
            root=root,
            event_name=f"G7_ADJUSTMENT_{cycle_id}",
            title=f"ACTA G7 ADJUSTMENT {cycle_id}",
            body_lines=[
                "## Estado",
                "",
                "`G7_ADJUSTMENT_COMPLETED`",
                "",
                "## Ajustes aplicados",
                "",
                f"`{adjustment_count}`",
                "",
                "## Frontera",
                "",
                "`NO_EXTERNAL_NO_LIVE_NO_SECRETS`",
            ],
            version=resolved_version,
            relacionados=related,
        )
        _append_continuous_history(
            root,
            (
                f"- `{_utc_now().isoformat(timespec='seconds').replace('+00:00', 'Z')}` "
                f"ciclo `{cycle_id}` evento `{event_policy['trigger']}` "
                f"snapshot `{snapshot.get('snapshot_id')}` drift `{drift}` "
                f"divergencias `{divergence_count}` ajustes `{adjustment_count}`."
            ),
            resolved_version,
        )
        report["evidencia"] = {
            "report": _relative(report_path, root),
            "divergence_matrix": _relative(divergence_path, root),
            "indicators": _relative(indicators_path, root),
            "audit_acta": _relative(audit_path, root),
            "reconciliation_acta": _relative(reconciliation_path, root),
            "adjustment_acta": _relative(adjustment_path, root),
            "history": "operativa/HISTORY_CONTINUOUS_EVOLUTION.md",
        }
    else:
        report["evidencia"] = {"report": "stdout_or_output_file"}

    if output:
        _write_json(output if output.is_absolute() else root / output, report)
        report["output"] = str(output)
    return report


def _print_table(rows: list[dict[str, Any]]) -> None:
    if not rows:
        print("No snapshots found.")
        return
    headers = ["snapshot_id", "version", "event_type", "created_at_utc", "commit", "dirty", "path"]
    widths = {
        header: max(
            len(header),
            *[
                (
                    len(",".join(str(x) for x in row.get(header, [])))
                    if isinstance(row.get(header), list)
                    else len(str(row.get(header, "")))
                )
                for row in rows
            ],
        )
        for header in headers
    }
    print(" | ".join(header.ljust(widths[header]) for header in headers))
    print("-+-".join("-" * widths[header] for header in headers))
    for row in rows:
        values = []
        for header in headers:
            value = row.get(header, "")
            if isinstance(value, list):
                value = ",".join(str(item) for item in value)
            values.append(str(value).ljust(widths[header]))
        print(" | ".join(values))


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="CEO governed runtime snapshot CLI")
    parser.add_argument("--root", type=Path, default=ROOT, help="Repository root")
    subparsers = parser.add_subparsers(dest="command", required=True)

    save = subparsers.add_parser("save", help="Create a governed runtime snapshot")
    save.add_argument("--ref", default="HEAD", help="Git ref to snapshot")
    save.add_argument("--version", default=None, help="Version bucket for the snapshot")
    save.add_argument("--event-type", default="manual", help="Snapshot event type")
    save.add_argument("--allow-dirty", action="store_true", help="Allow diagnostic dirty snapshot")
    save.add_argument("--json", action="store_true", help="Print JSON payload")

    list_parser = subparsers.add_parser("list", help="List available snapshots")
    list_parser.add_argument("--json", action="store_true", help="Print JSON payload")

    index_parser = subparsers.add_parser("index", help="Rebuild governed snapshot index")
    index_parser.add_argument("--json", action="store_true", help="Print JSON payload")

    state_parser = subparsers.add_parser("state", help="Write governed version state")
    state_parser.add_argument("--version", default=None, help="Version to record")
    state_parser.add_argument("--json", action="store_true", help="Print JSON payload")

    restore = subparsers.add_parser("restore", help="Restore or dry-run restore from a snapshot")
    restore.add_argument("snapshot_id", help="Snapshot id or path")
    restore.add_argument("--apply", action="store_true", help="Apply checkout to snapshot commit")
    restore.add_argument("--yes", action="store_true", help="Required with --apply")
    restore.add_argument("--confirm", action="store_true", help="Alias for --yes")
    restore.add_argument("--json", action="store_true", help="Print JSON payload")

    sentinel = subparsers.add_parser("sentinel", help="Write runtime sentinel report")
    sentinel.add_argument("--json", action="store_true", help="Print JSON payload")
    sentinel.add_argument("--output", type=Path, default=None, help="Optional JSON output path")

    status = subparsers.add_parser("status", help="Show governed runtime status")
    status.add_argument("--json", action="store_true", help="Print JSON payload")

    continuous = subparsers.add_parser("continuous", help="Run G7 continuous governance cycle")
    continuous.add_argument("--event", default="manual", help="Trigger event name")
    continuous.add_argument("--version", default=None, help="Version bucket for the cycle")
    continuous.add_argument("--output", type=Path, default=None, help="Optional JSON output path")
    continuous.add_argument(
        "--no-persist", action="store_true", help="Do not write G7 actas/matrices"
    )
    continuous.add_argument("--json", action="store_true", help="Print JSON payload")

    return parser


def _main(args: argparse.Namespace) -> int:
    root = args.root.resolve()
    if args.command == "save":
        payload = save_snapshot(
            root=root,
            ref=args.ref,
            allow_dirty=args.allow_dirty,
            version=args.version,
            event_type=args.event_type,
        )
        if args.json:
            print(json.dumps(payload, indent=2, ensure_ascii=False))
        else:
            print(f"Snapshot creado: {payload['path']}")
        return 0
    if args.command == "list":
        rows = list_snapshots(root=root)
        if args.json:
            print(json.dumps(rows, indent=2, ensure_ascii=False))
        else:
            _print_table(rows)
        return 0
    if args.command == "index":
        payload = build_snapshot_index(root=root, write=True)
        if args.json:
            print(json.dumps(payload, indent=2, ensure_ascii=False))
        else:
            print(
                f"Snapshot index: operativa/snapshots/SNAPSHOT_INDEX.json total={payload['total']}"
            )
        return 0
    if args.command == "state":
        index = build_snapshot_index(root=root, write=False)
        latest = index["snapshots"][-1] if index["snapshots"] else None
        payload = write_version_state(root=root, version=args.version, latest_snapshot=latest)
        if args.json:
            print(json.dumps(payload, indent=2, ensure_ascii=False))
        else:
            print(f"Version state: {payload['path']} version={payload['version_actual']}")
        return 0
    if args.command == "restore":
        payload = restore_snapshot(
            args.snapshot_id,
            root=root,
            apply=args.apply,
            yes=args.yes or args.confirm,
        )
        if args.json:
            print(json.dumps(payload, indent=2, ensure_ascii=False))
        else:
            print(f"Restore {payload['mode']}: {payload['commit']}")
        return 0
    if args.command == "sentinel":
        payload = build_sentinel_report(root=root, output=args.output)
        if args.json:
            print(json.dumps(payload, indent=2, ensure_ascii=False))
        else:
            print(f"Sentinel report: {payload['path']} status={payload['status']}")
        return 0
    if args.command == "status":
        payload = runtime_status(root=root)
        if args.json:
            print(json.dumps(payload, indent=2, ensure_ascii=False))
        else:
            latest = payload.get("latest_snapshot") or {}
            print(f"Runtime status: {payload['status']}")
            print(f"Version: {payload['version']}")
            print(f"Branch: {payload['branch']}")
            print(f"Commit: {payload['commit']}")
            print(f"Workspace clean: {payload['workspace']['clean']}")
            print(f"Latest snapshot: {latest.get('snapshot_id', 'NONE')}")
        return 0
    if args.command == "continuous":
        payload = run_continuous_cycle(
            root=root,
            event=args.event,
            version=args.version,
            output=args.output,
            persist=not args.no_persist,
        )
        if args.json:
            print(json.dumps(payload, indent=2, ensure_ascii=False))
        else:
            print(f"G7 continuous cycle: {payload['cycle_id']} drift={payload['drift']}")
        return 0
    return 1


def main(argv: Iterable[str] | None = None) -> int:
    parser = build_parser()
    args = parser.parse_args(list(argv) if argv is not None else None)
    try:
        return _main(args)
    except RuntimeErrorMessage as exc:
        print(str(exc), file=sys.stderr)
        return 1


def save_main() -> int:
    return main(["save", *sys.argv[1:]])


def list_main() -> int:
    return main(["list", *sys.argv[1:]])


def restore_main() -> int:
    return main(["restore", *sys.argv[1:]])


def sentinel_main() -> int:
    return main(["sentinel", *sys.argv[1:]])


def index_main() -> int:
    return main(["index", *sys.argv[1:]])


def state_main() -> int:
    return main(["state", *sys.argv[1:]])


def status_main() -> int:
    return main(["status", *sys.argv[1:]])


def continuous_main() -> int:
    return main(["continuous", *sys.argv[1:]])


def ceo_main() -> int:
    args = sys.argv[1:]
    if args[:1] == ["runtime"]:
        return main(args[1:])
    print(
        "Uso: ceo runtime <save|list|restore|sentinel|status|index|state|continuous>",
        file=sys.stderr,
    )
    return 1


if __name__ == "__main__":
    raise SystemExit(main())
