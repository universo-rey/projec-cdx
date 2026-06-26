# SDU SharePoint Link Watchdog L6 Readback

## Dictamen

PARTIAL

El watchdog L6 read-only fue implementado y validado sintacticamente. No se ejecuto corrida autenticada porque no se pasaron tokens ni se abrio gate de ejecucion live read en este paso.

Estado operativo: `READY_FOR_AUTHENTICATED_READONLY_RUN`.

## Archivos Creados O Modificados

- `C:\CEO\watchdog\config.sharepoint-link.json`
- `C:\CEO\watchdog\watchdog-sharepoint-link.ps1`
- `C:\CEO\watchdog\logs\`
- `C:\CEO\watchdog\state\`
- `C:\CEO\watchdog\evidence\`
- `C:\CEO\project-cdx\docs\watchdogs\SDU_SHAREPOINT_LINK_WATCHDOG_L6.md`
- `C:\CEO\project-cdx\08_READBACKS\20260625_000033_SDU_SHAREPOINT_LINK_WATCHDOG_L6_READBACK.md`

## SHA256

| Archivo | SHA256 |
|---|---|
| `C:\CEO\watchdog\config.sharepoint-link.json` | `C5C6E63D6EF737C22DBD9302B035822FABCCCDCCAD252776DB7F897AA9250EEE` |
| `C:\CEO\watchdog\watchdog-sharepoint-link.ps1` | `907978B8AE1D83B535BC6B8A53D57C3D86F6F985A195D69DE90B12450D5D8C4D` |
| `C:\CEO\project-cdx\docs\watchdogs\SDU_SHAREPOINT_LINK_WATCHDOG_L6.md` | `3B0416930020F888B2033680D26CF17C601D9CAD22F220E8EED9CA8CC7629CE8` |

Nota: el hash del readback se calcula externamente despues de su escritura final para evitar autocontenido circular.

## Validacion Sintactica

Comando equivalente ejecutado:

```powershell
powershell.exe -NoProfile -Command '$parseErrors = $null; $null = [System.Management.Automation.PSParser]::Tokenize((Get-Content -Raw ''C:\CEO\watchdog\watchdog-sharepoint-link.ps1''), [ref]$parseErrors); if ($parseErrors) { $parseErrors | ConvertTo-Json -Depth 5; exit 1 } else { ''PS_PARSE_OK'' }'
```

Resultado:

```text
PS_PARSE_OK
```

Validacion adicional:

```text
SCRIPTBLOCK_PARSE_OK
```

## Ejecucion Autenticada

No ejecutada.

Motivo:

- El config queda editable con `https://TU_ORG.crm.dynamics.com`.
- No se pasaron `DATAVERSE_ACCESS_TOKEN` ni `GRAPH_ACCESS_TOKEN`.
- No se pidio corrida con `-UseAzureCliToken`.
- Se evito cualquier live read no autorizado adicional.

## Limites Confirmados

- No Dataverse POST/PATCH/PUT/DELETE.
- No Microsoft Graph POST/PATCH/PUT/DELETE.
- No SharePoint folder create.
- No `sharepointdocumentlocation` create.
- No Power Automate flow run.
- No tokens impresos.
- No tokens persistidos.
- No scheduler registrado.
- No git push.
- No PR.

## Proximo Paso Recomendado

Ejecutar una corrida autenticada read-only con owner gate:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File "C:\CEO\watchdog\watchdog-sharepoint-link.ps1" `
  -DataverseUrl "https://org084965d9.crm.dynamics.com" `
  -UseAzureCliToken
```

Si la corrida devuelve `YELLOW` o `DEGRADED`, revisar:

- `C:\CEO\watchdog\logs\sharepoint_link_health.json`
- `C:\CEO\watchdog\logs\sharepoint_link_events.jsonl`
- `C:\CEO\watchdog\logs\alerts.jsonl`
- `C:\CEO\watchdog\state\sharepoint_link_last_run.json`
- `C:\CEO\watchdog\evidence\sharepoint_link_watchdog_YYYYMMDD_HHMMSS.json`
