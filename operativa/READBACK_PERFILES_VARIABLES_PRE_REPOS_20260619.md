# READBACK_PERFILES_VARIABLES_PRE_REPOS_20260619

## Estado

`PASS`

## Objetivo

Congelar perfiles y variables de la cabina `C:\CEO` antes de mover repos, crear worktrees o abrir entornos aislados.

## Variables

- Variables `CEO_*`, `CODEX_*` y `SOURCE_TREE_PATH` persistidas en ambito `User` y reflejadas en `Process`.
- `CODEX_START_ROOT=C:\CEO`.
- `CODEX_PROJECT_ROOT=C:\CEO\project-cdx`.
- `CODEX_WORKBENCH_ROOT=C:\CEO\project-cdx` queda solo como alias legacy de compatibilidad.
- `CODEX_SOURCE_TREE_PATH=C:\CEO\repos`.
- `CODEX_WORKTREE_PATH=C:\CEO\worktrees`.
- `SOURCE_TREE_PATH=C:\CEO\repos`.
- No hay variables canonicas apuntando a `C:\` ni usando separador `/`.

## Perfiles

- `C:\CEO\Start-CEO.ps1` conserva la entrada operativa.
- `C:\CEO\CodexProfile.ps1` conserva el puente hacia `.codex`.
- `C:\CEO\Documents\PowerShell\profile.ps1` normalizado a `C:\CEO\Start-CEO.ps1`.
- `C:\CEO\Documents\PowerShell\Microsoft.PowerShell_profile.ps1` normalizado a `C:\CEO\Start-CEO.ps1`.
- `C:\Users\enzo1\.codex\profiles\powershell\CodexProfile.ps1` normalizado a rutas Windows nativas.

## Terminal

- Windows Terminal mantiene perfil por defecto `PowerShell`.
- `disabledProfileSources=Windows.Terminal.PowershellCore`.
- Los perfiles visibles abren con `pwsh.exe -NoLogo -NoExit -ExecutionPolicy Bypass -File "C:\CEO\Start-CEO.ps1"`.
- `startingDirectory=C:\CEO`.

## Evidencia

- `CEO_SAFE_START_OK`.
- `NO_BAD_ROOT_OR_FORWARD_SLASH_IN_CANONICAL_ENV`.
- Sin coincidencias activas para `C:/CEO` o `C:/Users` en perfiles revisados.
- Backups creados:
  - `C:\CEO\Documents\PowerShell\profile.ps1.bak-20260619-215721`.
  - `C:\CEO\Documents\PowerShell\Microsoft.PowerShell_profile.ps1.bak-20260619-215721`.
  - `C:\Users\enzo1\.codex\profiles\powershell\CodexProfile.ps1.bak-20260619-215721`.

## Path

- `User Path` queda intacto y sin duplicados observados.
- El perfil CEO arma `Process Path` dinamicamente con Git, Codex CLI, runtime Codex, PAC y rutas existentes.
- No se toco `Machine Path`.

## Delta

`perfiles_variables_sellados_pre_repos`

## Stop Condition

- No mover repos ni crear entornos aislados si `CEO_SAFE_START_OK` falla.
- No tocar variables de maquina ni secretos desde este carril.
- Reabrir solo si una terminal nueva no inicia en `C:\CEO`, si aparece una ruta activa `C:/CEO` o si una variable canonica vuelve a apuntar a `C:\`.
