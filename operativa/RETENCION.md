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
