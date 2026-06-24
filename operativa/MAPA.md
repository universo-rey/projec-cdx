---
artifact_id: operativa/MAPA.md
categoria: operativa
tipo: mapa
estado: live
version: v0.6.0-rc1
fecha_evento: '2026-06-23'
autoridad:
  tipo: sistema
  referencia: CABINA_GOBIERNO_TOTAL
origen: GitHub
ubicacion_repo: operativa/MAPA.md
etiquetas:
  - operativa
  - mapa
  - frontdoor
  - clean-root
relacionados:
  - operativa/README.md
  - operativa/CURRENT.md
  - operativa/NEXT.md
  - operativa/archive/README.md
descripcion: Mapa corto de la mesa operativa despues de archivar la historia suelta.
---

# Mapa Operativo

## Frente Vivo

```text
CURRENT -> NEXT -> CONTROL -> TRACE
```

- [CURRENT.md](CURRENT.md)
- [NEXT.md](NEXT.md)
- [CONTROL.md](CONTROL.md)
- [TRACE.md](TRACE.md)

## Navegacion Corta

- [README.md](README.md)
- [README_CORTO.md](README_CORTO.md)
- [MAPA_CORTO.md](MAPA_CORTO.md)

## Archivo Gobernado

- [archive/README.md](archive/README.md)
- [archive/legacy-root](archive/legacy-root)
- [tasks/20260623/OPERATIVA_ROOT_ARCHIVE_MANIFEST_20260623.csv](tasks/20260623/OPERATIVA_ROOT_ARCHIVE_MANIFEST_20260623.csv)

## Runtime

- [runtime-events](runtime-events)
- [snapshots](snapshots)
- [SENTINEL_STATE.md](SENTINEL_STATE.md)
- [SENTINEL_EVENTS.jsonl](SENTINEL_EVENTS.jsonl)

## Regla

La raiz de `operativa` no aloja historia ni matrices sueltas. Lo historico vive en `archive/legacy-root`; lo nuevo de trabajo vive en `tasks/YYYYMMDD`.
