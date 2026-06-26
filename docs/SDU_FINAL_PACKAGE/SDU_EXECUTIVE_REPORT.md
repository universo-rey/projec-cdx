# SDU Executive Report

Fecha: 2026-06-25

## Resumen ejecutivo

El sistema SDU quedo consolidado como una plataforma institucional para controlar el vinculo documental entre Dataverse y SharePoint. Su objetivo es que cada expediente pueda tener una ubicacion documental trazable, validada y observable, sin depender de acciones manuales opacas ni de automatizaciones sin control.

El estado final del carril documental es **PRODUCTION READY bajo operacion gobernada**, con un residual historico aceptado y sin ejecucion automatica de acciones correctivas.

## Problema original

El sistema no tenia un carril documental operativo completo. Dataverse no contaba con anclas suficientes para crear y validar `DocumentLocation`, el vinculo con SharePoint no podia ser auditado de punta a punta, y no habia una pantalla unica para distinguir entre falla real, advertencia operativa y ruido de alertas.

El riesgo institucional era doble:

- Documentos y registros podian quedar desconectados.
- Las alertas podian generar intervenciones innecesarias o decisiones sin evidencia.

## Solucion implementada

Se construyo y estabilizo un carril documental completo:

1. Se creo el ancla `SharePointSite`.
2. Se valido el primer `DocumentLocation` tecnico.
3. Se incorporo una entidad real de dominio: `cr3c_expediente`.
4. Se migro el uso operativo desde `adx_portalcomment` hacia expediente.
5. Se depreco ADX como creacion nueva, preservando compatibilidad historica.
6. Se implemento watchdog con validacion Graph.
7. Se agrego NOC local en modo pantalla y web.
8. Se agrego motor de inteligencia y recomendaciones.
9. Se definio un modelo multi-dominio para expansion.

## Capacidades actuales

- Validacion de vinculos documentales Dataverse -> SharePoint.
- Deteccion de salud con watchdog.
- NOC local CLI/screen/web.
- Score predictivo institucional.
- Recomendaciones operativas sin ejecucion automatica.
- Control de duplicados mediante gate separado.
- Modelo multi-carril para `DOCUMENTAL`, `EXPEDIENTES`, `FIRMAS`, `COMUNICACIONES` y `RUNTIME`.

## Metricas reales

Fuente principal: `C:\CEO\watchdog\state\predictive_score.json`

- Score: `70`
- Health: `YELLOW`
- Risk: `HIGH`
- Trend: `STABLE`
- locationsReviewed: `15`
- Graph OK: `true`
- Graph failures: `0`
- Estado de recomendacion: `STABLE_WITH_ALERT_NOISE_AND_KNOWN_RESIDUAL`

Interpretacion ejecutiva: el riesgo alto no indica caida del sistema documental. Proviene de densidad de alertas y ruido conocido. El carril documental permanece estable, con Graph OK y watchdog revisando 15 ubicaciones.

## Beneficios institucionales

- Trazabilidad: cada accion queda vinculada a evidencia local.
- Control: no hay ejecucion automatica sin gate formal.
- Auditoria: el sistema genera logs, evidence JSON y readbacks.
- Continuidad: el carril documental puede operar sin depender de decisiones informales.
- Escalabilidad: el contrato base permite nuevos dominios sin duplicar logica.

## Estado final

Estado: **PRODUCTION READY**

Condicion: produccion gobernada, con residual historico aceptado.

Residual conocido:

- Tipo: `PRE_FIX_DUPLICATE`
- Estado: `ACCEPTED`
- Accion: `NO_AUTO_DELETE`
- Motivo: preservacion de trazabilidad historica.

## Recomendacion ejecutiva

Adoptar SDU como control institucional del carril documental. La proxima expansion debe enfocarse en incorporar nuevos dominios bajo el contrato existente, no en reescribir el runtime.

No se recomienda ejecutar limpieza automatica. La limpieza del residual historico, si se decide hacerla, debe pasar por un `CLEANUP GATE` formal con owner, rollback, evidencia previa y post-verificacion.
