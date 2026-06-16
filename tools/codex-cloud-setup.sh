#!/bin/sh
set -eu

default_repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
repo_root=${CODEX_SOURCE_TREE_PATH:-${CODEX_CLOUD_REPO_ROOT:-${1:-$default_repo_root}}}
worktree_root=${CODEX_WORKTREE_PATH:-${CODEX_CLOUD_WORKTREE:-${2:-$(pwd)}}}

case "$repo_root" in
  [A-Za-z]:*) repo_root=$default_repo_root ;;
esac

case "$worktree_root" in
  [A-Za-z]:*) worktree_root=$default_repo_root ;;
esac
bootstrap_sh="$repo_root/tools/codex-cloud-bootstrap.sh"
bootstrap_ps1="$repo_root/tools/codex-cloud-bootstrap.ps1"

cd "$worktree_root"

python_exe=python
if [ -x "./.venv/bin/python" ]; then
  python_exe="./.venv/bin/python"
elif [ -x "./.venv/Scripts/python.exe" ]; then
  python_exe="./.venv/Scripts/python.exe"
fi

"$python_exe" -m pip install -e ".[dev,agents-sdk,openai-orchestration]"

if command -v pwsh >/dev/null 2>&1; then
  pwsh -NoProfile -File "$bootstrap_ps1" -RepoRoot "$repo_root" -WorkspaceRoot "$worktree_root"
else
  sh "$bootstrap_sh" "$repo_root" "$worktree_root"
fi
