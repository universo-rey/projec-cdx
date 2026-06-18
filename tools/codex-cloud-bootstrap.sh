#!/bin/sh
set -eu

repo_root=${1:-$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)}
workspace_root=${2:-$(pwd)}
mode=${MODE:-cloud}
gate=${GATE:-metadata-only}

contract_path="$repo_root/operativa/CODEX_CLOUD_CONTRACT_20260615.md"
registry_path="$repo_root/dataverse/REGISTRO_CODEX_CLOUD_20260615.md"
maintenance_log_path="$repo_root/operativa/CODEX_CLOUD_MAINTENANCE_20260615.md"

git_branch=$(git -C "$workspace_root" branch --show-current 2>/dev/null || true)
[ -n "${git_branch:-}" ] || git_branch=DETACHED
git_remote=$(git -C "$workspace_root" remote get-url origin 2>/dev/null || true)
[ -n "${git_remote:-}" ] || git_remote=NO_REMOTE

timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)

mkdir -p "$(dirname "$contract_path")" "$(dirname "$registry_path")"

cat > "$contract_path" <<EOF
# Codex Cloud Contract 20260615

## Proposito

Codex Cloud se usa para delegacion, orquestacion y trabajo repetible de varios pasos. La mesa local conserva evidencia, traza y versionado durable.

## Estado

\`metadata_only_until_activation\`

## Current Context

- repo root: $repo_root
- branch: $git_branch
- remote: $git_remote
- workspace root: $workspace_root
- mode: $mode
- gate: $gate
- generated at: $timestamp

## Variables

- \`CODEX_CLOUD_ENABLED\` | default: \`1\` | Master switch for delegated cloud work.
- \`CODEX_CLOUD_MODE\` | default: \`$mode\` | Execution mode: local, cloud, or hybrid.
- \`CODEX_CLOUD_GATE\` | default: \`$gate\` | Gate contract for metadata-only or higher.
- \`CODEX_CLOUD_PROFILE\` | default: \`projec-cdx\` | Project profile name.
- \`CODEX_CLOUD_REPO_ROOT\` | default: \`$repo_root\` | Canonical repo root.
- \`CODEX_CLOUD_WORKTREE\` | default: \`$workspace_root\` | Current isolated workspace path.
- \`CODEX_CLOUD_BRANCH\` | default: \`$git_branch\` | Current branch for the lane.
- \`CODEX_CLOUD_CONTRACT\` | default: \`$contract_path\` | Contract document path.
- \`CODEX_CLOUD_MAINTENANCE_LOG\` | default: \`$maintenance_log_path\` | Maintenance log path.
- \`CODEX_CLOUD_DATAVERSE_REGISTRY\` | default: \`$registry_path\` | Metadata-only Dataverse registry path.
- \`CODEX_CLOUD_DATAVERSE_GATE\` | default: \`$repo_root/dataverse/GATE.md\` | Dataverse gate file.
- \`CODEX_CLOUD_DATAVERSE_BLOCKERS\` | default: \`$repo_root/dataverse/REGISTRO_BLOQUEOS.md\` | Dataverse blocker registry.
- \`CODEX_CLOUD_DATAVERSE_SOURCE_MAP\` | default: \`$repo_root/dataverse/MAPA_CONEXIONES_DATAVERSE.md\` | Dataverse connection and drift map.
- \`CODEX_CLOUD_DATAVERSE_PLAN\` | default: \`$repo_root/dataverse/PLAN_SEGUNDA_PASADA.md\` | Dataverse second-pass plan.
- \`OPENAI_MODEL\` | default: \`gpt-5.4-mini\` | Optional fallback model when API mode is used.

\`OPENAI_API_KEY\` queda fuera del repo. Solo se usa si existe un carril API de respaldo.

## Contrato Operativo

- Un solo lane por vez.
- Sin comandos inventados si Codex Cloud no esta configurado.
- Sin live write sin gate explicito.
- Sin mezcla entre bootstrap cloud y limpieza local.
- Dataverse se usa como hidratacion metadata-only hasta nueva orden.

## Stop Conditions

- \`CODEX_CLOUD_ENABLED=0\`
- \`CODEX_CLOUD_GATE\` distinto de \`metadata-only\` sin orden nueva
- falta \`dataverse/GATE.md\`
- falta \`dataverse/REGISTRO_BLOQUEOS.md\`
- se detecta secreto o write live
- se intenta usar este contrato como sustituto de una configuracion real de Codex Cloud

## Resultado

La configuracion queda declarada, portable y auditable. La activacion real sigue separada del contrato.
EOF

cat > "$registry_path" <<EOF
# Registro Codex Cloud 20260615

## Estado

\`metadata_only\`

## Identidad

- contract: \`operativa/CODEX_CLOUD_CONTRACT_20260615.md\`
- bootstrap: \`tools/codex-cloud-bootstrap.sh\`
- maintenance: \`tools/codex-cloud-maintenance.sh\`
- mode: \`$mode\`
- gate: \`$gate\`
- dataverse_write: \`no\`
- generated at: \`$timestamp\`

## Dataverse Hydration

- gate file: \`dataverse/GATE.md\`
- blocker registry: \`dataverse/REGISTRO_BLOQUEOS.md\`
- source map: \`dataverse/MAPA_CONEXIONES_DATAVERSE.md\`
- plan: \`dataverse/PLAN_SEGUNDA_PASADA.md\`
- hydration_state: \`pending_first_run\`

## Variables Declaradas

- \`CODEX_CLOUD_ENABLED\`
- \`CODEX_CLOUD_MODE\`
- \`CODEX_CLOUD_GATE\`
- \`CODEX_CLOUD_PROFILE\`
- \`CODEX_CLOUD_REPO_ROOT\`
- \`CODEX_CLOUD_WORKTREE\`
- \`CODEX_CLOUD_BRANCH\`
- \`CODEX_CLOUD_CONTRACT\`
- \`CODEX_CLOUD_MAINTENANCE_LOG\`
- \`CODEX_CLOUD_DATAVERSE_REGISTRY\`
- \`CODEX_CLOUD_DATAVERSE_GATE\`
- \`CODEX_CLOUD_DATAVERSE_BLOCKERS\`
- \`CODEX_CLOUD_DATAVERSE_SOURCE_MAP\`
- \`CODEX_CLOUD_DATAVERSE_PLAN\`

## Notas

- Este registro es metadata local.
- No implica write live.
- El script de mantenimiento lo actualiza cuando exista una primera corrida.
EOF

printf '%s\n' "ContractPath=$contract_path"
printf '%s\n' "RegistryPath=$registry_path"
printf '%s\n' "WorkspaceRoot=$workspace_root"
printf '%s\n' "Branch=$git_branch"
printf '%s\n' "Mode=$mode"
printf '%s\n' "Gate=$gate"
printf '%s\n' "Status=Prepared"
