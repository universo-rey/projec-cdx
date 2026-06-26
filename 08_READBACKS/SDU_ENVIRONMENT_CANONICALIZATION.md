# SDU_ENVIRONMENT_CANONICALIZATION

Estado: PASS

## Objetivo

Alinear PATH y entorno entre Terminal CEO y VS Code Insiders.

## Fuente canonica

- Metodo: `CEO_PATH_CANONICAL_FROM_00_ENV_10_ISOLATION`
- Capas usadas:
  - `C:\CEO\core\00-Env.ps1`
  - `C:\CEO\core\10-Isolation.ps1`
  - `C:\CEO\policy.json`
- Bootstrap completo: no ejecutado.
- Archivo exportado:
  - `C:\CEO\project-cdx\PATH_CANONICAL.json`

## Cambio aplicado

- Archivo actualizado:
  - `C:\Users\enzo1\AppData\Roaming\Code - Insiders\User\settings.json`
- Clave actualizada:
  - `terminal.integrated.env.windows.PATH`
- Valor aplicado:
  - PATH canonico exportado en `PATH_CANONICAL.json`

## Backup

- Backup previo:
  - `C:\CEO\project-cdx\.codex\backups\environment-canonicalization\20260625_222329\vscode-insiders-settings.json`

## Validacion

- `PATH_CANONICAL.json`: JSON valido.
- `settings.json`: JSON valido.
- PATH de VS Code Insiders coincide exactamente con `PATH_CANONICAL.json`.
- Perfil terminal VS Code Insiders:
  - `PowerShell 7 (CEO Safe)`
- CWD terminal VS Code Insiders:
  - `C:\`

## Node

- Resultado validado fuera del sandbox:
  - `Get-Command node`: OK
  - Source: `C:\Users\enzo1\AppData\Local\Microsoft\WinGet\Packages\OpenJS.NodeJS.LTS_Microsoft.Winget.Source_8wekyb3d8bbwe\node-v24.17.0-win-x64\node.exe`
  - Version: `v24.17.0`

## Observaciones

- La sesion sandbox no puede ejecutar directamente `node.exe` en la ruta WinGet por restriccion de acceso local.
- La validacion operativa se realizo fuera del sandbox con autorizacion y con el mismo PATH persistido para VS Code.
- No se modifico Windows Terminal.
- No se reintrodujo autoboot.
- No se ejecutaron cambios destructivos.

## Criterio PASS

- Node visible con PATH canonico: PASS.
- VS Code Insiders usa PATH canonico: PASS.
- Backup creado antes del cambio: PASS.
- JSON valido: PASS.
- Bootstrap CEO sigue manual y explicito: PASS.
