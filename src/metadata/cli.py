from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Iterable

from .indexer import build_indexes
from .validator import replace_front_matter, validate_repository


def _repo_root() -> Path:
    return Path(__file__).resolve().parents[2]


def _schema_path(root: Path) -> Path:
    return root / "schema.json"


def _load_live_manifest(path: Path) -> dict:
    if path.exists():
        return json.loads(path.read_text(encoding="utf-8"))
    return {"artifacts": []}


def _write_live_manifest(path: Path, artifacts: list[str]) -> None:
    payload = {"artifacts": sorted(set(artifacts))}
    path.write_text(json.dumps(payload, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")


def _run_validate(root: Path, schema: Path) -> int:
    result = validate_repository(root, schema)
    if result.errors:
        for item in result.errors:
            print(f"{item.source_path} :: {item.field_path} :: {item.message}")
        print(f"Metadatos invalidos: {len(result.errors)} error(es).")
        return 1
    print(f"OK: {len(result.records)} metadatos validos.")
    return 0


def _run_build_index(root: Path, schema: Path) -> int:
    root_index, operativa_index = build_indexes(root, schema)
    print(f"Index generado: {root_index}")
    print(f"Subindex generado: {operativa_index}")
    return 0


def _run_graph(root: Path, schema: Path, output: Path, fmt: str) -> int:
    result = validate_repository(root, schema)
    if result.errors:
        print("No se puede generar grafo: hay metadatos invalidos.")
        return 1

    edges: list[tuple[str, str]] = []
    for record in result.records:
        source = str(record.metadata.get("artifact_id", ""))
        if not source:
            continue
        for target in record.metadata.get("relacionados", []):
            if isinstance(target, str) and target:
                edges.append((source, target))

    if fmt == "dot":
        lines = ["digraph relaciones {"]
        for source, target in edges:
            lines.append(f'  "{source}" -> "{target}";')
        lines.append("}")
        output.write_text("\n".join(lines) + "\n", encoding="utf-8")
    else:
        payload = {"edges": [{"from": source, "to": target} for source, target in edges]}
        output.write_text(json.dumps(payload, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    print(f"Grafo generado: {output}")
    return 0


def _run_promote(root: Path, schema: Path, artifact_id: str, estado: str) -> int:
    result = validate_repository(root, schema)
    if result.errors:
        print("No se puede promover: hay metadatos invalidos.")
        return 1

    target = next((record for record in result.records if record.metadata.get("artifact_id") == artifact_id), None)
    if target is None:
        print(f"artifact_id no encontrado: {artifact_id}")
        return 1

    metadata = dict(target.metadata)
    metadata["estado"] = estado
    metadata_source = root / target.source_path
    if target.kind == "front_matter":
        replace_front_matter(metadata_source, metadata)
    else:
        metadata_source.write_text(json.dumps(metadata, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")

    manifest_path = root / "live-manifest.json"
    manifest = _load_live_manifest(manifest_path)
    artifacts = [item for item in manifest.get("artifacts", []) if isinstance(item, str)]
    if estado in {"aprobado", "live"}:
        artifacts.append(artifact_id)
    else:
        artifacts = [item for item in artifacts if item != artifact_id]
    _write_live_manifest(manifest_path, artifacts)
    print(f"Estado actualizado: {artifact_id} -> {estado}")
    return 0


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="CLI de metadatos PROJEC CDX")
    parser.add_argument("--root", type=Path, default=_repo_root(), help="Raiz del repositorio")
    subparsers = parser.add_subparsers(dest="command", required=True)

    subparsers.add_parser("validate", help="Validar metadatos contra schema.json")
    subparsers.add_parser("build-index", help="Construir indices index.json")

    graph_parser = subparsers.add_parser("graph", help="Exportar grafo de relacionados")
    graph_parser.add_argument("--output", type=Path, default=Path("metadata-graph.json"))
    graph_parser.add_argument("--format", choices=["json", "dot"], default="json")

    promote_parser = subparsers.add_parser("promote", help="Cambiar estado y actualizar live-manifest")
    promote_parser.add_argument("artifact_id")
    promote_parser.add_argument("estado", choices=["borrador", "en_revision", "aprobado", "live"])

    return parser


def main(argv: Iterable[str] | None = None) -> int:
    parser = build_parser()
    args = parser.parse_args(list(argv) if argv is not None else None)

    root = args.root.resolve()
    schema = _schema_path(root)
    if not schema.exists():
        print(f"No existe schema.json en {root}")
        return 1

    if args.command == "validate":
        return _run_validate(root, schema)
    if args.command == "build-index":
        return _run_build_index(root, schema)
    if args.command == "graph":
        output = args.output if args.output.is_absolute() else root / args.output
        return _run_graph(root, schema, output, args.format)
    if args.command == "promote":
        return _run_promote(root, schema, args.artifact_id, args.estado)
    parser.print_help()
    return 1
