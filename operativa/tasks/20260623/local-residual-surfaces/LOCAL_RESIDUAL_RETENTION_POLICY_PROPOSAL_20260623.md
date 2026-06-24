---
artifact_id: operativa/runtime-events/LOCAL_RESIDUAL_RETENTION_POLICY_PROPOSAL_20260623.md
categoria: operativa
tipo: plan
estado: en_revision
version: v0.6.0-rc1
fecha_evento: '2026-06-23'
autoridad:
  tipo: sistema
  referencia: CABINA_GOBIERNO_TOTAL
origen: GitHub
ubicacion_repo: operativa/runtime-events/LOCAL_RESIDUAL_RETENTION_POLICY_PROPOSAL_20260623.md
etiquetas:
  - runtime
  - residual
  - retention
  - policy
relacionados:
  - operativa/runtime-events/LOCAL_RESIDUAL_SURFACES_CLASSIFICATION_20260623.md
descripcion: Propuesta no aplicada de politica de retencion para superficies residuales locales.
---
# LOCAL RESIDUAL RETENTION POLICY PROPOSAL 20260623

## Estado

PROPOSAL_ONLY_NOT_APPLIED

Esta politica no fue aplicada. No se modifico .gitignore, no se movieron archivos y no se limpio ningun temporal.

## 1. Que se ignora por gitignore

Propuesta inicial para carril futuro APPLY_LOCAL_RETENTION_POLICY_G1:

```gitignore
# Local temp/work
.tmp_*
work/

# Backups
*.previous-*
*.bak

# Raw evidence / generated bulk outputs
.cabina/organizacion-total/out/*.csv
.cabina/organizacion-total/out/*raw*
.cabina/organizacion-total/logs/

# Local-only runtime evidence candidates
# revisar antes de aplicar:
# operativa/*.csv
# operativa/*.csv.meta.json
```

## 2. Que queda visible como dirty esperado

- Readbacks locales no canonizados.
- Backups .previous-*.
- Propuestas declarativas no adoptadas.
- Evidencia operativa local no incluida en el commit runtime.
- El script tools/promote_sdu_manifesto_dataverse.ps1 mientras owner no decida normalizar/revertir/promover.

## 3. Que debe moverse a archivo local en carril posterior

- Propuestas antiguas o multiples versiones de readbacks bajo .cabina/organizacion-total/out si owner quiere archivo historico local.
- Backups .previous-* si se adopta ventana de retencion.
- Evidencia CSV local si se decide conservar fuera del repo versionable.

## 4. Que nunca se versiona

- Dumps, trazas, logs, evidencia cruda, CSV masivos y temporales.
- Backups mecanicos salvo excepcion doctrinal explicita.
- Cualquier archivo con secretos o valores no saneados.

## 5. Que puede convertirse en delta futuro

- tools/promote_sdu_manifesto_dataverse.ps1 solo si owner confirma cambio funcional real.
- Propuestas de configuracion bajo .cabina/organizacion-total/config y .cabina/organizacion-total/out solo tras carril especifico.
- Readbacks finales saneados si se decide canonizar evidencia documental.

## 6. Que requiere decision owner

- Normalizacion del script tracked modificado.
- Retencion o ignore de backups .previous-*.
- Retencion/versionado de evidencia operativa CEO_RUNTIME_*.
- Adopcion o descarte de proposals y patch proposals.

## 7. Warning aceptable de ceo-runtime-status

WARN_EXPECTED_LOCAL_RESIDUAL_ONLY es aceptable si:

- Staging esta vacio.
- No hay push/PR/live.
- Todo residual esta clasificado.
- No hay secretos detectados ni lectura sensible requerida.
- El unico tracked modified queda bajo owner decision y no se trata como runtime roto.

Deja de ser aceptable si aparece un cambio funcional no clasificado, un archivo staged, un secreto, un drift remoto/live o un residuo fuera de categorias gobernadas.
