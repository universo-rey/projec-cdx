# Despierta Traza del Flujo

## Cadena actual
- Fuente: lectura live de Dataverse ya confirmada.
- Proceso: compactar a set minimo de evidencia y workbook.
- Salida: readback corto + JSON vivo + workbook vigente.
- Hito: snapshot liviano 2026-06-17.
- Cierre: `delta_select_next_consumer_from_dataverse_live_rows`

## Regla
- La traza completa queda del lado de la rama pesada.
- Esta rama solo conserva el carril activo minimo.
