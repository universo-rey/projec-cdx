# SDU SharePoint Link Watchdog L6

## Objetivo

Validar en modo read-only el vinculo Dataverse -> SharePoint del carril Escribania / Registro / Dataverse.

El watchdog lee `sharepointdocumentlocations` en Dataverse, obtiene la URL absoluta con
`RetrieveAbsoluteAndSiteCollectionUrl()`, resuelve la ubicacion contra Microsoft Graph,
confirma el `driveItem` y, si es carpeta, lista hijos de primer nivel para evaluar hints
documentales.

## Modo

- `READ_ONLY`
- Local-first
- Evidencia JSON / JSONL
- Sin reparacion automatica
- Sin scheduler automatico

## Que Valida

- Acceso GET a Dataverse Web API.
- Existencia de filas en `sharepointdocumentlocations`.
- Resolucion de `AbsoluteUrl` y `SiteCollectionUrl`.
- Resolucion de sitio SharePoint por Graph.
- Resolucion de document library / drive.
- Existencia del `driveItem`.
- Lectura de hijos de primer nivel si el item es carpeta.
- Hints de estructura documental sin bloquear por defecto.

## Que No Valida

- No crea carpetas.
- No crea ni modifica `sharepointdocumentlocation`.
- No ejecuta flows.
- No modifica Dataverse.
- No modifica SharePoint.
- No modifica permisos.
- No verifica contenido profundo ni archivos internos.

## Ejecucion Con Tokens Manuales

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File "C:\CEO\watchdog\watchdog-sharepoint-link.ps1" `
  -DataverseUrl "https://org084965d9.crm.dynamics.com" `
  -DataverseToken $env:DATAVERSE_ACCESS_TOKEN `
  -GraphToken $env:GRAPH_ACCESS_TOKEN
```

Los tokens no se imprimen ni se guardan.

## Ejecucion Con Azure CLI

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File "C:\CEO\watchdog\watchdog-sharepoint-link.ps1" `
  -DataverseUrl "https://org084965d9.crm.dynamics.com" `
  -UseAzureCliToken
```

El script pide tokens a Azure CLI con:

```powershell
az account get-access-token --resource <DataverseUrl> --query accessToken -o tsv
az account get-access-token --resource https://graph.microsoft.com --query accessToken -o tsv
```

## Outputs

- `C:\CEO\watchdog\logs\sharepoint_link_health.json`
- `C:\CEO\watchdog\logs\sharepoint_link_events.jsonl`
- `C:\CEO\watchdog\logs\alerts.jsonl`
- `C:\CEO\watchdog\state\sharepoint_link_last_run.json`
- `C:\CEO\watchdog\evidence\sharepoint_link_watchdog_YYYYMMDD_HHMMSS.json`

## Exit Codes

- `0`: `HEALTHY`
- `1`: `YELLOW`
- `2`: `DEGRADED`

## Interpretacion

- `HEALTHY`: no hay checks fallidos `WARN` ni `HIGH`.
- `YELLOW`: hay fallas `WARN`, sin fallas `HIGH`.
- `DEGRADED`: existe al menos una falla `HIGH`.

## Scheduler Opcional

No activado automaticamente. Bloque sugerido para owner gate posterior:

```powershell
$Action = New-ScheduledTaskAction `
  -Execute "powershell.exe" `
  -Argument "-NoProfile -ExecutionPolicy Bypass -File `"C:\CEO\watchdog\watchdog-sharepoint-link.ps1`" -UseAzureCliToken"

$Trigger = New-ScheduledTaskTrigger `
  -Once `
  -At (Get-Date).AddMinutes(1) `
  -RepetitionInterval (New-TimeSpan -Minutes 10)

Register-ScheduledTask `
  -TaskName "CEO_WATCHDOG_SHAREPOINT_LINK" `
  -Action $Action `
  -Trigger $Trigger `
  -Description "SDU L6 READ-ONLY watchdog para validar vinculo Dataverse SharePoint Document Location" `
  -Force
```

## Riesgos

- Token faltante o vencido.
- Ambiente Dataverse equivocado si no se pasa `-DataverseUrl`.
- Graph sin permisos suficientes para resolver sitio, drive o carpeta.
- Document Location sin URL absoluta.
- Carpeta existe pero hijos no son legibles por permisos.

## Proximo Modulo

Flow run history read-only: inventario de ejecuciones de Power Automate sin ejecutar flows ni modificar estado.
