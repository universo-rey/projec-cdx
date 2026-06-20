# READBACK_CEO_ENV_TERMINAL_20260619

## Estado
HECHO_VERIFICADO

## Alcance
- Variables persistidas en ambito `User`, no `Machine`.
- Perfiles PowerShell alineados a `C:\CEO\Start-CEO.ps1`.
- Windows Terminal reinstalado desde `C:\CEO\windows-terminal\settings.json`.
- Rutas activas normalizadas con separador Windows nativo `\`.

## Variables Rectoras
- `CEO_ROOT=C:\CEO`
- `CEO_PROJECT_CDX_ROOT=C:\CEO\project-cdx`
- `CEO_REPOS_ROOT=C:\CEO\repos`
- `CEO_WORKTREES_ROOT=C:\CEO\worktrees`
- `CEO_AGENTS_ROOT=C:\CEO\agents`
- `CEO_SKILLS_ROOT=C:\CEO\skills`
- `CEO_CHAINS_ROOT=C:\CEO\chains`
- `CEO_M365_ROOT=C:\CEO\m365`
- `CEO_DATAVERSE_ROOT=C:\CEO\dataverse`
- `CEO_RUNTIME_ROOT=C:\CEO\runtime`
- `CEO_TOOLS_ROOT=C:\CEO\tools`
- `CEO_METADATA_ROOT=C:\CEO\.metadata`
- `CEO_INBOX_ROOT=C:\CEO\inbox`

## Variables Codex
- `CODEX_START_ROOT=C:\CEO`
- `CODEX_WORKBENCH_ROOT=C:\CEO\project-cdx`
- `CODEX_PROJECT_ROOT=C:\CEO\project-cdx`
- `CODEX_SOURCE_TREE_PATH=C:\CEO\repos`
- `CODEX_WORKTREE_PATH=C:\CEO\worktrees`
- `CODEX_METADATA_ROOT=C:\CEO\.metadata`
- `CODEX_CABINA_ROOT=C:\CEO`
- `CODEX_PAC_PATH=C:\CEO\tools\pac\microsoft.powerapps.cli.2.8.1\tools\pac.exe`
- `SOURCE_TREE_PATH=C:\CEO\repos`

## Terminal
- Perfil por defecto: `PowerShell`.
- Comando: `"C:\Program Files\PowerShell\7\pwsh.exe" -NoLogo -NoExit -ExecutionPolicy Bypass -File "C:\CEO\Start-CEO.ps1"`.
- Directorio inicial: `C:\CEO`.
- Fuente dinamica bloqueada: `Windows.Terminal.PowershellCore`.
- Perfil elevado disponible: `Admin-CEO`.

## Evidencia
- Postcheck: `CEO_SAFE_START_OK`.
- Snapshot previo de variables: `C:\CEO\windows-profile\env-user-snapshot-20260619-193138.json`.
- Backup de Windows Terminal: `C:\Users\enzo1\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json.bak-20260619-193149`.
- Busqueda en perfiles activos: sin coincidencias para rutas CEO con barra `/`.

## Stop Condition
- No tocar variables de maquina ni secretos.
- Reabrir solo si una terminal nueva no inicia en `C:\CEO`, si aparece una ruta CEO activa con barra `/`, o si `CEO_SAFE_START_OK` falla.
