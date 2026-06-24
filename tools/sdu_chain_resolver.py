from __future__ import annotations

import argparse
import csv
import json
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Any

REPO_ROOT = Path(__file__).resolve().parents[1]
DEFAULT_AGENT = "All"
NERVOUS_SYSTEM_CHAIN = (
    "entrada -> estado -> orden -> agentes -> semantica -> motor -> modelo -> evidencia -> salida"
)

SDU_AGENT_ORDER = [
    "seshat-normativa",
    "thot-tecnico",
    "anubis-gate",
    "maat-cumplimiento",
    "horus-riesgo",
    "narrador-normativo",
]

AGENT_SKILL_HINTS = {
    "seshat-normativa": [
        "projec-cdx-semantic-layer",
        "canon-documental",
        "documentos-canon-atomico",
        "governed-readback-closeout",
    ],
    "thot-tecnico": [
        "matrix-recipe-skill-sync",
        "dataverse-rehidratacion",
        "cli-creator",
        "cabina-agent-delegation",
    ],
    "anubis-gate": [
        "no-inference-runtime-write-guard",
        "sdu-ejecutor-gates",
        "codex-security:security-scan",
        "rey-modo-evidencia-riesgo-handoff",
    ],
    "maat-cumplimiento": [
        "delta-gobernado",
        "repo-agent-tool-governance",
        "cabina-decision-matrix",
        "superpowers:verification-before-completion",
    ],
    "horus-riesgo": [
        "parallel-agentic-repo-audit",
        "security-ownership-map",
        "cabina-lane-selector",
        "rey-modo-fronteras-continuidad",
    ],
    "narrador-normativo": [
        "cabina-continuity-readback",
        "cierre-wave-documental",
        "canon-documental",
        "governed-readback-closeout",
    ],
}

RECIPE_HINTS = {
    "seshat-normativa": ["canon-documental.md", "documentos-canon-atomico.md"],
    "thot-tecnico": ["dataverse-rehidratacion.md", "configuracion-entorno-codex-ui.md"],
    "anubis-gate": ["normalizacion-perfil-windows.md", "limpieza-pc-local-segura.md"],
    "maat-cumplimiento": ["agentes-atomicos-algoritmicos-en-waves.md"],
    "horus-riesgo": ["microsoft-live-read-preliminar.md"],
    "narrador-normativo": ["cierre-wave-documental.md", "canon-documental.md"],
}

CORE_TOOLS = [
    "tools/sdu_boot.ps1",
    "tools/sdu_chain_resolver.py",
    "tools/validate_proj_cdx_operational_chain.ps1",
    "tools/validate_sdu_dataverse_metadata_wave.ps1",
    "tools/build_skills_unified_table.ps1",
    "tools/codex-control-total.ps1",
]

CORE_VALIDATORS = [
    "tools/validate_proj_cdx_operational_chain.ps1",
    "tools/validate_sdu_dataverse_metadata_wave.ps1",
    "tools/validate.py",
]

CORE_EVIDENCE = [
    "inventarios/SKILLS_UNIFIED_TABLE.csv",
    "operativa/archive/legacy-root/20260615/MATRIZ_SKILLS_TOOLS_RECETAS_20260615.md",
    "dataverse/DATAVERSE_OPERATIONAL_CHAIN_SOURCE_MAP.csv",
    "atomic/CODEX_ATOMIC_ACTION_MATRIX.csv",
]

ARCHIVED_ROOT_ALIASES = {
    "operativa/archive/legacy-root/20260615/MATRIZ_SKILLS_TOOLS_RECETAS_20260615.md": (
        "operativa/MATRIZ_SKILLS_TOOLS_RECETAS_20260615.md",
    ),
    "operativa/archive/legacy-root/20260616/CANON_SEMANTICO_WAVE_ATOMICA_METADATA_20260616.md": (
        "operativa/CANON_SEMANTICO_WAVE_ATOMICA_METADATA_20260616.md",
    ),
}

ABSTRACT_ENDPOINT_PREFIXES = ("<RUNTIME_PATH>/",)


