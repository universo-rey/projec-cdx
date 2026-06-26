---
artifact_id: operativa/tasks/20260623/READBACK_ROOT_SURFACE_CONVERGENCE_TASKS_20260623.md
categoria: operativa
tipo: readback
estado: en_revision
version: v0.6.0-rc1
fecha_evento: '2026-06-23'
autoridad:
  tipo: sistema
  referencia: CABINA_GOBIERNO_TOTAL
origen: GitHub
ubicacion_repo: operativa/tasks/20260623/READBACK_ROOT_SURFACE_CONVERGENCE_TASKS_20260623.md
etiquetas:
  - convergencia
  - raiz
  - surface-map
  - local-only
relacionados:
  - operativa/tasks/20260623/ROOT_SURFACE_CONVERGENCE_TASKS_20260623.csv
  - README.md
  - MAPA_MAESTRO.md
  - MAPA_CAPAS.md
  - .cabina/organizacion-total
descripcion: Readback de preparacion de tareas para converger la raiz de PROJEC CDX sin mover archivos.
---

# READBACK ROOT SURFACE CONVERGENCE TASKS

## Estado

`ROOT_SURFACE_CONVERGENCE_TASKS_READY_LOCAL_ONLY`

## Decision

La raiz debe converger antes de absorber mas paquetes.

No se crea `SDU_RUNTIME_ROOT`.
El paquete de organismo vivo se absorbe dentro de:

```text
.cabina/organizacion-total/organismo-vivo
```

## Mesa objetivo

```text
README.md                 entrada humana corta
MAPA_MAESTRO.md           navegacion viva unica
MAPA_CAPAS.md             sistema nervioso y capas
operativa/                canon vivo y decisiones finales
.cabina/organizacion-total runtime, VS Code Insiders y organismo vivo
docs/                     referencia estable
src/ tools/ tests/        motor tecnico
inventarios/              indices y catalogos
hitos/                    archivo versionado
outputs/                  generado historico
work/                     scratch y backups
```

## Tareas preparadas

Matriz:

```text
operativa/tasks/20260623/ROOT_SURFACE_CONVERGENCE_TASKS_20260623.csv
```

Cantidad:

```text
13 tareas
```

Bloques:

- `RST-00`: precheck y frontera de dirty previo.
- `RST-01`: puerta visible y mapas (`APPLIED_LOCAL_ONLY`).
- `RST-02`: canon vivo en `operativa` (`APPLIED_LOCAL_ONLY`).
- `RST-03`: runtime/cabina en `.cabina`.
- `RST-04`: absorcion del paquete organismo vivo (`APPLIED_LOCAL_ONLY`).
- `RST-05`: clasificacion de `.cabina/organizacion-total/out` (`APPLIED_LOCAL_ONLY`).
- `RST-06`: historia versionada en `hitos`.
- `RST-07`: salidas historicas en `outputs`.
- `RST-08`: scratch y backups.
- `RST-09`: motor tecnico.
- `RST-10`: identidad de rutas (`PARTIAL_LOCAL_ONLY`).
- `RST-11`: metadata/index.
- `RST-12`: cierre y validacion.

## Orden recomendado

```text
RST-00 -> RST-11 -> RST-12
```

El resto queda como compactacion posterior:

```text
RST-03, RST-06, RST-07, RST-08, RST-09
```

`RST-04` ya quedo aplicado como injerto local del paquete en:

```text
.cabina/organizacion-total/organismo-vivo
```

`RST-01` ya quedo aplicado como frontdoor vivo en:

```text
README.md
MAPA_MAESTRO.md
MAPA_CAPAS.md
```

`RST-02` ya quedo aplicado como alineacion de estado vivo en:

```text
operativa/CURRENT.md
operativa/NEXT.md
```

`RST-05` ya quedo aplicado como reubicacion local sin borrado:

```text
.cabina/organizacion-total/evidence/
.cabina/organizacion-total/archive/
.cabina/organizacion-total/backups/
```

Manifest:

```text
.cabina/organizacion-total/evidence/manifests/20260623/ROOT_RELOCATION_MANIFEST_20260623.csv
```

`RST-10` queda parcial: documentacion corta normalizada; `C:\CEO\repos`, Machine ENV y `.agents/codex` requieren owner-gate.

## Frontera

- No se movieron archivos.
- No se borro historia.
- No se creo `SDU_RUNTIME_ROOT`.
- No se tocaron DB/cache.
- No se abrio live.
- No se hizo stage.
- No se hizo commit.

## Resultado

```text
ROOT_SURFACE_CONVERGENCE_TASKS_READY_LOCAL_ONLY
```

## Proximo delta

```text
EXECUTE_RST_00_RST_01_RST_10_ROOT_FRONT_DOOR_CONVERGENCE
```
