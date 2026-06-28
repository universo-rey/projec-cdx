# Retencion

Politica corta para mantener `PROJEC CDX` compacto y auditable.

## Mantener Al Frente

- `README.md`
- `MAPA_MAESTRO.md`
- `operativa/`
- `playbooks/`
- `workbooks/EXCEL_AL_FRENTE.md`
- `hitos/INDICE_MAESTRO.md`
- `hitos/20260615-hilo-origen-v1`
- `hitos/20260615-dataverse-conexiones-drift-v1`
- `hitos/20260615-corte-ejecutora-vs-sdu-v1`
- `hitos/20260616-wave-atomica-documentos-conocimiento-v1`
- `hitos/20260616-wave-atomica-documentos-pc-root-codex-mantenimiento-v1`

## Mantener Como Evidencia

- `outputs/` con README y MAPA por corrida.
- `hitos/` versionado.
- `inventarios/` con fecha, alcance y estado.
- `packages/` solo si tienen uso o referencia.
- `operativa/TRACE.md`, `operativa/CURRENT.md` y `operativa/READBACK_CIERRE_20260615.md` como trazas de cierre y segundo orden.

## Excluir Del Canon

- `node_modules/`
- caches
- temporales
- inspecciones intermedias no referenciadas

## Antes De Mover O Borrar

Requiere orden explicita y registrar:

- Ruta exacta.
- Motivo.
- Backup o rollback.
- Postcheck.
- Evidencia final.

## Reglas De Mantenimiento

- Diario: cada artefacto nuevo se clasifica como `canonical`, `mirror`, `transient` o `discardable`.
- Semanal: reindexar las superficies visibles y detectar deriva de superficie duplicada.
- Mensual: medir los roots pesados, refrescar retencion y refrescar el mapa de mantenimiento.
- Gates de movimiento: ninguna mudanza sin `source`, `target`, `rollback`, `evidence`, `postcheck` y `validator`.