@dataclass(frozen=True)
class Check:
    name: str
    status: str
    detail: str


def _rel(path: Path, root: Path) -> str:
    try:
        return path.resolve().relative_to(root.resolve()).as_posix()
    except ValueError:
        return str(path)


def _path(root: Path, value: str) -> Path:
    candidate = Path(value)
    if candidate.is_absolute():
        return candidate
    parts = [part for part in value.replace("\\", "/").split("/") if part not in {"", "."}]
    return root.joinpath(*parts)


def _path_candidates(value: str) -> tuple[str, ...]:
    return (value, *ARCHIVED_ROOT_ALIASES.get(value, ()))


def _existing_path(root: Path, value: str) -> Path | None:
    for candidate in _path_candidates(value):
        path = _path(root, candidate)
        if path.exists():
            return path
    return None


def _exists(root: Path, value: str) -> bool:
    if value.startswith(ABSTRACT_ENDPOINT_PREFIXES):
        return True
    return _existing_path(root, value) is not None


def _read_csv(path: Path) -> list[dict[str, str]]:
    if not path.exists():
        return []
    with path.open("r", encoding="utf-8-sig", newline="") as handle:
        return list(csv.DictReader(handle))


def _skill_names_from_inventory(root: Path) -> set[str]:
    rows = _read_csv(root / "inventarios" / "SKILLS_UNIFIED_TABLE.csv")
    names: set[str] = set()
    for row in rows:
        if (row.get("Kind") or "").lower() not in {"skill", "plugin"}:
            continue
        for key in ("Canonical", "Alias"):
            value = (row.get(key) or "").strip()
            if value:
                names.add(value)
    return names


def _physical_skill_names() -> set[str]:
    names: set[str] = set()
    for root in (Path.home() / ".codex" / "skills", Path.home() / ".agents" / "skills"):
        if not root.exists():
            continue
        for skill_file in root.rglob("SKILL.md"):
            names.add(skill_file.parent.name)
            for line in skill_file.read_text(encoding="utf-8", errors="ignore").splitlines()[:16]:
                if line.startswith("name:"):
                    declared = line.split(":", 1)[1].strip().strip('"').strip("'")
                    if declared:
                        names.add(declared)
                    break
    return names


def _load_agent_profiles(root: Path) -> dict[str, str]:
    sys_path_added = False
    src = root / "src"
    if str(src) not in sys.path:
        sys.path.insert(0, str(src))
        sys_path_added = True
    try:
        from projec_cdx_cloud.agent import SDU_AGENT_PROFILES  # type: ignore

        return dict(SDU_AGENT_PROFILES)
    except Exception:
        return {agent: "profile_unavailable" for agent in SDU_AGENT_ORDER}
    finally:
        if sys_path_added:
            try:
                sys.path.remove(str(src))
            except ValueError:
                pass


def _select_existing(root: Path, paths: list[str]) -> list[str]:
    selected = []
    for path in paths:
        existing = _existing_path(root, path)
        if existing is not None:
            selected.append(_rel(existing, root))
    return selected


def _select_existing_recipes(root: Path, names: list[str]) -> list[str]:
    selected = []
    for name in names:
        path = root / "recipes" / name
        if path.exists():
            selected.append(_rel(path, root))
    return selected


def _agent_packet(root: Path, agent: str, available_skills: set[str]) -> dict[str, Any]:
    skill_hints = AGENT_SKILL_HINTS.get(agent, [])
    selected_skills = [skill for skill in skill_hints if skill in available_skills]
    missing_skills = [skill for skill in skill_hints if skill not in available_skills]
    return {
        "agent": agent,
        "skills": selected_skills,
        "missing_skill_hints": missing_skills,
        "recipes": _select_existing_recipes(root, RECIPE_HINTS.get(agent, [])),
        "tools": _select_existing(root, CORE_TOOLS),
        "validators": _select_existing(root, CORE_VALIDATORS),
        "evidence": _select_existing(root, CORE_EVIDENCE),
        "stop_condition": "missing_required_local_artifact_or_live_gate_requested",
    }


