# 05 - Promover Aprendizaje

Regla para que el conocimiento operativo no quede solo en conversacion.

## Cuando Usarlo

- Un patron se repite.
- Un bloqueo tiene solucion estable.
- Un agente aporta una regla reutilizable.
- Un workbook, validador o indice revela una frontera nueva.

## Destinos

- Canon corto: `README.md`, `MAPA_MAESTRO.md` u `operativa/CONTROL.md`.
- Procedimiento: `playbooks/`.
- Evidencia: `operativa/TRACE.md`.
- Hito durable: `hitos/YYYYMMDD-nombre-vN/`.
- Dataverse: `dataverse/` solo en carril local o metadata-only.
- Herramienta: `tools/`.

## Regla

Promover solo aprendizajes estables. No promover ruido, observaciones dudosas ni datos sensibles.

## Stop Conditions

- `learning_not_stable`
- `target_canon_ambiguous`
- `sensitive_detail_detected`
- `no_evidence`

## Salida

- Aprendizaje.
- Destino.
- Evidencia.
- Proximo uso esperado.
