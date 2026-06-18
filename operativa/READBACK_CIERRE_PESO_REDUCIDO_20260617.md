# READBACK_CIERRE_PESO_REDUCIDO_20260617

## Agente
Codex

## Orden
Reducir el peso visible del trabajo dejando un solo backup vigente del workbook y consolidando la evidencia repetida en una salida corta reutilizable.

## Superficie
`workbooks/_backups/` y `operativa/`

## Skill
`delta-gobernado` + `governed-readback-closeout`

## Receta
Recorte seguro de backups reconstruibles, con cierre corto y sin tocar el workbook vigente ni las superficies live.

## Tool
`Remove-Item` + `Get-ChildItem`

## Estado
HECHO_VERIFICADO

## Evidencia
- Quedó un solo backup en `workbooks/_backups/`.
- Se conservaron `workbooks/CODEX_GLOBAL_STATE_DECISION_WORKBOOK_20260617.xlsx` y el backup `CODEX_GLOBAL_STATE_DECISION_WORKBOOK_20260617_before_update_20260617_231403.xlsx`.
- La cronologia consolidada ya vive en `operativa/CRONOLOGIA_MAESTRA_20260617.md`.

## Validador
- `Get-ChildItem 'C:\\Users\\enzo1\\PROJEC CDX\\workbooks\\_backups' -File`
- `git status --short --branch`

## Riesgo
Bajo. Se redujo el stock de rollback rapido, pero quedo un backup vigente y el workbook actual sigue intacto.

## Rollback
Si hiciera falta recuperar backups intermedios, se pueden restaurar desde Git history.

## Stop Condition
No seguir borrando historial reconstruible si en el futuro se necesita auditar una iteracion intermedia del workbook.

## Proximos carriles
Mantener vivo el delta actual `delta_select_next_consumer_from_dataverse_live_rows`.
Si se sigue compactando contexto, la siguiente referencia corta debe partir de `operativa/CRONOLOGIA_MAESTRA_20260617.md`.
