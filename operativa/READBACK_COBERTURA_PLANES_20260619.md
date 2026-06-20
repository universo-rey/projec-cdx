# READBACK_COBERTURA_PLANES_20260619

## Estado
HECHO_VERIFICADO

## Cobertura ya existente
- `2026-06-13-codex-dotcodex-surface-split.md`: split `.codex` vs `PROJEC CDX`.
- `2026-06-16-wave-atomica-repositorios.md`: repositorios y wave de repos.
- `2026-06-16-wave-atomica-documentos-conocimiento.md`: documentos y conocimiento.
- `2026-06-16-wave-atomica-documentos-pc-root-codex-mantenimiento.md`: PC local, raiz pesada de Codex y mantenimiento.
- `2026-06-19-normalizacion-cabina-local.md`: separacion de `C:\CEO`, `C:\CEO\project-cdx` y `C:\Users\enzo1\PROJEC CDX`.
- `2026-06-19-dataverse-familia-cobertura.md`: familia Dataverse con un solo camino visible.
- `2026-06-19-plan-rector-cobertura-total.md`: conecta los planes y fija la matriz de cobertura.

## Huecos Controlados
- La matriz visible sigue concentrada en `docs/superpowers/plans/README.md`; no hay que duplicarla en mas sitios.
- Dataverse ya quedo absorbido en una sola familia visible; `PLAN_SEGUNDA_PASADA.md` queda como soporte.
- Cualquier superficie nueva debe entrar con plan propio o con etiqueta `legacy` explicita.
- No deben aparecer dos planes para la misma superficie.

## Siguiente delta
- Mantener el indice de planes, `CURRENT.md` y `NEXT.md` alineados con la cobertura ya declarada.
- Reabrir solo si surge una superficie huerfana o un conflicto de duenios.

## Stop condition
- Cerrar cuando no queden entradas visibles sin plan y ninguna superficie reclame doble autoridad.
