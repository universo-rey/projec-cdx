# SDU Technical Architecture

Fecha: 2026-06-25

## Vista general

SDU integra Dataverse, SharePoint, Microsoft Graph, runtime local, watchdog, NOC e inteligencia operativa para sostener el carril documental institucional.

La arquitectura separa datos, control, observabilidad y decision. Ninguna capa de visualizacion o inteligencia ejecuta cambios automaticos.

## Capas

### Dataverse

Contiene las entidades de negocio y las entidades de document management:

- `sharepointsite`
- `sharepointdocumentlocation`
- `cr3c_expediente`
- `adx_portalcomment` como legado

### SharePoint

Contiene la biblioteca documental real asociada al sitio institucional.

La biblioteca validada es usada mediante ruta relativa controlada y verificada por Graph.

### Microsoft Graph

Valida que la ubicacion documental exista y sea accesible.

Senales usadas:

- Drive encontrado.
- Drive item existe.
- Carpeta accesible.
- Graph failures = `0`.

### Runtime

Ejecuta operaciones controladas e idempotentes. El loop actual prioriza `cr3c_expediente` y no crea ADX automaticamente.

### Watchdog

Revisa la salud del vinculo documental y genera evidencia JSON.

Fuente principal actual:

```text
C:\CEO\watchdog\evidence\sharepoint_link_watchdog_20260625_183012.json
```

### NOC

Presenta estado operativo en:

- CLI/screen: `C:\CEO\watchdog\noc-screen.ps1`
- alias local: `C:\CEO\watchdog\noclive.ps1`
- web local: `C:\CEO\watchdog\noc-web\index.html`

### Intelligence

Calcula score, riesgo, tendencia, anomalias y outbox:

- `C:\CEO\watchdog\state\predictive_score.json`
- `C:\CEO\watchdog\logs\anomalies.jsonl`
- `C:\CEO\watchdog\outbox\alerts_out.jsonl`
- `C:\CEO\watchdog\outbox\recommended_actions.json`

## Flujo completo

```text
evento
  -> expediente
  -> validacion de entidad
  -> GET DocumentLocation existente
  -> crear o reutilizar DocumentLocation
  -> validar Graph
  -> watchdog
  -> evidencia JSON
  -> NOC
  -> intelligence
  -> recomendacion operativa
```

## Diagrama textual

```text
[Dataverse: cr3c_expediente]
          |
          v
[Dataverse: sharepointdocumentlocation]
          |
          v
[SharePoint: biblioteca documental]
          |
          v
[Graph: validacion de carpeta]
          |
          v
[Watchdog: health + evidence]
          |
          v
[NOC: pantalla + web]
          |
          v
[Intelligence: score + recommendations]
```

## Fuente de verdad operativa

Orden de prioridad:

1. Ultima evidencia watchdog: `sharepoint_link_watchdog_*.json`
2. Evidencia G8: `g8_*.json`
3. Estado local: `g6_loop_last.json`
4. Score consolidado: `predictive_score.json`

## Modelo multi-carril

Archivo:

```text
C:\CEO\watchdog\config\systems.json
```

Carriles:

- `DOCUMENTAL`
- `EXPEDIENTES`
- `FIRMAS`
- `COMUNICACIONES`
- `RUNTIME`

El carril `DOCUMENTAL` ya tiene fuente de estado activa. Los demas carriles quedan definidos como base de expansion y deben incorporar fuente de estado y gate antes de ejecutar acciones reales.
