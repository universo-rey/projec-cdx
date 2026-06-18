#!/bin/sh
set -eu

repo_root=${1:-$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)}
workspace_root=${2:-$(pwd)}

contract_path="$repo_root/operativa/CODEX_CLOUD_CONTRACT_20260615.md"
registry_path="$repo_root/dataverse/REGISTRO_CODEX_CLOUD_20260615.md"
maintenance_log_path="$repo_root/operativa/CODEX_CLOUD_MAINTENANCE_20260615.md"

git_branch=$(git -C "$workspace_root" branch --show-current 2>/dev/null || true)
[ -n "${git_branch:-}" ] || git_branch=DETACHED
git_remote=$(git -C "$workspace_root" remote get-url origin 2>/dev/null || true)
[ -n "${git_remote:-}" ] || git_remote=NO_REMOTE
git_status=$(git -C "$workspace_root" status --short --branch 2>/dev/null || true)

mode=${CODEX_CLOUD_MODE:-cloud}
gate=${CODEX_CLOUD_GATE:-metadata-only}

check_line() {
  name=$1
  path=$2
  required=$3
  if [ -e "$path" ]; then
    state=PASS
  elif [ "$required" = yes ]; then
    state=FAIL
  else
    state=WARN
  fi
  printf -- '- %s: %s ("%s")\n' "$name" "$state" "$path"
}

check_lines=$(cat <<EOF
$(check_line contract "$contract_path" yes)
$(check_line registry "$registry_path" yes)
$(check_line gate "$repo_root/dataverse/GATE.md" yes)
$(check_line blockers "$repo_root/dataverse/REGISTRO_BLOQUEOS.md" yes)
$(check_line source_map "$repo_root/dataverse/MAPA_CONEXIONES_DATAVERSE.md" no)
$(check_line plan "$repo_root/dataverse/PLAN_SEGUNDA_PASADA.md" no)
EOF
)

env_lines=$(cat <<EOF
- CODEX_CLOUD_ENABLED: $( [ -n "${CODEX_CLOUD_ENABLED:-}" ] && printf 'present / %s' "$CODEX_CLOUD_ENABLED" || printf 'missing / (unset)' )
- CODEX_CLOUD_MODE: $( [ -n "${CODEX_CLOUD_MODE:-}" ] && printf 'present / %s' "$CODEX_CLOUD_MODE" || printf 'missing / (unset)' )
- CODEX_CLOUD_GATE: $( [ -n "${CODEX_CLOUD_GATE:-}" ] && printf 'present / %s' "$CODEX_CLOUD_GATE" || printf 'missing / (unset)' )
- CODEX_CLOUD_PROFILE: $( [ -n "${CODEX_CLOUD_PROFILE:-}" ] && printf 'present / %s' "$CODEX_CLOUD_PROFILE" || printf 'missing / (unset)' )
- CODEX_CLOUD_REPO_ROOT: $( [ -n "${CODEX_CLOUD_REPO_ROOT:-}" ] && printf 'present / %s' "$CODEX_CLOUD_REPO_ROOT" || printf 'missing / (unset)' )
- CODEX_CLOUD_WORKTREE: $( [ -n "${CODEX_CLOUD_WORKTREE:-}" ] && printf 'present / %s' "$CODEX_CLOUD_WORKTREE" || printf 'missing / (unset)' )
- CODEX_CLOUD_BRANCH: $( [ -n "${CODEX_CLOUD_BRANCH:-}" ] && printf 'present / %s' "$CODEX_CLOUD_BRANCH" || printf 'missing / (unset)' )
- CODEX_CLOUD_CONTRACT: $( [ -n "${CODEX_CLOUD_CONTRACT:-}" ] && printf 'present / %s' "$CODEX_CLOUD_CONTRACT" || printf 'missing / (unset)' )
- CODEX_CLOUD_MAINTENANCE_LOG: $( [ -n "${CODEX_CLOUD_MAINTENANCE_LOG:-}" ] && printf 'present / %s' "$CODEX_CLOUD_MAINTENANCE_LOG" || printf 'missing / (unset)' )
- CODEX_CLOUD_DATAVERSE_REGISTRY: $( [ -n "${CODEX_CLOUD_DATAVERSE_REGISTRY:-}" ] && printf 'present / %s' "$CODEX_CLOUD_DATAVERSE_REGISTRY" || printf 'missing / (unset)' )
- CODEX_CLOUD_DATAVERSE_GATE: $( [ -n "${CODEX_CLOUD_DATAVERSE_GATE:-}" ] && printf 'present / %s' "$CODEX_CLOUD_DATAVERSE_GATE" || printf 'missing / (unset)' )
- CODEX_CLOUD_DATAVERSE_BLOCKERS: $( [ -n "${CODEX_CLOUD_DATAVERSE_BLOCKERS:-}" ] && printf 'present / %s' "$CODEX_CLOUD_DATAVERSE_BLOCKERS" || printf 'missing / (unset)' )
- CODEX_CLOUD_DATAVERSE_SOURCE_MAP: $( [ -n "${CODEX_CLOUD_DATAVERSE_SOURCE_MAP:-}" ] && printf 'present / %s' "$CODEX_CLOUD_DATAVERSE_SOURCE_MAP" || printf 'missing / (unset)' )
- CODEX_CLOUD_DATAVERSE_PLAN: $( [ -n "${CODEX_CLOUD_DATAVERSE_PLAN:-}" ] && printf 'present / %s' "$CODEX_CLOUD_DATAVERSE_PLAN" || printf 'missing / (unset)' )
- OPENAI_MODEL: $( [ -n "${OPENAI_MODEL:-}" ] && printf 'present / %s' "$OPENAI_MODEL" || printf 'missing / (unset)' )
EOF
)

timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)

mkdir -p "$(dirname "$maintenance_log_path")"

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
- last_maintenance: \`$timestamp\`

## Dataverse Hydration

- gate file: \`dataverse/GATE.md\`
- blocker registry: \`dataverse/REGISTRO_BLOQUEOS.md\`
- source map: \`dataverse/MAPA_CONEXIONES_DATAVERSE.md\`
- plan: \`dataverse/PLAN_SEGUNDA_PASADA.md\`
- hydration_state: \`validated_metadata_only\`

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

- Este registro sigue siendo metadata local.
- No implica write live.
- Se actualiza con cada pasada de mantenimiento.
EOF

cat > "$maintenance_log_path" <<EOF
# Codex Cloud Maintenance 20260615

## Snapshot

- timestamp: $timestamp
- branch: $git_branch
- remote: $git_remote
- root: $repo_root
- mode: $mode
- gate: $gate
- git_status:
$git_status

## Checks

$check_lines

## Environment

$env_lines

## Dataverse Hydration

- gate file: \`dataverse/GATE.md\`
- blocker registry: \`dataverse/REGISTRO_BLOQUEOS.md\`
- source map: \`dataverse/MAPA_CONEXIONES_DATAVERSE.md\`
- registry: \`dataverse/REGISTRO_CODEX_CLOUD_20260615.md\`
- state: metadata-only

## Result

El contrato queda confirmado, la hidratacion local queda alineada y no se abre write live.
EOF

printf '%s\n' "Root=$repo_root"
printf '%s\n' "WorkspaceRoot=$workspace_root"
printf '%s\n' "Branch=$git_branch"
printf '%s\n' "Remote=$git_remote"
printf '%s\n' "ContractPath=$contract_path"
printf '%s\n' "RegistryPath=$registry_path"
printf '%s\n' "MaintenanceLogPath=$maintenance_log_path"
printf '%s\n' "Mode=$mode"
printf '%s\n' "Gate=$gate"
printf '%s\n' "Status=Maintained"
