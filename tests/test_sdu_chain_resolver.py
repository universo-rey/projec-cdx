from __future__ import annotations

import csv
import json
from pathlib import Path

from projec_cdx_cloud import cli as cloud_cli
from tools.sdu_chain_resolver import build_graph


def _write(path: Path, text: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text, encoding="utf-8")


def _write_csv(path: Path, rows: list[dict[str, str]]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=list(rows[0]))
        writer.writeheader()
        writer.writerows(rows)


def test_sdu_chain_resolver_builds_local_chain(tmp_path: Path) -> None:
    repo = tmp_path / "repo"
    _write_csv(
        repo / "inventarios" / "SKILLS_UNIFIED_TABLE.csv",
        [
            {
                "RootLabel": ".codex/skills",
                "Kind": "skill",
                "Family": "control",
                "Canonical": "projec-cdx-semantic-layer",
                "Alias": "",
                "Purpose": "semantic source routing",
                "SourcePath": "C:/Users/enzo1/.codex/skills/projec-cdx-semantic-layer/SKILL.md",
                "Notes": "",
            }
        ],
    )
    _write(repo / "README.md", "# Repo\n")
    _write(repo / "AGENTS.md", "# Agents\n")
    _write(repo / "MAPA_MAESTRO.md", "# Mapa\n")
    _write(repo / "operativa" / "CURRENT.md", "# Current\n")
    _write(repo / "operativa" / "NEXT.md", "# Next\n")
    _write(repo / "operativa" / "TRACE.md", "# Trace\n")
    _write(repo / "recipes" / "INDICE_RECETAS.md", "# Recetas\n")
    _write(repo / "recipes" / "canon-documental.md", "# Canon documental\n")
    _write(repo / "dataverse" / "ORDEN_SDU_VIVA.md", "# Orden\n")
    _write(repo / "dataverse" / "DATAVERSE_OPERATIONAL_CHAIN_SOURCE_MAP.csv", "a,b\n1,2\n")
    _write(repo / "atomic" / "CODEX_ATOMIC_ACTION_MATRIX.csv", "a,b\n1,2\n")
    _write(repo / "inventarios" / "AGENTES_SKILLS_RECETAS_20260616.md", "# Agentes\n")
    _write(repo / "docs" / "referencia" / "semantic-layer.md", "# Semantic layer\n")
    _write(repo / "operativa" / "CANON_SEMANTICO_WAVE_ATOMICA_METADATA_20260616.md", "# Canon\n")
    _write(repo / "src" / "metadata" / "cli.py", "# cli\n")
    _write(repo / "src" / "metadata" / "doc_report.py", "# report\n")
    _write(repo / "tools" / "sdu_boot.ps1", "# boot\n")
    _write(repo / "tools" / "sdu_chain_resolver.py", "# resolver\n")
    _write(repo / "tools" / "validate_proj_cdx_operational_chain.ps1", "# validator\n")
    _write(repo / "tools" / "validate_sdu_dataverse_metadata_wave.ps1", "# validator\n")
    _write(repo / "tools" / "validate.py", "# validator\n")
    _write(repo / "tools" / "build_index.py", "# build index\n")
    _write(repo / "tools" / "build_skills_unified_table.ps1", "# builder\n")
    _write(repo / "tools" / "codex-control-total.ps1", "# control\n")
    _write(repo / "schema.json", "{}\n")
    _write(repo / "index.json", "{}\n")
    _write(repo / "operativa" / "index.json", "{}\n")
    _write(repo / "live-manifest.json", "{}\n")
    _write(repo / "inventarios" / "ACTAS_PAPELES_AGENTES_20260616.md", "# Actas\n")
    _write(repo / "hitos" / "INDICE_MAESTRO.md", "# Hitos\n")
    _write(repo / "outputs" / "README.md", "# Outputs\n")
    _write(repo / "docs" / "herramientas" / "cli-metadata.md", "# CLI\n")
    _write(repo / "operativa" / "MATRIZ_SKILLS_TOOLS_RECETAS_20260615.md", "# matrix\n")

    payload = build_graph(repo, no_external=True, dry_run=True)

    assert payload["status"] in {"PASS", "OBSERVED"}
    assert (
        payload["chain"]
        == "entrada -> estado -> orden -> agentes -> semantica -> motor -> modelo -> evidencia -> salida"
    )
    assert payload["agents"][0]["agent"] == "seshat-normativa"
    assert "tools/sdu_boot.ps1" in payload["agents"][0]["tools"]
    checks = {check["name"]: check for check in payload["checks"]}
    assert checks["salida:runtime_endpoint"]["status"] == "PASS"


def test_cloud_smoke_does_not_load_local_env(monkeypatch, capsys) -> None:
    def fail_load_env() -> None:
        raise AssertionError("smoke mode must not load local env")

    monkeypatch.setattr(cloud_cli, "load_local_env", fail_load_env)
    monkeypatch.setattr(cloud_cli, "align_runtime_context", lambda: None)
    monkeypatch.setattr(cloud_cli, "smoke_report", lambda: {"status": "prepared"})

    assert cloud_cli.main(["--smoke", "--json"]) == 0
    assert json.loads(capsys.readouterr().out)["status"] == "prepared"
