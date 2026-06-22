from __future__ import annotations

import json
from pathlib import Path

from metadata.cli import main as metadata_main
from metadata.doc_report import build_doc_report
from metadata.indexer import build_indexes
from metadata.validator import validate_repository


def _write(path: Path, text: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text, encoding="utf-8")


def _seed_repo(tmp_path: Path) -> Path:
    repo = tmp_path / "repo"
    repo.mkdir()
    schema = Path(__file__).resolve().parents[1] / "schema.json"
    (repo / "schema.json").write_text(schema.read_text(encoding="utf-8"), encoding="utf-8")
    return repo


def test_validate_repository_detects_duplicate_artifact_id(tmp_path: Path) -> None:
    repo = _seed_repo(tmp_path)
    _write(
        repo / "operativa" / "A.md",
        """---
artifact_id: operativa/DUP
categoria: operativa
tipo: mapa
estado: en_revision
version: "1"
autoridad: {tipo: owner, referencia: "@seshat"}
origen: GitHub
ubicacion_repo: operativa/A.md
etiquetas: [a]
relacionados: []
descripcion: prueba A
---
contenido
""",
    )
    _write(
        repo / "operativa" / "B.csv.meta.json",
        json.dumps(
            {
                "artifact_id": "operativa/DUP",
                "categoria": "operativa",
                "tipo": "matriz",
                "estado": "en_revision",
                "version": "1",
                "autoridad": {"tipo": "owner", "referencia": "@seshat"},
                "origen": "GitHub",
                "ubicacion_repo": "operativa/B.csv",
                "etiquetas": ["b"],
                "relacionados": [],
                "descripcion": "prueba B",
            }
        ),
    )

    result = validate_repository(repo, repo / "schema.json")
    assert not result.is_valid
    assert any("duplicado" in item.message for item in result.errors)


def test_build_indexes_generates_root_and_operativa_catalog(tmp_path: Path) -> None:
    repo = _seed_repo(tmp_path)
    _write(
        repo / "operativa" / "MAPA.md",
        """---
artifact_id: operativa/MAPA.md
categoria: operativa
tipo: mapa
estado: live
version: "1"
autoridad: {tipo: owner, referencia: "@seshat"}
origen: GitHub
ubicacion_repo: operativa/MAPA.md
etiquetas: [operativa]
relacionados: []
descripcion: mapa
---
contenido
""",
    )

    root_index, operativa_index = build_indexes(repo, repo / "schema.json")
    assert root_index.exists()
    assert operativa_index.exists()

    root_payload = json.loads(root_index.read_text(encoding="utf-8"))
    operativa_payload = json.loads(operativa_index.read_text(encoding="utf-8"))
    assert root_payload["count"] == 1
    assert operativa_payload["count"] == 1
    assert operativa_payload["items"][0]["artifact_id"] == "operativa/MAPA.md"


def test_build_indexes_is_idempotent_when_metadata_is_unchanged(tmp_path: Path) -> None:
    repo = _seed_repo(tmp_path)
    _write(
        repo / "operativa" / "MAPA.md",
        """---
artifact_id: operativa/MAPA.md
categoria: operativa
tipo: mapa
estado: live
version: "1"
autoridad: {tipo: owner, referencia: "@seshat"}
origen: GitHub
ubicacion_repo: operativa/MAPA.md
etiquetas: [operativa]
relacionados: []
descripcion: mapa
---
contenido
""",
    )

    root_index, operativa_index = build_indexes(repo, repo / "schema.json")
    first_root = root_index.read_text(encoding="utf-8")
    first_operativa = operativa_index.read_text(encoding="utf-8")

    build_indexes(repo, repo / "schema.json")

    assert root_index.read_text(encoding="utf-8") == first_root
    assert operativa_index.read_text(encoding="utf-8") == first_operativa


