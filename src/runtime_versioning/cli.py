from __future__ import annotations

import argparse
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
SNAPSHOT_PREFIX = "CEORUNTIME"

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


def _relative(path: Path, root: Path) -> str:
    return path.resolve().relative_to(root.resolve()).as_posix()


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
        digest.update(f"{mode} {object_type} {object_hash}\t{normalized}\n".encode("utf-8"))
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


def _snapshot_payload(root: Path, ref: str, allow_dirty: bool) -> dict[str, Any]:
    status_lines = _git_status(root)
    if status_lines and not allow_dirty:
        raise RuntimeErrorMessage(
            "WORKSPACE_DIRTY: create a clean snapshot or pass --allow-dirty for diagnostic captures"
        )
    commit = _git(root, "rev-parse", ref)
    branch = _git(root, "branch", "--show-current")
    tags = [line for line in _git(root, "tag", "--points-at", commit).splitlines() if line]
    tree = _tracked_tree_hash(root, commit)
    watched = {
        path: _sha256_file(root / path)
        for path in WATCHED_RUNTIME_FILES
        if (root / path).exists()
    }

    payload: dict[str, Any] = {
        "schema_version": "1.0",
        "snapshot_id": f"{SNAPSHOT_PREFIX}_{_timestamp_id()}",
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
        "restore_policy": {
            "requires_clean_workspace": True,
            "requires_explicit_yes": True,
            "default_mode": "DRY_RUN",
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


def save_snapshot(
    root: Path = ROOT,
    ref: str = "HEAD",
    allow_dirty: bool = False,
    snapshot_dir: Path | None = None,
) -> dict[str, Any]:
    payload = _snapshot_payload(root.resolve(), ref, allow_dirty)
    output_dir = snapshot_dir or root / "operativa" / "snapshots"
    path = _next_snapshot_path(output_dir, str(payload["snapshot_id"]))
    path.write_text(json.dumps(payload, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    payload["path"] = _relative(path, root)
    return payload


def _snapshot_files(root: Path, snapshot_dir: Path | None = None) -> list[Path]:
    directory = snapshot_dir or root / "operativa" / "snapshots"
    if not directory.exists():
        return []
    return sorted(directory.glob(f"{SNAPSHOT_PREFIX}_*.json"))


def list_snapshots(root: Path = ROOT, snapshot_dir: Path | None = None) -> list[dict[str, Any]]:
    rows: list[dict[str, Any]] = []
    for path in _snapshot_files(root.resolve(), snapshot_dir):
        payload = _load_json(path)
        if not isinstance(payload, dict):
            continue
        rows.append(
            {
                "snapshot_id": payload.get("snapshot_id", path.stem),
                "created_at_utc": payload.get("created_at_utc"),
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
    checkout = _run(["git", "checkout", "--detach", commit], root)
    if checkout.returncode != 0:
        raise RuntimeErrorMessage(checkout.stderr.strip() or "git checkout failed")
    result["result"] = "restored_detached_head"
    return result


def build_sentinel_report(root: Path = ROOT, output: Path | None = None) -> dict[str, Any]:
    root = root.resolve()
    status_lines = _git_status(root)
    validate_result = _run([sys.executable, "-m", "tools.validate"], root)
    snapshots = list_snapshots(root)
    latest_snapshot = snapshots[-1] if snapshots else None
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
        "watched_hashes": {
            path: _sha256_file(root / path)
            for path in WATCHED_RUNTIME_FILES
            if (root / path).exists()
        },
        "no_external": True,
    }
    output_path = output or root / "operativa" / "sentinel" / "SENTINEL_REPORT.json"
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(json.dumps(report, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    report["path"] = _relative(output_path, root)
    return report


def _print_table(rows: list[dict[str, Any]]) -> None:
    if not rows:
        print("No snapshots found.")
        return
    headers = ["snapshot_id", "created_at_utc", "commit", "tags", "dirty", "path"]
    widths = {
        header: max(
            len(header),
            *[
                len(",".join(str(x) for x in row.get(header, [])))
                if isinstance(row.get(header), list)
                else len(str(row.get(header, "")))
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
    save.add_argument("--allow-dirty", action="store_true", help="Allow diagnostic dirty snapshot")
    save.add_argument("--json", action="store_true", help="Print JSON payload")

    list_parser = subparsers.add_parser("list", help="List available snapshots")
    list_parser.add_argument("--json", action="store_true", help="Print JSON payload")

    restore = subparsers.add_parser("restore", help="Restore or dry-run restore from a snapshot")
    restore.add_argument("snapshot_id", help="Snapshot id or path")
    restore.add_argument("--apply", action="store_true", help="Apply checkout to snapshot commit")
    restore.add_argument("--yes", action="store_true", help="Required with --apply")
    restore.add_argument("--json", action="store_true", help="Print JSON payload")

    sentinel = subparsers.add_parser("sentinel", help="Write runtime sentinel report")
    sentinel.add_argument("--json", action="store_true", help="Print JSON payload")

    return parser


def _main(args: argparse.Namespace) -> int:
    root = args.root.resolve()
    if args.command == "save":
        payload = save_snapshot(root=root, ref=args.ref, allow_dirty=args.allow_dirty)
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
    if args.command == "restore":
        payload = restore_snapshot(args.snapshot_id, root=root, apply=args.apply, yes=args.yes)
        if args.json:
            print(json.dumps(payload, indent=2, ensure_ascii=False))
        else:
            print(f"Restore {payload['mode']}: {payload['commit']}")
        return 0
    if args.command == "sentinel":
        payload = build_sentinel_report(root=root)
        if args.json:
            print(json.dumps(payload, indent=2, ensure_ascii=False))
        else:
            print(f"Sentinel report: {payload['path']} status={payload['status']}")
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


if __name__ == "__main__":
    raise SystemExit(main())
