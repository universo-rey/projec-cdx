# Acta De Canal Dataverse En Corte Ejecutora

Fecha: 2026-06-15

## Estado Del Canal

Canal Dataverse activado como carril gobernado local. No implica live write ni re-lectura innecesaria del mismo target ya cacheado.

## Evidencia Base

- Readback vivo previo: `msdyn_PowerPlatformAppAgents = 11 rows`
- Surface de agentes live presente
- Packet cacheado para el apply worker DEV: `NO_OP_LISTO_ALREADY_ACTIVE`

## Packet Reutilizable

- Ambiente: `HUBDesarrollo`
- Org: `https://org084965d9.crm.dynamics.com/`
- Profile: `SDU-HUB`
- Flow: `SDU_Process_Dataverse_Apply_Work_Items`
- Workflow id: `65468687-515f-f111-a826-00224805fc91`
- Queue: `SDU.Dataverse.Apply.Queue`
- Queue id: `513da9e9-3f5f-f111-a826-00224805fc91`

## Lectura Operativa

- Dataverse se usa aqui como superficie de agentes, bloqueos y decisiones.
- La activacion ya esta resuelta para el apply worker conocido, asi que no se repite el fetch.
- Si aparece otro target, la siguiente accion es armar un packet exacto de un solo candidato.
- La corte ejecutora registra este tramo como obra propia: discovery, reuse del packet y acta quedan asentados para continuidad.

## Componentes Resueltos

- `2dcc528e-6a76-4bf1-a262-5ba8a60d16ac` -> `ApplicationUser` -> `Microsoft Copilot Studio`
- `a00413e7-7735-f111-88b4-002248e01c0a` -> `ApplicationUserRole` -> `System Customizer`
- `9d0413e7-7735-f111-88b4-002248e01c0a` -> `ApplicationUserRole` -> `CCI admin`
- `a50413e7-7735-f111-88b4-002248e01c0a` -> `ApplicationUserRole` -> `Environment Maker`

## Lectura Corta

- El componente `10092` resuelve a `applicationusers` y queda como `Microsoft Copilot Studio`.
- El componente `10093` resuelve a `applicationuserroleset`; las tres filas apuntan a roles ya conocidos.
- El mapa ya no deja los 4 ids como frontera opaca.

## Roster SDU

- `seshat-normativa` -> `sdu.agent.seshat_normativa.runtime_actions`
- `thot-tecnico` -> `sdu.agent.thot_tecnico.runtime_actions`
- `anubis-gate` -> `sdu.agent.anubis_gate.runtime_actions`
- `maat-cumplimiento` -> `sdu.agent.maat_cumplimiento.runtime_actions`
- `horus-riesgo` -> `sdu.agent.horus_riesgo.runtime_actions`
- `narrador-normativo` -> `sdu.agent.narrador_normativo.runtime_actions`

## Diferencia Corte Ejecutora Y SDU

- La corte ejecutora es la capa que registra decision, continuidad y canon del canal.
- El roster SDU es la capa operativa de agentes postcheckeados en `HUBDesarrollo`.
- La cola de trabajo SDU es la superficie de ejecucion; no define la corte.
- `MAPA_AGENTES_SDU.md` y `MAPA_COLA_TRABAJO_SDU.md` describen operacion; esta acta describe autoridad y continuidad.
- Separacion canonica: `SDU Dataverse` nombra la superficie operativa; `corte ejecutora` nombra la capa de autoridad y continuidad. No son equivalentes.

## Cola De Trabajo

- `workqueue`
- `workqueueitem`
- `SDU.Dataverse.Apply.Queue`
- `SDU_Process_Dataverse_Apply_Work_Items`

## Conexion Y Drift

- `MAPA_CONEXIONES_DATAVERSE.md` deja al frente las superficies de conexion, gates y evidencia de semilla.
- `DATAVERSE_DRIFT_RULES.md` mantiene el criterio de bloqueo para cambios de esquema, DEV targets ambiguos y apply logs faltantes.
- Esta ronda queda completa en lo que faltaba del carril Dataverse sin convertir metadata en write live.

## Stop Conditions

- `target_identity_ambiguous`
- `wrong_environment_or_default`
- `order_packet_missing_required_fields`
- `secret_detected`

## Cierre

Este documento deja abierto el canal de Dataverse dentro de la corte ejecutora sin inventar una nueva activacion live.
