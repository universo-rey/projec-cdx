# Plan Para Completar La Estructura

Plan operativo para terminar `PROJEC CDX` como workbench gobernado, accionable y retomable por hilos nuevos.

## Objetivo

Completar la cadena punta a punta:

`operativa -> playbooks -> tools -> workbook -> dataverse -> outputs -> hitos -> inventarios -> cierre`

## Aportes De Agentes

- Feynman: estructura, mapas, duplicados, fuente de verdad, manifests y retencion.
- Leibniz: workbook/control, schema canonico, ingesta desde `operativa`, alertas y manifest de corrida.
- Einstein: playbooks faltantes, validador read-only, evidencia minima y stop conditions.

## Fase 1 - Puerta De Entrada

Crear la rutina de arranque para todo hilo nuevo.

Archivos objetivo:

- `operativa/START_HERE.md`
- `operativa/PROMPT_NUEVO_HILO.md`
- `playbooks/00-preflight-gobernado.md`

Criterio de cierre:

- Un hilo nuevo sabe leer `CONTROL`, `CURRENT`, `NEXT`, `BLOCKERS`, `TRACE`, playbooks y workbook antes de actuar.

## Fase 2 - Playbooks Completos

Completar la secuencia operativa.

Archivos objetivo:

- `playbooks/04-validar-delta.md`
- `playbooks/05-promover-aprendizaje.md`
- actualizar `playbooks/README.md`
- actualizar `playbooks/MAPA.md`

Criterio de cierre:

- Hay playbook para iniciar, ejecutar, cerrar, validar y promover aprendizaje.

## Fase 3 - Validador Del Workbench

Crear un validador read-only propio del workbench.

Archivo objetivo:

- `tools/validate_proj_cdx_workbench.ps1`

Debe verificar:

- existencia de `README`, `MAPA`, `CONTROL`, `CURRENT`, `NEXT`, `BLOCKERS`, `TRACE`
- mapas principales sin enlaces rotos
- `outputs/MAPA.md` alineado con carpetas reales
- `NEXT.md` con una sola accion
- `BLOCKERS.md` sin bloqueo activo o con target, impacto, rollback, postcheck y evidencia
- no leer secretos ni abrir `auth.json`, `cap_sid`, `.env`, tokens o credenciales

Criterio de cierre:

- El validador devuelve PASS/OBSERVED/FAIL y deja evidencia local sin tocar runtime.

## Fase 4 - Workbook Como Tablero Real

Pasar de plantilla a tablero operativo.

Archivos objetivo:

- `tools/build_control_workbook.mjs`
- `workbooks/control_operativo.xlsx`
- `outputs/control_operativo_YYYYMMDD/`

Cambios requeridos:

- ingerir `operativa/CURRENT.md`, `NEXT.md`, `BLOCKERS.md`, `TRACE.md`
- agregar campos canonicos: `delta_id`, `estado`, `owner`, `fecha_inicio`, `fecha_actualizacion`, `fecha_cierre`
- agregar evidencia: `fuente`, `proceso`, `salida`, `hito`, `criterio_cierre`, `postcheck`
- agregar riesgo: `target_exacto`, `rollback`, `bloqueo`, `impacto`, `guardrail`
- agregar hoja `Alertas`
- emitir manifest de corrida

Criterio de cierre:

- El workbook refleja estado real y no solo filas manuales.

## Fase 5 - Manifests Y Retencion

Declarar fuente de verdad y estado de salidas.

Archivos objetivo:

- manifests por output principal
- `outputs/MAPA.md`
- `workbooks/MAPA.md`
- `inventarios/MAPA.md`

Reglas:

- `workbooks/` contiene fuentes vivas.
- `outputs/` contiene corridas fechadas y evidencia generada.
- `.png`, `.ndjson` y `.xlsx.inspect.ndjson` son evidencia de corrida.
- duplicados deben clasificarse como `fuente`, `generado`, `evidencia` o `historico`.

Criterio de cierre:

- Ningun output principal queda sin README, MAPA y manifest/estado.

## Fase 6 - Dataverse Gobernado

Integrar Dataverse como carril propio.

Archivos objetivo:

- `dataverse/README.md`
- `dataverse/MAPA.md`
- `dataverse/GATE.md`
- `dataverse/PLAN_SEGUNDA_PASADA.md`
- `playbooks/06-dataverse-gobernado.md`

Criterio de cierre:

- Dataverse queda separado entre evidencia local, metadata-only, preparado, live confirmado y bloqueado.

## Fase 7 - Hito Y Readback

Versionar el cierre de estructura.

Archivos objetivo:

- `hitos/YYYYMMDD-projec-cdx-estructura-v1/`
- `hitos/INDICE_MAESTRO.md`
- `hitos/INDICE_MAESTRO.csv`
- `operativa/TRACE.md`

Criterio de cierre:

- Otra sesion puede retomar desde `operativa/CONTROL.md` sin depender de conversacion previa.

## Stop Conditions

- `PENDING_TARGET`
- `PENDING_OWNER`
- `PENDING_ROLLBACK`
- `PENDING_POSTCHECK`
- `PENDING_EVIDENCE`
- `OPERATIONAL_CHAIN_MISSING`
- `SECRET_BOUNDARY`

## Orden De Ejecucion

1. Fase 1 - `closed`
2. Fase 2 - `closed`
3. Fase 3 - `closed`
4. Fase 4 - `closed`
5. Fase 5 - `closed`
6. Fase 6 - `closed_local`
7. Fase 7 - `closed`

No avanzar de fase si el criterio de cierre anterior no esta cumplido.

## Readback De Cierre

- Arranque: `operativa/START_HERE.md`, `operativa/PROMPT_NUEVO_HILO.md`.
- Playbooks: `playbooks/00-preflight-gobernado.md` a `playbooks/06-dataverse-gobernado.md`.
- Validador: `tools/validate_proj_cdx_workbench.ps1`.
- Workbook: `workbooks/control_operativo.xlsx`.
- Manifest de corrida: `outputs/control_operativo_20260615/MANIFEST.json`.
- Hito: `hitos/20260615-cierre-workbench-v1`.