def test_validate_repository_ignores_local_virtualenv_metadata(tmp_path: Path) -> None:
    repo = _seed_repo(tmp_path)
    _write(
        repo / "operativa" / "MAPA.md",
        """---
artifact_id: operativa/MAPA.md
categoria: operativa
tipo: mapa
estado: live
version: "1"
autoridad: {tipo: owner, referencia: "@seshat"}
origen: GitHub
ubicacion_repo: operativa/MAPA.md
etiquetas: [operativa]
relacionados: []
descripcion: mapa
---
contenido
""",
    )
    _write(repo / "review-env" / "pyvenv.cfg", "home = python\n")
    _write(
        repo
        / "review-env"
        / "Lib"
        / "site-packages"
        / "fastapi"
        / ".agents"
        / "skills"
        / "fastapi"
        / "SKILL.md",
        """---
name: fastapi
description: external package skill
---
external metadata shape
""",
    )

    result = validate_repository(repo, repo / "schema.json")

    assert result.is_valid
    assert [record.source_path for record in result.records] == ["operativa/MAPA.md"]


def test_promote_updates_manifest(tmp_path: Path) -> None:
    repo = _seed_repo(tmp_path)
    _write(
        repo / "operativa" / "README.md",
        """---
artifact_id: operativa/README.md
categoria: operativa
tipo: indice
estado: en_revision
version: "1"
autoridad: {tipo: owner, referencia: "@seshat"}
origen: GitHub
ubicacion_repo: operativa/README.md
etiquetas: [operativa]
relacionados: []
descripcion: indice
---
contenido
""",
    )

    exit_code = metadata_main(["--root", str(repo), "promote", "operativa/README.md", "live"])
    assert exit_code == 0
    manifest = json.loads((repo / "live-manifest.json").read_text(encoding="utf-8"))
    assert "operativa/README.md" in manifest["artifacts"]


def test_doc_report_generates_json_and_markdown(tmp_path: Path) -> None:
    repo = _seed_repo(tmp_path)
    _write(
        repo / "docs" / "gobernanza" / "nomenclatura.md",
        """---
artifact_id: docs/gobernanza/nomenclatura.md
categoria: playbooks
tipo: plan
estado: en_revision
version: "1"
autoridad: {tipo: owner, referencia: CEO}
origen: GitHub
ubicacion_repo: docs/gobernanza/nomenclatura.md
etiquetas: [docs]
relacionados: []
descripcion: nomenclatura
---
contenido
""",
    )
    json_output = repo / "outputs" / "documental" / "doc-report.json"
    md_output = repo / "outputs" / "documental" / "doc-report.md"

    build_doc_report(repo, repo / "schema.json", json_output, md_output)

    payload = json.loads(json_output.read_text(encoding="utf-8"))
    assert payload["schema"] == "projec-cdx-doc-report-v1"
    assert payload["summary"]["by_categoria"] == {"playbooks": 1}
    assert "Reporte Documental PROJEC CDX" in md_output.read_text(encoding="utf-8")


def test_doc_report_cli_generates_outputs(tmp_path: Path) -> None:
    repo = _seed_repo(tmp_path)
    _write(
        repo / "operativa" / "README.md",
        """---
artifact_id: operativa/README.md
categoria: operativa
tipo: indice
estado: live
version: "1"
autoridad: {tipo: owner, referencia: CEO}
origen: GitHub
ubicacion_repo: operativa/README.md
etiquetas: [operativa]
relacionados: []
descripcion: indice
---
contenido
""",
    )

    exit_code = metadata_main(["--root", str(repo), "doc-report"])

    assert exit_code == 0
    assert (repo / "outputs" / "documental" / "doc-report.json").exists()
    assert (repo / "outputs" / "documental" / "doc-report.md").exists()


def test_validate_repository_enforces_dataset_artifact_id_convention(tmp_path: Path) -> None:
    repo = _seed_repo(tmp_path)
    _write(
        repo / "operativa" / "B.csv.meta.json",
        json.dumps(
            {
                "artifact_id": "operativa/B.csv",
                "categoria": "operativa",
                "tipo": "matriz",
                "estado": "en_revision",
                "version": "1",
                "autoridad": {"tipo": "owner", "referencia": "@seshat"},
                "origen": "GitHub",
                "ubicacion_repo": "operativa/B.csv",
                "etiquetas": ["b"],
                "relacionados": [],
                "descripcion": "prueba B",
            }
        ),
    )

    result = validate_repository(repo, repo / "schema.json")

    assert not result.is_valid
    assert any("convencion artifact_id" in item.message for item in result.errors)
