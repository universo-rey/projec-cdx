# Codex Cloud Contract 20260615

## Proposito

Codex Cloud se usa para delegacion, orquestacion y trabajo repetible de varios pasos. La mesa local conserva evidencia, traza y versionado durable.

## Estado

`connected_read_observe`

## Current Context

- active repo root: C:/CEO/project-cdx
- metadata root: C:/CEO/.metadata
- worktree root: C:/CEO/worktrees
- source tree root: C:/Users/enzo1/Documents/GitHub
- retired source root: C:/CEO/repos (does not currently exist; do not declare canonical)
- current local branch: detect with git
- remote: https://github.com/universo-rey/projec-cdx.git
- mode: connected
- gate: read-observe
- generated at: 2026-06-16T07:06:46.4472407-03:00

## Variables

- `CODEX_CLOUD_ENABLED` | default: `1` | Cloud connection switch.
- `CODEX_CLOUD_MODE` | default: `connected` | Cloud is connected for observation only.
- `CODEX_CLOUD_GATE` | default: `read-observe` | Hard cloud boundary.
- `CODEX_CLOUD_MUTATION_ALLOWED` | default: `0` | Cloud must not mutate.
- `CODEX_CLOUD_LOCAL_PATHS_MODE` | default: `reference-only` | Windows paths are local evidence only.
- `CODEX_CLOUD_PROFILE` | default: `project-cdx` | Project profile name.
- `CODEX_PROJECT_ROOT` | default: `C:/CEO/project-cdx` | Local project root.
- `CODEX_METADATA_ROOT` | default: `C:/CEO/.metadata` | Local metadata root.
- `CODEX_WORKTREE_PATH` | default: `C:/CEO/worktrees` | Local worktree root.
- `CODEX_SOURCE_TREE_PATH` | default: `C:/Users/enzo1/Documents/GitHub` | Current local source tree root.
- `CODEX_RETIRED_REPOS_ROOT` | default: `C:/CEO/repos` | Retired/nonexistent root; do not assume it exists.
- `CODEX_CLOUD_REPO_ROOT` | default: `.` | Repo-relative cloud reference.
- `CODEX_CLOUD_WORKTREE` | default: `.` | Repo-relative cloud workspace reference.
- `CODEX_CLOUD_BRANCH` | default: `main` | Current branch for the lane.
- `OPENAI_MODEL` | default: `gpt-5.4-mini` | Optional fallback model when API mode is used.

`OPENAI_API_KEY` queda fuera del repo. Solo se usa si existe un carril API de respaldo.

## Contrato Operativo

- Codex Cloud is read-observe only.
- No file writes, dependency installs, migrations, branch operations, PR creation, deploys, or remote mutations from Codex Cloud.
- GitHub Actions CI is separate from Codex Cloud.
- Promotion remains manual, owner-gated, rollback-backed, and postchecked.
- Windows absolute paths are local evidence only for cloud.

## Dataverse Hydration

- `dataverse/GATE.md` fija el gate local antes de cualquier live.
- `dataverse/REGISTRO_BLOQUEOS.md` registra las fronteras y decisiones.
- `dataverse/MAPA_CONEXIONES_DATAVERSE.md` da el mapa de conexiones y drift.
- `dataverse/PLAN_SEGUNDA_PASADA.md` sirve como plan de referencia para la segunda pasada.
- `dataverse/REGISTRO_CODEX_CLOUD_20260615.md` guarda el registro local historico del contrato.

## Scripts

- `tools/codex-cloud-bootstrap.ps1`
- `tools/codex-cloud-maintenance.ps1`

## Stop Conditions

- `CODEX_CLOUD_ENABLED=0`
- `CODEX_CLOUD_GATE` distinto de `read-observe`
- falta `dataverse/GATE.md`
- falta `dataverse/REGISTRO_BLOQUEOS.md`
- se detecta secreto o write live
- se intenta usar este contrato como sustituto de una configuracion real de Codex Cloud

## Resultado

La configuracion queda declarada, portable y auditable. La activacion real sigue separada del contrato.