def build_graph(
    root: Path,
    *,
    mode: str = "all",
    agent: str = DEFAULT_AGENT,
    no_external: bool = True,
    dry_run: bool = True,
) -> dict[str, Any]:
    root = root.resolve()
    checks: list[Check] = []

    def add(name: str, status: str, detail: str) -> None:
        checks.append(Check(name=name, status=status, detail=detail))

    add("repo_root_exists", "PASS" if root.exists() else "FAIL", str(root))
    add("no_external_gate", "PASS" if no_external else "FAIL", "external surfaces disabled")
    add(
        "dry_run_gate",
        "PASS" if dry_run else "OBSERVED",
        "no mutation requested" if dry_run else "execution mode can mutate",
    )
    add("env_local_read", "PASS", ".env.local not read by resolver")

    required_files = {
        "entrada:readme": "README.md",
        "entrada:agents": "AGENTS.md",
        "entrada:mapa_maestro": "MAPA_MAESTRO.md",
        "estado:current": "operativa/CURRENT.md",
        "estado:next": "operativa/NEXT.md",
        "estado:trace": "operativa/TRACE.md",
        "orden:sdu_boot": "tools/sdu_boot.ps1",
        "orden:sdu_chain_resolver": "tools/sdu_chain_resolver.py",
        "orden:orden_sdu_viva": "dataverse/ORDEN_SDU_VIVA.md",
        "agentes:agent_skill_map": "inventarios/AGENTES_SKILLS_RECETAS_20260616.md",
        "agentes:skills_inventory": "inventarios/SKILLS_UNIFIED_TABLE.csv",
        "agentes:recipes_index": "recipes/INDICE_RECETAS.md",
        "semantica:semantic_layer_repo": "docs/referencia/semantic-layer.md",
        "semantica:semantic_canon": "operativa/archive/legacy-root/20260616/CANON_SEMANTICO_WAVE_ATOMICA_METADATA_20260616.md",
        "motor:metadata_cli": "src/metadata/cli.py",
        "motor:doc_report": "src/metadata/doc_report.py",
        "motor:validate": "tools/validate.py",
        "motor:build_index": "tools/build_index.py",
        "modelo:schema": "schema.json",
        "modelo:index": "index.json",
        "modelo:operativa_index": "operativa/index.json",
        "modelo:live_manifest": "live-manifest.json",
        "evidencia:actas_papeles": "inventarios/ACTAS_PAPELES_AGENTES_20260616.md",
        "evidencia:hitos_index": "hitos/INDICE_MAESTRO.md",
        "evidencia:source_map": "dataverse/DATAVERSE_OPERATIONAL_CHAIN_SOURCE_MAP.csv",
        "evidencia:atomic_matrix": "atomic/CODEX_ATOMIC_ACTION_MATRIX.csv",
        "salida:runtime_endpoint": "<RUNTIME_PATH>/README.md",
        "salida:cli_metadata_doc": "docs/herramientas/cli-metadata.md",
    }
    for name, relative in required_files.items():
        add(name, "PASS" if _exists(root, relative) else "FAIL", relative)

    for relative in CORE_VALIDATORS:
        add(f"validator:{relative}", "PASS" if _exists(root, relative) else "FAIL", relative)

    agent_profiles = _load_agent_profiles(root)
    missing_agents = [
        agent_name for agent_name in SDU_AGENT_ORDER if agent_name not in agent_profiles
    ]
    add(
        "sdu_agents_defined",
        "PASS" if not missing_agents else "FAIL",
        f"{len(agent_profiles)} profiles; missing={','.join(missing_agents) or 'none'}",
    )

    inventory_skills = _skill_names_from_inventory(root)
    physical_skills = set() if no_external else _physical_skill_names()
    available_skills = inventory_skills | physical_skills
    add(
        "semantica:projec_cdx_semantic_layer_registered",
        "PASS" if "projec-cdx-semantic-layer" in available_skills else "FAIL",
        "projec-cdx-semantic-layer",
    )
    add(
        "skills_resolved",
        "PASS" if available_skills else "FAIL",
        f"inventory={len(inventory_skills)} "
        + (
            f"physical={len(physical_skills)}"
            if not no_external
            else "physical=skipped(no_external)"
        ),
    )

    recipe_files = sorted((root / "recipes").glob("*.md")) if (root / "recipes").exists() else []
    add("recipes_resolved", "PASS" if recipe_files else "FAIL", f"{len(recipe_files)} recipes")

    selected_agents = SDU_AGENT_ORDER if agent.lower() == "all" else [agent]
    packets = [_agent_packet(root, agent_name, available_skills) for agent_name in selected_agents]
    for packet in packets:
        if not packet["skills"]:
            add(f"agent:{packet['agent']}:skills", "OBSERVED", "no preferred skill hint resolved")
        if not packet["recipes"]:
            add(f"agent:{packet['agent']}:recipes", "OBSERVED", "no preferred recipe hint resolved")

    statuses = [check.status for check in checks]
    if "FAIL" in statuses:
        status = "FAIL"
    elif "OBSERVED" in statuses:
        status = "OBSERVED"
    else:
        status = "PASS"

    return {
        "status": status,
        "mode": mode,
        "agent": agent,
        "root": str(root),
        "no_external": no_external,
        "dry_run": dry_run,
        "chain": NERVOUS_SYSTEM_CHAIN,
        "checks": [check.__dict__ for check in checks],
        "agents": packets,
        "canonical_sources": {
            "entrada": "README.md, AGENTS.md, MAPA_MAESTRO.md",
            "estado": "operativa/CURRENT.md, operativa/NEXT.md, operativa/TRACE.md",
            "orden": "tools/sdu_boot.ps1, tools/sdu_chain_resolver.py",
            "skills": "inventarios/SKILLS_UNIFIED_TABLE.csv",
            "recipes": "recipes/INDICE_RECETAS.md",
            "tools": "tools/",
            "semantica": "docs/referencia/semantic-layer.md + projec-cdx-semantic-layer + operativa/archive/legacy-root/20260616/CANON_SEMANTICO_WAVE_ATOMICA_METADATA_20260616.md",
            "modelo": "schema.json, index.json, live-manifest.json",
            "dataverse": "dataverse/DATAVERSE_OPERATIONAL_CHAIN_SOURCE_MAP.csv",
            "atomic": "atomic/CODEX_ATOMIC_ACTION_MATRIX.csv",
            "salida": "<RUNTIME_PATH>/README.md, docs/herramientas/cli-metadata.md",
        },
    }


