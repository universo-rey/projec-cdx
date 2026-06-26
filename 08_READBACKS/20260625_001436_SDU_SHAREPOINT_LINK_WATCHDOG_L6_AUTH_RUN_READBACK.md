# SDU SharePoint Link Watchdog L6 Authenticated Run Readback

## Dictamen

YELLOW

El watchdog L6 read-only ejecuto una corrida autenticada contra `HUBDesarrollo` usando Azure CLI con PATH temporal.

No se detectaron writes remotos. La corrida llego a Dataverse y leyo `sharepointdocumentlocations`, pero no encontro filas.

## Resultado

- Run ID: `9570bd3b-ca64-472e-9cc5-9d78ee359770`
- Started at: `2026-06-25T03:14:28.8038957Z`
- Finished at: `2026-06-25T03:14:36.5643000Z`
- Mode: `READ_ONLY`
- Health: `YELLOW`
- Exit code: `1`
- Checks total: `3`
- Checks failed: `1`
- Locations reviewed: `0`

## Failed Check

```json
{
  "name": "sharepointdocumentlocations_has_rows",
  "ok": false,
  "severity": "WARN",
  "message": "sharepointdocumentlocations row count: 0.",
  "data": {
    "count": 0,
    "requireAtLeastOneLocation": false
  }
}
```

## Evidence

- Health: `C:\CEO\watchdog\logs\sharepoint_link_health.json`
- Events: `C:\CEO\watchdog\logs\sharepoint_link_events.jsonl`
- Alerts: `C:\CEO\watchdog\logs\alerts.jsonl`
- State: `C:\CEO\watchdog\state\sharepoint_link_last_run.json`
- Evidence: `C:\CEO\watchdog\evidence\sharepoint_link_watchdog_20260625_001428.json`

## SHA256

| Archivo | SHA256 |
|---|---|
| `C:\CEO\watchdog\config.sharepoint-link.json` | `C5C6E63D6EF737C22DBD9302B035822FABCCCDCCAD252776DB7F897AA9250EEE` |
| `C:\CEO\watchdog\watchdog-sharepoint-link.ps1` | `779056FDE2FC6466F9D2B53FDDFDF0324A20031CE88D9F4EB761F5F6211DF89E` |
| `C:\CEO\project-cdx\docs\watchdogs\SDU_SHAREPOINT_LINK_WATCHDOG_L6.md` | `3B0416930020F888B2033680D26CF17C601D9CAD22F220E8EED9CA8CC7629CE8` |
| `C:\CEO\watchdog\evidence\sharepoint_link_watchdog_20260625_001428.json` | `0A73467CB114A6569AA94617D26950FD42C63BF6EAA4A20C8F5E7A9E0A2C0992` |

## Correcciones Locales Aplicadas Antes De La Corrida

- Se ajusto `Get-Health` para aceptar colecciones vacias sin romper PowerShell 5.1.
- Se ajusto `Add-CheckAndEvent` para aceptar el primer check cuando la coleccion esta vacia.
- Se uso PATH temporal hacia `C:\Program Files\Microsoft SDKs\Azure\CLI2\wbin`; no se modifico PATH del sistema.

## No Writes Confirmados

- No Dataverse POST/PATCH/PUT/DELETE.
- No Microsoft Graph POST/PATCH/PUT/DELETE.
- No SharePoint create/update/delete.
- No Power Automate flow run.
- No scheduler registrado.
- No tokens impresos.
- No tokens persistidos.
- No push.
- No PR.

## Interpretacion

El acceso autenticado funciona, pero el entorno no devolvio filas en la tabla estandar `sharepointdocumentlocations`.

Como `requireAtLeastOneLocation=false`, la ausencia de filas es `WARN`, no `HIGH`.

## Proximo Paso Recomendado

Validar si el vinculo documental del carril usa realmente `sharepointdocumentlocations` estandar o si el modelo operativo vive en tablas `cr3c_*` / `SP Governance Model`.

No conviene cambiar `requireAtLeastOneLocation=true` hasta confirmar la fuente canonica del vinculo documental.
