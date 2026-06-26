---
artifact_id: operativa/README.md
categoria: operativa
tipo: indice
estado: live
version: v0.6.0-rc1
fecha_evento: '2026-06-23'
autoridad:
  tipo: sistema
  referencia: CABINA_GOBIERNO_TOTAL
origen: GitHub
ubicacion_repo: operativa/README.md
etiquetas:
  - operativa
  - indice
  - frontdoor
  - clean-root
relacionados:
  - operativa/MAPA.md
  - operativa/CURRENT.md
  - operativa/NEXT.md
  - operativa/archive/README.md
descripcion: Entrada corta de la mesa operativa; la historia queda archivada por fecha.
---

# Operativa

Mesa viva de `PROJEC CDX`.

La raiz queda limpia: solo entradas vivas, Sentinel cableado y navegacion corta.

## Entradas Vivas

- [CURRENT.md](CURRENT.md): estado actual.
- [NEXT.md](NEXT.md): siguiente movimiento.
- [CONTROL.md](CONTROL.md): control operativo.
- [TRACE.md](TRACE.md): trazabilidad viva.
- [MAPA.md](MAPA.md): mapa operativo corto.
- [README_CORTO.md](README_CORTO.md): lectura minima.
- [MAPA_CORTO.md](MAPA_CORTO.md): navegacion minima.

## Archivo

- [archive/README.md](archive/README.md): puerta del archivo operativo.
- [archive/legacy-root](archive/legacy-root): historia reubicada por fecha.
- [tasks/20260623/OPERATIVA_ROOT_ARCHIVE_MANIFEST_20260623.csv](tasks/20260623/OPERATIVA_ROOT_ARCHIVE_MANIFEST_20260623.csv): manifiesto de archivo.

## Superficies Vivas

- [runtime-events](runtime-events): eventos y actas runtime.
- [snapshots](snapshots): snapshots reproducibles.
- [sentinel](sentinel): reportes auxiliares Sentinel.
- [tasks](tasks): tareas gobernadas.
- [orders_0.2.x](orders_0.2.x), [orders_0.3.x](orders_0.3.x), [orders_0.4.x](orders_0.4.x): ordenes versionadas.

## Frontera

- No live por inferencia.
- No secretos.
- No DB/cache mutation.
- No push/PR sin gate.
- No archivos sueltos nuevos en raiz.