def _print_text(payload: dict[str, Any]) -> None:
    print(f"STATUS: {payload['status']}")
    print(f"CHAIN: {payload['chain']}")
    for check in payload["checks"]:
        print(f"{check['status']} | {check['name']} | {check['detail']}")
    print("AGENTS:")
    for packet in payload["agents"]:
        print(
            f"- {packet['agent']}: skills={len(packet['skills'])} "
            f"recipes={len(packet['recipes'])} tools={len(packet['tools'])} "
            f"validators={len(packet['validators'])} evidence={len(packet['evidence'])}"
        )


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Resolve the local SDU agent capability chain.")
    parser.add_argument("--root", default=str(REPO_ROOT), help="Repository root.")
    parser.add_argument(
        "--mode", default="all", choices=["all", "check", "agents"], help="Resolution mode."
    )
    parser.add_argument("--agent", default=DEFAULT_AGENT, help="Agent name or All.")
    parser.add_argument(
        "--no-external", action="store_true", help="Keep remote/live surfaces closed."
    )
    parser.add_argument("--dry-run", action="store_true", help="Do not mutate anything.")
    parser.add_argument("--json", action="store_true", help="Emit JSON.")
    args = parser.parse_args(argv)

    payload = build_graph(
        Path(args.root),
        mode=args.mode,
        agent=args.agent,
        no_external=args.no_external,
        dry_run=args.dry_run,
    )
    if args.json:
        print(json.dumps(payload, indent=2, ensure_ascii=False))
    else:
        _print_text(payload)
    return 1 if payload["status"] == "FAIL" else 0


if __name__ == "__main__":
    raise SystemExit(main())
