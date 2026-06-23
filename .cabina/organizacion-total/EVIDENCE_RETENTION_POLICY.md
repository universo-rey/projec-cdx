# Evidence Retention Policy - SDU Organizacion Total

Baseline commit: 
2ec642ff52712699bbb673b604cf43714615ccee

## Principio

La evidencia del runner se conserva por capas. El canon versiona documentos, configuracion, scripts, templates, manifiestos y readbacks saneados. La evidencia cruda queda local e ignorada por defecto.

## Saneada versionable

- Readbacks finales de decision y canonizacion.
- Reportes comparativos en Markdown sin contenido raw.
- Manifiestos con metadata/hash y sin secretos.

## Local no versionable

- Markdown/YAML generado que no fue seleccionado en el baseline.
- Propuestas no promovidas.
- Reportes exploratorios que requieren owner decision.

## Cruda no versionable

- CSV de inventario, clasificacion, revision manual, move-plan, risk-register y queues crudas.
- JSON de evidencia masiva o intermedia.
- Logs de ejecucion.

## Backup retention

- work/backups/.
- .tmp_sdu_org_total/ hasta decision de retencion/cleanup.
- *.previous-* locales.

## Reglas

- safe_to_delete=false para todo en esta fase.
- requires_gate=true para versionar, limpiar, mover o borrar.
- No registrar contenido raw en readbacks.
- Preferir metadata, hash, conteos y rutas saneadas.
- No versionar CSV/JSON crudos salvo manifiesto saneado expresamente permitido.
