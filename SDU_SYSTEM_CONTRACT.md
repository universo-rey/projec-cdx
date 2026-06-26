---
artifact_id: SDU_SYSTEM_CONTRACT.md
categoria: procesos
tipo: plan
estado: aprobado
version: v0.6.0-rc1
fecha_evento: '2026-06-26'
autoridad:
  tipo: sistema
  referencia: SYSTEM_NERVOUS_INDEX
origen: GitHub
ubicacion_repo: SDU_SYSTEM_CONTRACT.md
etiquetas:
  - sdu
  - system-contract
  - sns
  - event-bus
  - agent-routing
relacionados:
  - SYSTEM_NERVOUS_INDEX.json
  - CEO_CONTROL_PLANE.code-workspace
  - .agileagentcanvas-context/sdu/artifacts/sdu-system.json
descripcion: Contrato canonico SDU declarado desde SNS, Event Bus y ruteo multiagente.
---

# SDU System Contract

Estado: CANONICAL

Este sistema esta definido operacionalmente en:
`SYSTEM_NERVOUS_INDEX.json`

SYSTEM_TYPE = "EVENT_DRIVEN_MULTI_AGENT_RUNTIME"

## 1. Control Plane

El control plane operativo vive en `CEO_CONTROL_PLANE.code-workspace` y usa
`SYSTEM_NERVOUS_INDEX.json` como fuente obligatoria para reconocer superficie,
Canvas, rutas y runner de gobernanza.

## 2. Event Bus

El sistema opera por eventos declarados en `routes`. Cada evento tiene una
cadena `chainId` y una lista ordenada de agentes responsables.

## 3. Agent Model

El modelo de agentes esta declarado en `agents`. Cada agente define owner,
superficie, herramienta, evidencia, validador, condicion de stop y estado.

## 4. Routing Chains

Las cadenas de ruteo se declaran en `routes` y conectan eventos como
`RUNTIME_DRIFT`, `ALERT_RAISED`, `POLICY_DECISION`, `FEDERATION_DRIFT` y
`CONTROL_PLANE_SYNC` con agentes concretos.

## 5. Fail-Closed Policy

La politica canonica esta en `policy`. El contrato exige `failClosed=true`,
`liveWrite=false`, `secretAccess=false` y `requiredForExecution=true`.

## 6. Execution Boundaries

Las fronteras de ejecucion son locales por defecto. No hay escritura live,
acceso a secretos ni mutacion externa sin gate explicito del owner.

## 7. Authority Model

La autoridad primaria del sistema es el SNS: `SYSTEM_NERVOUS_INDEX.json`.
`C:\CEO\project-cdx` es la raiz canonica local y
`C:\Users\enzo1\PROJEC CDX` es el alias fisico declarado. Agile Agent Canvas
consume el SNS como contrato, no como log ni salida generada.
