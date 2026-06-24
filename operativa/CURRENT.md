---
artifact_id: operativa/CURRENT.md
categoria: operativa
tipo: reporte
estado: en_revision
version: v0.6.0-rc1
fecha_evento: '2026-06-23'
autoridad:
  tipo: sistema
  referencia: CABINA_GOBIERNO_TOTAL
origen: GitHub
ubicacion_repo: operativa/CURRENT.md
etiquetas:
  - current
  - frontdoor
  - convergencia
  - local-only
relacionados:
  - README.md
  - MAPA_MAESTRO.md
  - MAPA_CAPAS.md
  - operativa/NEXT.md
  - operativa/tasks/20260623/ROOT_SURFACE_CONVERGENCE_TASKS_20260623.csv
descripcion: Estado vivo actual de PROJEC CDX tras convergencia local del frontdoor.
---

# Current

Estado vivo resumido de `PROJEC CDX`.

## Estado Actual

```text
CABINA_FRONTDOOR_CONVERGED_LOCAL_ONLY
ORGANISMO_VIVO_LANGUAGE_AND_POLICY_INJERTADO_EN_CABINA
ROOT_SURFACE_CONVERGENCE_TASKS_READY_LOCAL_ONLY
```

## Version

```text
v0.6.0-rc1
```

## Entrada Canonica

```text
C:\CEO\project-cdx
```

Alias fisico:

```text
C:\Users\enzo1\PROJEC CDX
```

Regla:

```text
No tratar el alias fisico como segundo workspace activo.
No crear SDU_RUNTIME_ROOT paralelo.
Usar siempre C:\CEO\project-cdx\.cabina\SDU_RUNTIME_ROOT.
```

## Puertas Vivas

- [README.md](../README.md)
- [MAPA_MAESTRO.md](../MAPA_MAESTRO.md)
- [MAPA_CAPAS.md](../MAPA_CAPAS.md)

## Canon Vivo

- [NEXT.md](NEXT.md)
- [TRACE.md](TRACE.md)
- [ROOT_SURFACE_CONVERGENCE_TASKS_20260623.csv](tasks/20260623/ROOT_SURFACE_CONVERGENCE_TASKS_20260623.csv)
- [READBACK_ROOT_FRONTDOOR_CONVERGENCE_20260623.md](tasks/20260623/READBACK_ROOT_FRONTDOOR_CONVERGENCE_20260623.md)
- [READBACK_ORGANISMO_VIVO_PACKAGE_ASSIMILATION_20260623.md](tasks/20260623/READBACK_ORGANISMO_VIVO_PACKAGE_ASSIMILATION_20260623.md)

## Runtime / Cabina

- [.cabina/SDU_RUNTIME_ROOT/00_START_HERE/SYSTEM_FRONTDOOR.md](../.cabina/SDU_RUNTIME_ROOT/00_START_HERE/SYSTEM_FRONTDOOR.md)
- [.cabina/SDU_RUNTIME_ROOT/00_START_HERE/README_ORGANISMO_VIVO.md](../.cabina/SDU_RUNTIME_ROOT/00_START_HERE/README_ORGANISMO_VIVO.md)
- [.cabina/SDU_RUNTIME_ROOT/03_PROVIDERS/VSCODE_INSIDERS/README.md](../.cabina/SDU_RUNTIME_ROOT/03_PROVIDERS/VSCODE_INSIDERS/README.md)

## Pendientes Vivos

```text
RST-05: documentar .cabina/organizacion-total como ruta historica
RST-10: federation/SNS extendidos a 16 repos con runtime pointer canonico
RST-11: refrescar indices/SNS si se decide versionar la convergencia
RST-12: cerrar readback final de convergencia
```

## Historico Reubicado

El estado historico `WORKBOOK_SURFACES_WORKSPACE_REFRESHED` queda preservado como antecedente.

Fuente maestra historica:

```text
HOLD_ARCHIVE_REVIEW
```

La cronologia historica queda fuera de esta promocion chica hasta reconciliar el archivo masivo.

## Frontera

- No live por inferencia.
- No secretos.
- No DB/cache mutation.
- No push.
- No PR.
- No stage/commit sin decision.
