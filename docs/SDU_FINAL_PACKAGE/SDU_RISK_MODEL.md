# SDU Risk Model

Fecha: 2026-06-25

## Resumen

El sistema SDU queda clasificado como estable para adopcion institucional, con riesgos conocidos y controles definidos.

Estado actual:

- Health: `YELLOW`
- Score: `70`
- Risk: `HIGH`
- Trend: `STABLE`
- Graph OK: `true`
- locationsReviewed: `15`

El riesgo alto actual se explica por densidad de alertas, no por falla estructural del vinculo documental.

## Riesgos

### Duplicados

Descripcion: existencia de un duplicado historico generado antes de la correccion de idempotencia.

Estado:

- Tipo: `PRE_FIX_DUPLICATE`
- Estado: `ACCEPTED`
- Accion: `NO_AUTO_DELETE`

Mitigacion:

- Runtime idempotente.
- ADX automatico deshabilitado.
- Cleanup solo bajo gate formal.

Impacto real:

- Bajo a medio.
- No impide operacion.
- Requiere decision de owner si se desea limpiar.

Acciones permitidas:

- Documentar.
- Monitorear.
- Abrir `CLEANUP GATE`.

Acciones prohibidas:

- Borrado automatico.
- Patch masivo.
- Limpieza sin rollback.

### Alert noise

Descripcion: alertas `HIGH` repetidas aunque el sistema documental permanece estable.

Estado:

- Recomendacion: `CHECK ALERT SOURCE (POSSIBLE NOISE)`
- `health=YELLOW`
- `graphOk=true`

Mitigacion:

- Motor de inteligencia.
- Recomendaciones sin ejecucion automatica.
- Clasificacion NOC.

Impacto real:

- Bajo sobre el carril documental.
- Medio sobre interpretacion operativa si no se separa ruido de falla real.

Acciones permitidas:

- Revisar origen.
- Ajustar clasificacion en futuras fases.
- Mantener observacion.

### Fallos Graph

Descripcion: Graph no confirma ubicacion documental.

Estado actual:

- Graph failures: `0`
- Graph OK: `true`

Mitigacion:

- Watchdog con evidencia.
- Validacion de `AbsoluteUrl`.
- Validacion de drive item.

Impacto real si ocurre:

- Alto.
- Puede impedir confirmar el vinculo documental.

Acciones permitidas:

- Revisar watchdog failures.
- Revisar permisos y disponibilidad Graph.
- Abrir incidente si health pasa a `DEGRADED`.

### Drift de configuracion

Descripcion: divergencia entre contrato, runtime y fuentes de observabilidad.

Estado actual:

- No se detecta drift operativo en el carril documental certificado.
- `locationsReviewed=15`
- `Graph OK=true`
- `noNewDuplicates` preservado por idempotencia.

Mitigacion:

- Documentacion final.
- Evidence index.
- Readbacks.
- Config multi-dominio centralizada.

## Matriz de decision

```text
YELLOW + Graph OK + loop estable -> NO ACTION
HIGH por ruido + Graph OK -> CHECK ALERT SOURCE
DEGRADED -> REVIEW WATCHDOG FAILURES
duplicate residual -> CLEANUP GATE
trend DOWN -> INVESTIGATE EVENT FLOW
```

## Riesgo residual aceptado

El residual `PRE_FIX_DUPLICATE` queda aceptado por preservacion de trazabilidad historica. No habilita borrado automatico ni limpieza implicita.
