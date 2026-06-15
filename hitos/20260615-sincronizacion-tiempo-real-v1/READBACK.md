# READBACK_SINCRONIZACION_TIEMPO_REAL_20260615

## Estado

HECHO_VERIFICADO: el contrato de sincronizacion local quedó definido y validado.

## Sistemas Tocados

- `README.md`
- `MAPA_MAESTRO.md`
- `operativa/CONTROL.md`
- `operativa/CURRENT.md`
- `operativa/NEXT.md`
- `operativa/TRACE.md`
- `patrones/`
- `procesos/`
- `tools/validate_proj_cdx_sync.ps1`
- `hitos/20260615-sincronizacion-tiempo-real-v1/`

## Sistemas No Tocados

- Secretos.
- `auth.json`.
- `cap_sid`.
- Global-state.
- SQLite.
- Dataverse live.
- Power Platform live.
- Microsoft live.
- Git remoto.

## Cambios

- Se definio el contrato de sincronizacion tiempo real.
- Se rehidrato el carril Dataverse local.
- Se reintrodujo `tracker.xlsx` en la navegacion principal.
- Se valido la alineacion local entre fuentes, outputs y cierres.

## Validacion

```powershell
pwsh -NoProfile -File "C:\Users\enzo1\PROJEC CDX\tools\validate_proj_cdx_sync.ps1"
```

## Riesgos

- Dataverse live sigue gateado.
- La sincronizacion es local/operativa; no implica refresco live automatico sin orden explicita.

## Rollback

Retirar el hito y revertir los enlaces de sincronizacion si la taxonomia cambia.

## Proximos Carriles

- Mantener el validador de sync como postcheck de cambios en fuentes vivas.
- Si aparece live Dataverse, exigir gate y orden explicita.
