from __future__ import annotations

import argparse
import json
from collections import Counter
from collections.abc import Iterable
from dataclasses import dataclass
from hashlib import sha256
from pathlib import Path
from typing import Any

from .path_policy import normalize_path_value

SECTION_PATHS = [
    "computer",
    "powershell",
    "environment",
    "users",
    "codex",
    "system",
    "tasks",
    "services",
    "processes",
]


@dataclass(frozen=True)
class DiffRecord:
    section: str
    kind: str
    left: Any
    right: Any


def _load_report(path: Path) -> dict[str, Any]:
    return json.loads(path.read_text(encoding="utf-8"))


def _normalize(value: Any) -> Any:
    value = normalize_path_value(value)
    if isinstance(value, dict):
        return {key: _normalize(item) for key, item in sorted(value.items(), key=lambda pair: pair[0])}
    if isinstance(value, list):
        normalized_items = [_normalize(item) for item in value]
        return sorted(
            normalized_items,
            key=lambda item: json.dumps(item, sort_keys=True, ensure_ascii=False),
        )
    return value


def _fingerprint(value: Any) -> str:
    return sha256(json.dumps(value, sort_keys=True, ensure_ascii=False).encode("utf-8")).hexdigest()


def _count_diff(left: list[Any], right: list[Any]) -> tuple[list[Any], list[Any]]:
    left_counts = Counter(_fingerprint(item) for item in left)
    right_counts = Counter(_fingerprint(item) for item in right)
    left_map = {_fingerprint(item): item for item in left}
    right_map = {_fingerprint(item): item for item in right}

    removed: list[Any] = []
    added: list[Any] = []
    for fingerprint, count in (left_counts - right_counts).items():
        removed.extend([left_map[fingerprint]] * count)
    for fingerprint, count in (right_counts - left_counts).items():
        added.extend([right_map[fingerprint]] * count)
    return added, removed


def _section_value(report: dict[str, Any], section: str) -> Any:
    value: Any = report
    for part in section.split("."):
        if not isinstance(value, dict) or part not in value:
            return None
        value = value[part]
    return value


def compare_audit_reports(left: dict[str, Any], right: dict[str, Any]) -> dict[str, Any]:
    differences: list[dict[str, Any]] = []
    identical_sections: list[str] = []
    changed_sections: list[str] = []
    left_only_sections: list[str] = []
    right_only_sections: list[str] = []

    for section in SECTION_PATHS:
        left_value = _section_value(left, section)
        right_value = _section_value(right, section)
        if left_value is None and right_value is None:
            continue
        if left_value is None:
            right_only_sections.append(section)
            differences.append({"section": section, "kind": "missing_left", "left": None, "right": _normalize(right_value)})
            continue
        if right_value is None:
            left_only_sections.append(section)
            differences.append({"section": section, "kind": "missing_right", "left": _normalize(left_value), "right": None})
            continue

        left_norm = _normalize(left_value)
        right_norm = _normalize(right_value)
        if left_norm == right_norm:
            identical_sections.append(section)
            continue

        changed_sections.append(section)
        if isinstance(left_norm, list) and isinstance(right_norm, list):
            added, removed = _count_diff(left_norm, right_norm)
            differences.append(
                {
                    "section": section,
                    "kind": "collection",
                    "left_count": len(left_norm),
                    "right_count": len(right_norm),
                    "added": added,
                    "removed": removed,
                }
            )
        elif isinstance(left_norm, dict) and isinstance(right_norm, dict):
            left_keys = set(left_norm)
            right_keys = set(right_norm)
            differences.append(
                {
                    "section": section,
                    "kind": "object",
                    "added_keys": sorted(right_keys - left_keys),
                    "removed_keys": sorted(left_keys - right_keys),
                    "shared_keys": sorted(left_keys & right_keys),
                    "left": left_norm,
                    "right": right_norm,
                }
            )
        else:
            differences.append(
                {
                    "section": section,
                    "kind": "scalar",
                    "left": left_norm,
                    "right": right_norm,
                }
            )

    focus_flags = []
    left_elevated = bool(_section_value(left, "computer.elevated"))
    right_elevated = bool(_section_value(right, "computer.elevated"))
    if left_elevated != right_elevated:
        focus_flags.append("elevation_mismatch")

    left_codex_vars = _section_value(left, "environment.codex") or []
    right_codex_vars = _section_value(right, "environment.codex") or []
    if len(left_codex_vars) != len(right_codex_vars):
        focus_flags.append("codex_env_cardinality_diff")

    return {
        "summary": {
            "identical_sections": identical_sections,
            "changed_sections": changed_sections,
            "left_only_sections": left_only_sections,
            "right_only_sections": right_only_sections,
            "focus_flags": focus_flags,
        },
        "differences": differences,
    }


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Comparador de auditorias SDU")
    parser.add_argument("--left", type=Path, required=True, help="JSON de la primera sesion")
    parser.add_argument("--right", type=Path, required=True, help="JSON de la segunda sesion")
    parser.add_argument("--output", type=Path, help="Ruta de salida opcional para el diff JSON")
    return parser


def main(argv: Iterable[str] | None = None) -> int:
    parser = build_parser()
    args = parser.parse_args(list(argv) if argv is not None else None)

    left = _load_report(args.left)
    right = _load_report(args.right)
    diff = compare_audit_reports(left, right)
    payload = {
        "left": str(args.left),
        "right": str(args.right),
        **diff,
    }
    rendered = json.dumps(payload, indent=2, ensure_ascii=False) + "\n"
    if args.output:
        args.output.write_text(rendered, encoding="utf-8")
    else:
        print(rendered, end="")
    return 0
