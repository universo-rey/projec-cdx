# Codex Cloud Contract 20260615

## Proposito

Codex Cloud se usa para delegacion, orquestacion y trabajo repetible de varios pasos. La mesa local conserva evidencia, traza y versionado durable.

## Estado

`metadata_only_until_activation`

## Current Context

- repo root: C:\Users\enzo1\PROJEC CDX
- branch: codex/revisar-procesos-del-equipo
- remote: https://github.com/universo-rey/projec-cdx.git
- workspace root: C:\Users\enzo1\.codex\worktrees\49ea\PROJEC CDX
- mode: hybrid
- gate: metadata-only
- generated at: 2026-06-15T19:50:01.8169575-03:00

## Variables

- `CODEX_CLOUD_ENABLED` | default: `1` | Master switch for delegated cloud work.
- `CODEX_CLOUD_MODE` | default: `hybrid` | Execution mode: local, cloud, or hybrid.
- `CODEX_CLOUD_GATE` | default: `metadata-only` | Gate contract for metadata-only or higher.
- `CODEX_CLOUD_PROFILE` | default: `projec-cdx` | Project profile name.
- `CODEX_CLOUD_REPO_ROOT` | default: `C:\Users\enzo1\PROJEC CDX` | Canonical repo root.
- `CODEX_CLOUD_WORKTREE` | default: `C:\Users\enzo1\.codex\worktrees\49ea\PROJEC CDX` | Current isolated workspace path.
- `CODEX_CLOUD_BRANCH` | default: `codex/revisar-procesos-del-equipo` | Current branch for the lane.
- `CODEX_CLOUD_CONTRACT` | default: `C:\Users\enzo1\PROJEC CDX\operativa\CODEX_CLOUD_CONTRACT_20260615.md` | Contract document path.
- `CODEX_CLOUD_MAINTENANCE_LOG` | default: `C:\Users\enzo1\PROJEC CDX\operativa\CODEX_CLOUD_MAINTENANCE_20260615.md` | Maintenance log path.
- `CODEX_CLOUD_DATAVERSE_REGISTRY` | default: `C:\Users\enzo1\PROJEC CDX\dataverse\REGISTRO_CODEX_CLOUD_20260615.md` | Metadata-only Dataverse registry path.
- `CODEX_CLOUD_DATAVERSE_GATE` | default: `C:\Users\enzo1\PROJEC CDX\dataverse\GATE.md` | Dataverse gate file.
- `CODEX_CLOUD_DATAVERSE_BLOCKERS` | default: `C:\Users\enzo1\PROJEC CDX\dataverse\REGISTRO_BLOQUEOS.md` | Dataverse blocker registry.
- `CODEX_CLOUD_DATAVERSE_SOURCE_MAP` | default: `C:\Users\enzo1\PROJEC CDX\dataverse\MAPA_CONEXIONES_DATAVERSE.md` | Dataverse connection and drift map.
- `CODEX_CLOUD_DATAVERSE_PLAN` | default: `C:\Users\enzo1\PROJEC CDX\dataverse\PLAN_SEGUNDA_PASADA.md` | Dataverse second-pass plan.
- `OPENAI_MODEL` | default: `gpt-5.4-mini` | Optional fallback model when API mode is used.

`OPENAI_API_KEY` queda fuera del repo. Solo se usa si existe un carril API de respaldo.

## Contrato Operativo

- Un solo lane por vez.
- Sin comandos inventados si Codex Cloud no esta configurado.
- Sin live write sin gate explicito.
- Sin mezcla entre bootstrap cloud y limpieza local.
- Dataverse se usa como hidratacion metadata-only hasta nueva orden.

## Dataverse Hydration

- `dataverse/GATE.md` fija el gate local antes de cualquier live.
- `dataverse/REGISTRO_BLOQUEOS.md` registra las fronteras y decisiones.
- `dataverse/MAPA_CONEXIONES_DATAVERSE.md` da el mapa de conexiones y drift.
- `dataverse/PLAN_SEGUNDA_PASADA.md` sirve como plan de referencia para la segunda pasada.
- `dataverse/REGISTRO_CODEX_CLOUD_20260615.md` guarda el registro local del contrato.

## Scripts

- `tools/codex-cloud-bootstrap.ps1`
- `tools/codex-cloud-maintenance.ps1`

## Stop Conditions

- `CODEX_CLOUD_ENABLED=0`
- `CODEX_CLOUD_GATE` distinto de `metadata-only` sin orden nueva
- falta `dataverse/GATE.md`
- falta `dataverse/REGISTRO_BLOQUEOS.md`
- se detecta secreto o write live
- se intenta usar este contrato como sustituto de una configuracion real de Codex Cloud

## Resultado

La configuracion queda declarada, portable y auditable. La activacion real sigue separada del contrato.