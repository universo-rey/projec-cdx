---
artifact_id: operativa/W1_W2_LOCAL_OVERLAY_POLICY_20260622.md
categoria: operativa
tipo: reporte
estado: en_revision
version: 2026.06.22
autoridad:
  tipo: owner
  referencia: '@SeshatSgin'
origen: Mixto
ubicacion_repo: operativa/W1_W2_LOCAL_OVERLAY_POLICY_20260622.md
etiquetas:
- cabina
- overlays
- w1-w2
relacionados:
- operativa/W1_W2_CARRIL_NOISE_REDUCTION_MATRIX_20260622.csv
- operativa/W1_W2_CODEX_MEMORY_BOUNDARY_MATRIX_20260622.csv
descripcion: Politica local para overlays y ruido sin borrado ni mutacion.
fecha_evento: '2026-06-22'
---

# W1/W2 LOCAL OVERLAY POLICY

## Politica

Los overlays locales no son basura por defecto. Se clasifican antes de tocarse.

## No tocar sin gate

- .codex DB/cache/workspaceStorage.
- .env.local.
- .vscode settings.
- .agents globales.
- plugin cache.
- node_modules.

## Accion actual

No se borra ni mueve nada. Se registra frontera y carril para wave posterior si el owner la autoriza.
