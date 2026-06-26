---
artifact_id: operativa/tasks/20260623/READBACK_PROMOTE_ONLY_FRONTDOOR_20260623.md
categoria: operativa
tipo: readback
estado: en_revision
version: v0.6.0-rc1
fecha_evento: '2026-06-23'
autoridad:
  tipo: sistema
  referencia: CABINA_GOBIERNO_TOTAL
origen: GitHub
ubicacion_repo: operativa/tasks/20260623/READBACK_PROMOTE_ONLY_FRONTDOOR_20260623.md
etiquetas:
  - frontdoor
  - promote-only
  - archive-hold
  - local-only
relacionados:
  - README.md
  - MAPA_MAESTRO.md
  - MAPA_CAPAS.md
  - operativa/CURRENT.md
  - operativa/NEXT.md
descripcion: Cierre de promocion chica del frontdoor vivo sin absorber archive masivo.
---

# READBACK PROMOTE ONLY FRONTDOOR 20260623

## Estado

HECHO_VERIFICADO:

```text
FRONTDOOR_PROMOTE_ONLY_READY_LOCAL_ONLY
```

## Sistemas tocados

- `README.md`
- `MAPA_MAESTRO.md`
- `MAPA_CAPAS.md`
- `operativa/CURRENT.md`
- `operativa/NEXT.md`
- `operativa/tasks/20260623`

## Sistemas no tocados

- `operativa/archive`
- bajas masivas de `operativa`
- `hitos`
- `outputs`
- DB/cache
- Microsoft/SharePoint/Dataverse live
- GitHub remoto
- secretos

## Cambios

- Se promovio la puerta viva de la cabina.
- Se fijo `C:\CEO\project-cdx` como entrada canonica.
- Se mantuvo `C:\Users\enzo1\PROJEC CDX` como alias fisico.
- Se declaro que no se crea `SDU_RUNTIME_ROOT` paralelo.
- Se desacoplaron los documentos vivos del `operativa/archive` masivo.
- Se dejo `operativa/archive` en `HOLD_ARCHIVE_REVIEW`.

## Validacion

- `python -m tools.validate`: requerido con Python canonico `.venv`.
- `tools/sdu_chain_resolver.py --no-external --dry-run --json`: requerido.
- `pytest --basetemp C:\CEO\.tmp\pytest-basetemp`: requerido.
- `git diff --check`: requerido.

## Riesgos

- El repo padre mantiene dirty residual grande por archive/index/hitos.
- Sentinel puede seguir reportando `EXPECTED_INDEX_REFRESH` hasta que el carril de archive sea reconciliado.
- No se debe interpretar este cierre como limpieza total del workspace.

## Rollback

Revertir el commit de promocion chica del frontdoor. No requiere restaurar `operativa/archive`, porque el archive masivo no entra en este commit.

## Proximos carriles

```text
ARCHIVE_RECONCILIATION_PASS
```

Clasificar:

- `EXACT_ARCHIVE`
- `MODIFIED_ARCHIVE`
- `INDEX_ONLY`
- `DO_NOT_PROMOTE`

## Stop condition

No promover `operativa/archive` ni las bajas masivas hasta que el contenido archivado quede reconciliado por hash o por decision owner.
