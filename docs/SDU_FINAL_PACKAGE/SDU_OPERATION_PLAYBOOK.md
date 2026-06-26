# SDU Operation Playbook

Fecha: 2026-06-25

## Objetivo

Este playbook define como operar el sistema SDU desde el NOC local, como interpretar alertas y que acciones estan permitidas.

## Herramientas

### NOC screen

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\CEO\watchdog\noc-screen.ps1"
```

Si el alias esta cargado:

```powershell
noclive
```

### NOC web

```text
http://localhost:8080/noc-web/
```

### Score predictivo

```text
C:\CEO\watchdog\state\predictive_score.json
```

### Recomendaciones

```text
C:\CEO\watchdog\outbox\recommended_actions.json
```

## Interpretacion de estados

### HEALTHY

El sistema no presenta fallas estructurales. No requiere intervencion.

### YELLOW

Estado operativo con advertencias no bloqueantes. En el estado actual, `YELLOW` significa que Graph valida las ubicaciones, pero existen advertencias informativas o ruido de alertas.

### HIGH

`HIGH` es severidad de riesgo o alerta, no necesariamente caida del sistema. En el estado actual, `risk=HIGH` proviene de densidad de alertas, mientras `health=YELLOW` y `Graph OK=true`.

### INCIDENT

Clasificacion inteligente para alertas repetidas o concentradas. Debe revisarse la fuente de la alerta antes de intervenir el runtime.

## Reglas de accion

### NO ACTION

Usar cuando:

- `health=YELLOW`
- `graphOk=true`
- loop estable
- riesgo alto explicado por densidad de alertas

Accion: observar, no intervenir.

### CHECK ALERTS

Usar cuando:

- hay `HIGH` repetidos
- el sistema sigue estable
- las alertas vienen de `LOG_ONLY` o checks informativos

Accion: revisar origen de alertas y clasificar ruido.

### CLEANUP GATE

Usar cuando:

- se detecta duplicado residual
- se decide tratarlo institucionalmente

Accion: abrir gate formal. No borrar automaticamente.

Requisitos minimos:

- Owner.
- Motivo.
- Registro afectado.
- Rollback.
- Evidencia previa.
- Postcheck watchdog.

## Roles

### Operator

Monitorea NOC, revisa recomendaciones y escala cuando corresponde.

### Analyst

Interpreta alertas, separa ruido de falla real y documenta hallazgos.

### Admin

Ejecuta cambios locales o controlados solo bajo gate autorizado.

### Owner

Autoriza acciones con impacto en datos, limpieza, scheduler o integraciones externas.

## Protocolo de incidente

1. Leer `recommended_actions.json`.
2. Confirmar `predictive_score.json`.
3. Revisar ultima evidencia watchdog.
4. Determinar si hay falla real o ruido.
5. Si hay falla real, abrir incidente.
6. Si requiere cambio, abrir gate.
7. Ejecutar solo con autorizacion formal.
8. Cerrar con evidencia y readback.

## Prohibiciones operativas

- No ejecutar cleanup automatico.
- No activar scheduler sin gate.
- No crear flows sin gate.
- No enviar alertas externas sin gate.
- No tocar Dataverse o SharePoint por inferencia.
