# Receta - Promocion Huella Tenant Dataverse

Use esta receta cuando el owner aprueba una huella atomica y pide promoverla a
tenant y Dataverse.

## Formula

`orden viva -> tenant confirmado -> target exacto -> metadata pointer -> postcheck -> canon`

## Reglas

- No publicar payload sensible.
- No abrir documentos ni reproducir titulos sensibles.
- No activar flows.
- No consumir workqueueitems por inferencia.
- No declarar bloqueo real sin autoridad humana.

## Tool

```powershell
pwsh -NoProfile -File "C:/Users/enzo1/PROJEC CDX/tools/promote_sdu_manifesto_dataverse.ps1"
```

## Postcheck

`source_count=1` y `evidence_count=1` por `canonical_id`.
