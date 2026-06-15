# Playbook 07 - Dataverse Fronteras

## Objetivo

Convertir el workbook de fronteras de Dataverse en una decision operativa corta:

`frontera -> clasificacion -> evidencia -> resolucion -> cierre`

## Cuando Usarlo

- aparece una fila del workbook `dataverse_blocker_frontier.xlsx`
- hay duda entre evidencia local, metadata-only o live
- falta decidir si el bloqueo es humano, gateado, mixto o automatico

## Entradas

- `dataverse/README.md`
- `dataverse/GATE.md`
- `dataverse/REGISTRO_BLOQUEOS.md`
- `dataverse/READBACK_EXCEL_BLOCKER_FRONTIER.md`
- `outputs/dataverse_blocker_frontier_20260614/README.md`
- `outputs/dataverse_blocker_frontier_20260614/dataverse_blocker_frontier.xlsx`

## Pasos

1. Identificar la frontera exacta y su tipo.
2. Clasificarla como `human`, `gate`, `mixed`, `automatic` o `observed`.
3. Si toca live, exigir ambiente, org, target, owner, rollback, postcheck y evidencia.
4. Si solo hay metadata o evidencia local, no promocionar a live.
5. Registrar el caso en `dataverse/REGISTRO_BLOQUEOS.md`.
6. Registrar la resolucion minima en `operativa/TRACE.md`.
7. Si el bloqueo queda cerrado, versionarlo en un hito.

## Campos Minimos

- `blocker_case`
- `superficie_afectada`
- `severidad`
- `human_decision`
- `owner`
- `fecha`
- `evidence_required`
- `decision_requerida`
- `aprobador`
- `resultado`
- `resolution_action`
- `rollback`
- `postcheck`
- `state`

## Cierre

El playbook cierra cuando la frontera queda clasificada y la salida apunta a una resolucion verificable, no a una inferencia.
