# ORDER 0.3.0 — GitHub labels Dependabot PROJEC CDX

## Estado de entrada
SDU_0.2.x_EXTENDED_PACKET_BASELINE_CLOSED_LOCAL

## Source gate
0.2.3 / GATE_0.2.3_GITHUB_LABELS_DEPENDABOT_PROJEC_CDX

## Superficie
GitHub / universo-rey/projec-cdx

## Tipo de ejecucion
github_label_write

## Objetivo
Crear o alinear labels requeridos por Dependabot para evitar fallos de etiquetado automatico.

## Labels propuestos
- dependencies
- python
- github-actions

## Requisitos previos
- owner autorizado
- GitHub write gate activo
- rollback definido
- postcheck definido
- no token impreso
- no push
- no PR

## Rollback
Si se crean labels incorrectos:
- borrar label creada si no existia previamente;
- restaurar descripcion/color si existia previamente.

## Postcheck
- verificar existencia de labels;
- verificar color/description;
- verificar que Dependabot no reporte labels faltantes en nuevos eventos.

## Prohibido
- no merge
- no PR
- no cambios de codigo
- no modificacion de dependabot.yml salvo orden separada

## Resultado esperado
GATE_0.3.0_READY_FOR_OWNER_AUTHORIZATION
