---
artifact_id: operativa/archive/legacy-root/20260622/CABINA_GOBIERNO_TOTAL_WAVE_POWERSHELL_COMMANDS_20260622.md
categoria: operativa
tipo: reporte
estado: en_revision
version: 2026.06.22
autoridad:
  tipo: owner
  referencia: '@SeshatSgin'
origen: Mixto
ubicacion_repo: operativa/archive/legacy-root/20260622/CABINA_GOBIERNO_TOTAL_WAVE_POWERSHELL_COMMANDS_20260622.md
etiquetas:
- cabina
- powershell
- vscode-insiders
- macro-wave
relacionados:
- tools/cabina/Invoke-CabinaGovernancePrecheck.ps1
- operativa/archive/legacy-root/20260622/CABINA_IDE_RUNNER_COMMAND_INDEX_20260622.csv
- operativa/archive/legacy-root/20260622/CABINA_TOTAL_STACK_COMMAND_SURFACE_MATRIX_20260622.csv
descripcion: Comandos PowerShell corregidos para ejecutar la wave desde la cabina VS Code Insiders sin depender de aliases fragiles.
fecha_evento: '2026-06-22'
---

# CABINA GOBIERNO TOTAL WAVE - POWERSHELL COMMANDS

## Regla rectora

La ejecucion prioriza VS Code Insiders como control-plane IDE, pero los comandos no dependen de que `code-insiders` este en PATH.

## Variables canonicas

```powershell
$WorkspaceRoot = 'C:\CEO\project-cdx'
$CodeInsiders = 'C:\Users\enzo1\AppData\Local\Programs\Microsoft VS Code Insiders\bin\code-insiders.cmd'
$Python = Join-Path $WorkspaceRoot '.venv\Scripts\python.exe'
```

## Precheck recomendado

```powershell
Set-Location -LiteralPath $WorkspaceRoot
& $CodeInsiders --version
& $CodeInsiders --status
& $Python -m tools.validate
& $Python tools\sdu_sentinel.py scan
& $Python tools\sdu_auto_remediation.py analyze
& $Python tools\sdu_sentinel.py check
& $Python -m pytest
git -C $WorkspaceRoot diff --check
git -C $WorkspaceRoot status --short --branch
```

## Runner seguro

```powershell
powershell -ExecutionPolicy Bypass -File tools\cabina\Invoke-CabinaGovernancePrecheck.ps1 -Json
```

## Correcciones aplicadas

- No usar `code-insiders` desnudo; usar ruta completa.
- No usar `python` desnudo; usar `.venv\Scripts\python.exe`.
- No pipear directamente despues de bloques `foreach`; materializar colecciones antes.
- No interpolar variables antes de `:` sin llaves; usar `"${name}:$value"`.
- No usar `pwsh -Command` para bloques largos; preferir `-File`.
- Para evidencia completa, preferir `ConvertTo-Json -Depth 5` antes que tablas truncables.

## Frontera

- No DB mutation.
- No cache cleanup.
- No MCP execution.
- No live write.
- No secretos.
- No push.
- No PR.
