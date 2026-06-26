# SDU Formal Contract

Fecha: 2026-06-25

## Alcance

Este contrato define las reglas institucionales del carril documental SDU para crear, reutilizar, validar y observar vinculos entre registros de Dataverse y ubicaciones documentales de SharePoint.

El contrato aplica al dominio `DOCUMENTAL` y queda preparado para expansion multi-dominio.

## Identidad unica

Un `sharepointdocumentlocation` queda definido por la siguiente clave logica:

```text
regardingobjectid + relativeurl + sharepointsiteid
```

Regla:

- No se debe crear un nuevo `DocumentLocation` si ya existe uno con la misma combinacion.
- La existencia se valida con `GET before POST`.
- La ausencia de esa validacion bloquea la creacion.

## Idempotencia

La idempotencia operativa se sostiene con `eventKey`.

Reglas:

- Un mismo `eventKey` debe reutilizar el mismo ancla y el mismo `DocumentLocation` si ya existen.
- Un segundo run no debe crear duplicados.
- Un run fallido no debe reintentar POST automaticamente.
- Toda reutilizacion debe quedar registrada como `reused=true`.

## Reglas de creacion

Toda creacion documental sigue esta cadena:

```text
evento -> policy -> validacion -> autorizacion -> GET before POST -> POST unico -> evidencia -> watchdog -> cierre
```

Reglas:

- Crear solo bajo modo controlado.
- Usar `relativeurl`, no `absoluteurl`, para `DocumentLocation`.
- Asociar contra `sharepointsite` valido.
- Asociar contra una entidad `regardingobjectid` valida.
- Ejecutar watchdog despues de la creacion.

## Politica de duplicados

El sistema distingue tres casos:

- Nuevo duplicado por runtime: no permitido.
- Residual historico pre-fix: aceptado si esta documentado.
- Cleanup: solo bajo gate formal.

Estado vigente:

- Residual: `PRE_FIX_DUPLICATE`
- Estado: `ACCEPTED`
- Accion: `NO_AUTO_DELETE`

## Politica ADX

`adx_portalcomment` queda clasificado como compatibilidad historica.

Reglas:

- Creacion ADX automatica: deshabilitada.
- Fallback ADX automatico: deshabilitado.
- Reutilizacion ADX historica: permitida para trazabilidad.
- Uso manual ADX: solo con modo forzado explicito.
- Origen primario actual: `cr3c_expediente`.

## Validacion

Cada ubicacion documental debe validarse con:

- `AbsoluteUrl` presente.
- Graph OK.
- Drive item existente.
- Carpeta accesible.
- `SiteCollectionUrl` puede estar vacio si `AbsoluteUrl` y Graph validan correctamente.

Clasificacion aceptada:

```text
SITE_COLLECTION_URL_OPTIONAL
```

## Comportamiento runtime

El runtime opera bajo estas reglas:

- Default: no ejecutar cambios externos sin gate.
- Scheduler: no habilitado automaticamente.
- Flows Power Automate: no creados por este contrato.
- Alertas externas: outbox preparado, envio real no habilitado.
- NOC: lectura y visualizacion.
- Intelligence: analitica y recomendacion, sin auto-repair.

## Contrato multi-dominio

El contrato base se extiende por dominio:

```text
DOCUMENTAL      -> documentlocation
EXPEDIENTES     -> expediente
FIRMAS          -> signature
COMUNICACIONES  -> messages
RUNTIME         -> config-only
```

Cada nuevo dominio debe declarar su contrato, fuente de estado, reglas de idempotencia, evidencia y gate de escritura antes de cualquier accion real.
