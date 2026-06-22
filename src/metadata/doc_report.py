from __future__ import annotations

import json
from collections import Counter
from pathlib import Path
from typing import Any

from .validator import ValidationResult, validate_repository


def _counter(values: list[str]) -> dict[str, int]:
    return dict(sorted(Counter(values).items()))


def _build_payload(result: ValidationResult) -> dict[str, Any]:
    items: list[dict[str, Any]] = []
    for record in sorted(result.records, key=lambda item: item.metadata.get("artifact_id", "")):
        metadata = record.metadata
        items.append(
            {
                "artifact_id": metadata.get("artifact_id"),
                "categoria": metadata.get("categoria"),
                "tipo": metadata.get("tipo"),
                "estado": metadata.get("estado"),
                "version": metadata.get("version"),
                "origen": metadata.get("origen"),
                "ubicacion_repo": metadata.get("ubicacion_repo"),
                "metadata_source": record.source_path,
                "metadata_kind": record.kind,
                "relacionados_count": len(metadata.get("relacionados", [])),
            }
        )

    return {
        "schema": "projec-cdx-doc-report-v1",
        "count": len(items),
        "summary": {
            "by_categoria": _counter([str(item["categoria"]) for item in items]),
            "by_tipo": _counter([str(item["tipo"]) for item in items]),
            "by_estado": _counter([str(item["estado"]) for item in items]),
            "by_origen": _counter([str(item["origen"]) for item in items]),
            "by_metadata_kind": _counter([str(item["metadata_kind"]) for item in items]),
        },
        "items": items,
    }


def _markdown_table(title: str, values: dict[str, int]) -> list[str]:
    lines = [f"## {title}", "", "| Valor | Cantidad |", "| --- | ---: |"]
    for key, count in values.items():
        lines.append(f"| `{key}` | {count} |")
    lines.append("")
    return lines


def _build_markdown(payload: dict[str, Any]) -> str:
    summary = payload["summary"]
    lines = [
        "# Reporte Documental PROJEC CDX",
        "",
        "Reporte generado desde metadata YAML/JSON validada por `schema.json`.",
        "",
        f"- Schema: `{payload['schema']}`",
        f"- Total de artefactos: `{payload['count']}`",
        "",
    ]
    lines.extend(_markdown_table("Por Categoria", summary["by_categoria"]))
    lines.extend(_markdown_table("Por Tipo", summary["by_tipo"]))
    lines.extend(_markdown_table("Por Estado", summary["by_estado"]))
    lines.extend(_markdown_table("Por Origen", summary["by_origen"]))
    lines.extend(_markdown_table("Por Fuente De Metadata", summary["by_metadata_kind"]))
    lines.extend(
        [
            "## Artefactos",
            "",
            "| Artifact ID | Categoria | Tipo | Estado | Fuente |",
            "| --- | --- | --- | --- | --- |",
        ]
    )
    for item in payload["items"]:
        lines.append(
            "| `{artifact_id}` | `{categoria}` | `{tipo}` | `{estado}` | `{metadata_source}` |".format(
                **item
            )
        )
    lines.append("")
    return "\n".join(lines)


def build_doc_report(
    root: Path, schema_path: Path, json_output: Path, md_output: Path
) -> tuple[Path, Path]:
    result = validate_repository(root, schema_path)
    if not result.is_valid:
        details = "\n".join(
            f"- {item.source_path} [{item.field_path}]: {item.message}" for item in result.errors
        )
        raise ValueError(
            f"No se puede construir reporte documental: metadatos invalidos.\n{details}"
        )

    payload = _build_payload(result)
    json_output.parent.mkdir(parents=True, exist_ok=True)
    md_output.parent.mkdir(parents=True, exist_ok=True)
    json_output.write_text(
        json.dumps(payload, indent=2, ensure_ascii=False) + "\n", encoding="utf-8"
    )
    md_output.write_text(_build_markdown(payload), encoding="utf-8")
    return json_output, md_output
