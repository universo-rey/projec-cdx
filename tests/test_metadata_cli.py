from __future__ import annotations

import json
from pathlib import Path

import main as root_main
from metadata.cli import main as metadata_main
from metadata.indexer import build_indexes
from metadata.path_policy import canonical_path, is_windows_old_path, normalize_path, normalize_path_value
from metadata import runtime_checks
from metadata.validator import validate_repository


def _write(path: Path, text: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text, encoding="utf-8")


def _seed_repo(tmp_path: Path) -> Path:
    repo = tmp_path / "repo"
    repo.mkdir()
    schema = Path(__file__).parents[1] / "schema.json"
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


def test_validate_repository_normalizes_extended_artifact_ids_before_duplicate_check(tmp_path: Path) -> None:
    repo = _seed_repo(tmp_path)
    _write(
        repo / "operativa" / "A.md",
        r"""---
artifact_id: \\?\C:\Users\enzo1\PROJEC CDX\operativa\DUP.md
categoria: operativa
tipo: mapa
estado: en_revision
version: "1"
autoridad: {tipo: owner, referencia: "@seshat"}
origen: GitHub
ubicacion_repo: \\?\C:\Users\enzo1\PROJEC CDX\operativa\A.md
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
                "artifact_id": r"C:\Users\enzo1\PROJEC CDX\operativa\DUP.md",
                "categoria": "operativa",
                "tipo": "matriz",
                "estado": "en_revision",
                "version": "1",
                "autoridad": {"tipo": "owner", "referencia": "@seshat"},
                "origen": "GitHub",
                "ubicacion_repo": r"C:\Users\enzo1\PROJEC CDX\operativa\B.csv",
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


def test_normalize_path_strips_extended_prefix() -> None:
    assert canonical_path(r"\\?\C:\Users\enzo1\PROJEC CDX\operativa\MAPA.md") == "C:/Users/enzo1/PROJEC CDX/operativa/MAPA.md"
    assert canonical_path(r"\\?\UNC\server\share\file.txt") == "//server/share/file.txt"


def test_normalize_path_value_keeps_non_path_text_intact() -> None:
    assert normalize_path_value({"url": "https://example.com/a/b"}) == {"url": "https://example.com/a/b"}
    assert normalize_path_value({"repo": r"operativa\MAPA.md"}) == {"repo": "operativa/MAPA.md"}


def test_windows_old_paths_are_excluded_as_historical() -> None:
    assert is_windows_old_path(r"C:\Windows.old\Users\enzo1\Documents\GitHub\repo")
    assert not is_windows_old_path(r"C:\Users\enzo1\Documents\GitHub\repo")


def test_validate_core_only_excludes_external_skill_metadata(tmp_path: Path, monkeypatch) -> None:
    monkeypatch.setattr(runtime_checks, "_WARNED_NON_ELEVATED", False)
    monkeypatch.setattr(runtime_checks, "is_elevated_terminal", lambda: False)
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
    _write(
        repo / ".github" / "skills" / "external" / "SKILL.md",
        """---
name: external-skill
description: external metadata
---
""",
    )

    exit_code = metadata_main(["--root", str(repo), "validate", "--core-only"])
    assert exit_code == 0

    scope = json.loads((repo / "validate-scope.json").read_text(encoding="utf-8"))
    assert scope["included_paths"] == ["src/", "tests/", "tools/", "operativa/"]
    assert ".github/skills/" in scope["excluded_paths"]
    assert any(".github/skills/" in item for item in scope["ignored_errors"])


def test_warn_if_not_elevated_emits_clear_message(monkeypatch, capsys) -> None:
    monkeypatch.setattr(runtime_checks, "_WARNED_NON_ELEVATED", False)
    monkeypatch.setattr(runtime_checks, "is_elevated_terminal", lambda: False)

    warned = runtime_checks.warn_if_not_elevated("metadata")
    captured = capsys.readouterr()

    assert warned is True
    assert "terminal no esta elevada" in captured.err
    assert "Administrador" in captured.err or "administrador" in captured.err


def test_check_elevation_rejects_when_required(monkeypatch, capsys) -> None:
    monkeypatch.setattr(runtime_checks, "_WARNED_NON_ELEVATED", False)
    monkeypatch.setattr(runtime_checks, "is_elevated_terminal", lambda: False)

    allowed = runtime_checks.check_elevation(True, "metadata")
    captured = capsys.readouterr()

    assert allowed is False
    assert "se requiere una terminal elevada" in captured.err


def test_metadata_main_rejects_non_elevated_when_flagged(monkeypatch) -> None:
    monkeypatch.setattr(runtime_checks, "is_elevated_terminal", lambda: False)

    exit_code = metadata_main(["--root", str(Path(__file__).parents[1]), "--require-elevated", "validate"])

    assert exit_code == 2


def test_root_main_strips_require_elevated_flag(monkeypatch) -> None:
    calls: dict[str, list[str]] = {}
    monkeypatch.setattr(root_main, "check_elevation", lambda required, context, stream=None: True)
    monkeypatch.setattr(root_main, "metadata_main", lambda args: calls.__setitem__("metadata", list(args)) or 0)
    monkeypatch.setattr(root_main, "cloud_main", lambda args: calls.__setitem__("cloud", list(args)) or 0)

    exit_code = root_main.main(["--require-elevated", "validate", "--root", "C:/tmp/repo"])

    assert exit_code == 0
    assert calls["metadata"] == ["validate", "--root", "C:/tmp/repo"]
