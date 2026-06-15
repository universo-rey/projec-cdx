# Readback

Semaforo: `GREEN_OPERABLE`

Resumen corto:
- La superficie mas pesada vive en `cache`, `worktrees` y `.tmp`.
- El frente util para gobierno y continuidad vive en `workpapers`, `matrices`, `skills`, `hitos` y `catalogo-local`.
- `plugins` y `vendor_imports` sostienen capacidad, pero no deberian dominar el frente visible.
- `secrets`, `private`, `.sandbox*`, `sqlite`, `auth.json` y `cap_sid` quedan fuera del carril de compactacion.

Siguiente movimiento:
- Propagar este informe a `outputs/README.md` y `outputs/MAPA.md`.
