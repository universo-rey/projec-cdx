from __future__ import annotations

import json
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

from .validator import ValidationResult, validate_repository


def _sort_items(items: list[dict[str, Any]]) -> list[dict[str, Any]]:
    return sorted(items, key=lambda item: item.get("artifact_id", ""))


def _build_items(result: ValidationResult) -> list[dict[str, Any]]:
    items: list[dict[str, Any]] = []
    for record in result.records:
        row = dict(record.metadata)
        row["metadata_source"] = record.source_path
        row["metadata_kind"] = record.kind
        items.append(row)
    return _sort_items(items)


def _existing_generated_at(path: Path, items: list[dict[str, Any]]) -> str | None:
    if not path.exists():
        return None
    try:
        payload = json.loads(path.read_text(encoding="utf-8"))
    except (json.JSONDecodeError, OSError):
        return None
    if not isinstance(payload, dict):
        return None
    if payload.get("items") != items:
        return None
    generated_at = payload.get("generated_at")
    return generated_at if isinstance(generated_at, str) else None


def build_indexes(root: Path, schema_path: Path) -> tuple[Path, Path]:
    result = validate_repository(root, schema_path)
    if not result.is_valid:
        details = "\n".join(
            f"- {item.source_path} [{item.field_path}]: {item.message}" for item in result.errors
        )
        raise ValueError(f"No se puede construir index: metadatos invalidos.\n{details}")

    items = _build_items(result)
    generated_at = datetime.now(tz=timezone.utc).isoformat()
    root_index_path = root / "index.json"
    root_generated_at = _existing_generated_at(root_index_path, items) or generated_at
    root_index = {
        "generated_at": root_generated_at,
        "count": len(items),
        "items": items,
    }
    root_index_path.write_text(json.dumps(root_index, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")

    operativa_items = [item for item in items if str(item.get("artifact_id", "")).startswith("operativa/")]
    operativa_index_path = root / "operativa" / "index.json"
    operativa_generated_at = _existing_generated_at(operativa_index_path, operativa_items) or root_generated_at
    operativa_index = {
        "generated_at": operativa_generated_at,
        "count": len(operativa_items),
        "items": operativa_items,
    }
    operativa_index_path.write_text(
        json.dumps(operativa_index, indent=2, ensure_ascii=False) + "\n",
        encoding="utf-8",
    )
    return root_index_path, operativa_index_path
