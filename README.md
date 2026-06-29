# SDU Runtime

SDU es el sistema gobernado de operacion, observabilidad y trazabilidad de
`project-cdx`. Su funcion es mantener alineados el estado real del watchdog, la
proyeccion ejecutiva del NOC, la politica de riesgo, el bus de eventos y la
bitacora de decisiones.

El estado institucional vigente es `LIVE`: `execution_mode=LIVE`,
`runtime_mode=OPERATIONAL` y `noc_mode=REALTIME`. La ejecucion automatica esta
habilitada en modo gobernado para acciones locales, controladas y no
destructivas.

## Runtime Authority Split

- Local desktop is the authoritative CEO governed write/execute surface.
- Codex Cloud is connected read-observe only.
- GitHub Actions may execute CI; manual promotion workflows are owner-gated and
  separate from Codex Cloud.
- Windows absolute paths in this README are local evidence paths and must not be
  treated as Codex Cloud executable dependencies.
- The current source tree root is `C:/Users/enzo1/Documents/GitHub`.
  `C:/CEO/repos` is retired/not declared because it does not currently exist.

## Arquitectura

El sistema se organiza en cinco superficies principales:

- Watchdog: observa el estado real del sistema, emite alertas y publica eventos.
- Bus: transporta eventos SDU para monitoreo, delta y trazabilidad.
- Policy: clasifica riesgo y decide el comportamiento permitido.
- NOC: muestra la proyeccion operativa en tiempo real.
- Governance: registra decisiones, evidencia, aprobaciones y cierres.

## Componentes

- `C:\CEO\watchdog\state\sdu-system-state.json`: estado real autoritativo del watchdog.
- `C:\CEO\watchdog\bus\sdu-event-bus.jsonl`: bus de eventos SDU.
- `C:\CEO\watchdog\alerts\*.json`: alertas emitidas por watchdog.
- `C:\CEO\project-cdx\noc\noc-state.json`: estado NOC alineado.
- `C:\CEO\project-cdx\noc\operacion-en-vivo.json`: panel operativo en vivo.
- `C:\CEO\project-cdx\.sdu\risk-policy.json`: politica de riesgo vigente.
- `C:\CEO\governance\reports\sdu-decision-log.json`: bitacora de decisiones.
- `schema.json` e `index.json`: modelo de metadata e indice operativo del repo.

## Ejecucion Local

La ejecucion local no requiere bootstrap desde este carril. El operador trabaja
sobre el runtime ya instalado y validado.

Comandos de verificacion habituales:

```powershell
python -m tools.validate
python -m tools.build_index
pytest
```

Validadores operativos SDU:

```powershell
C:\CEO\project-cdx\.agents\codex\tools\local_validate_order_packets.ps1
C:\CEO\project-cdx\.agents\codex\tools\local_validate_operational_chain.ps1
```

## Panel NOC

El panel NOC se consulta en:

```text
http://localhost:8081
```

El panel lee `C:\CEO\project-cdx\noc\operacion-en-vivo.json` y refresca cada 3
segundos. No duplica estado ni reconstruye datos: muestra la proyeccion actual
del NOC desde la fuente viva.

## Flujo Operativo

1. Watchdog observa estado, alertas y eventos.
2. El bus publica los eventos SDU.
3. Policy clasifica riesgo y determina decision.
4. NOC refleja estado, riesgo, foco y monitoreo agregado.
5. Governance registra decisiones, evidencia y trazabilidad.
6. Las acciones automaticas solo se ejecutan cuando existe delta nuevo con
   clasificacion critica y decision `ESCALATE`.
7. Cualquier accion externa, destructiva o de alto impacto requiere aprobacion
   humana.

## Estado LIVE

El modo `LIVE` significa que el runtime operativo esta activo y observado en
tiempo real. No significa autorizacion abierta para cambios externos.

Permitido en automatico:

- append de bitacora.
- registro de incidente.
- marcado de foco critico en NOC.
- generacion de tarea interna SDU.
- activacion de flags de seguimiento.

Bloqueado sin aprobacion humana:

- cambios en repos.
- acciones en SharePoint.
- acciones en Dataverse.
- escrituras Microsoft, OpenAI o cloud.
- modificaciones destructivas.

## Trazabilidad

Toda decision operativa debe quedar asociada a evidencia local verificable:

- estado watchdog.
- snapshot NOC.
- decision policy.
- bitacora governance.
- postcheck.
- rollback cuando aplique.
