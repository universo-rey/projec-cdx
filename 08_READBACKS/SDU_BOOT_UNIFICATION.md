# SDU_BOOT_UNIFICATION

Estado: PASS

## Contrato

CEO bootstrap MUST be manual and explicit.

## Endpoint de arranque

Windows Terminal y VS Code Insiders arrancan en modo seguro:

`pwsh -NoLogo -NoProfile`

## Arranque Manual CEO

Comando oficial:

`C:\CEO\start-ceo-manual.ps1`

Contenido:

`powershell -File C:\CEO\Start-CEO.ps1`

## Resultado

- Windows Terminal ya no ejecuta `C:\CEO\Start-CEO.ps1` en el arranque de perfiles PowerShell.
- VS Code Insiders mantiene `PowerShell 7 (CEO Safe)` con `-NoLogo` y `-NoProfile`.
- CEO se activa solo por decision explicita mediante el script manual.

## Backup

`C:\CEO\project-cdx\.codex\backups\boot-unification\20260625_221726`
