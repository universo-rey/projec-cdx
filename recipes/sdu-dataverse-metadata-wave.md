# Receta SDU Dataverse Metadata Wave

## Uso

Usar cuando una wave necesita convertir evidencia observada de Dataverse, Power Platform, SGIN, SharePoint, Planner o colas SDU en metadata reusable sin ejecutar writes.

## Secuencia

1. Rehidratar tenant, ambiente, readbacks e inventarios vivos.
2. Fijar frontera `tenant_scoped` y modo `metadata_only`.
3. Despachar agentes con carriles disjuntos: canon, tecnico, gate, cumplimiento, riesgo e identidad.
4. Generar matriz `METADATA_HYDRATION_MATRIX.csv`.
5. Eliminar redundancia semantica y nombres sensibles.
6. Validar con `tools/validate_sdu_dataverse_metadata_wave.ps1`.
7. Cerrar con readback, rollback, postcheck y siguiente delta unico.

## No Hacer

- No abrir documentos.
- No reproducir mensajes, previews, payloads ni titulos Planner.
- No ejecutar flows.
- No escribir Dataverse si el target no tiene candidate count exacto.

## Salida

Un hito versionado `hitos/YYYYMMDD-sdu-dataverse-metadata-wave-vN` con manifest, evidencia, matriz metadata-only y validador.
