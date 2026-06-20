# Novedad Seshat - PowerShell quedo estable

Fecha: 2026-06-18
Origen: Acta Seshat de erradicacion PowerShell
Estado: resuelto

Nota: este informe cubre solo el cierre PowerShell. La novedad completa del dia quedo consolidada en `operativa/INFORME_NOVEDAD_SESHAT_CRONOLOGIA_COMPLETA_20260618.md`.

## Resumen para compartir

Hoy se resolvio un problema que estaba generando ruido cada vez que se abria o se usaba PowerShell en la cabina local.

El sintoma era un mensaje tecnico repetido sobre una ruta vacia. No afectaba datos ni servicios externos, pero ensuciaba la salida de trabajo, dificultaba leer verificaciones y podia confundir los controles diarios.

La causa fue ubicada en la cadena local de arranque de PowerShell. Se corrigieron los perfiles de inicio y se agregaron controles para que el arranque no falle si alguna variable del entorno viene vacia.

## Que se hizo

- Se reviso la cadena de arranque local de PowerShell.
- Se corrigieron los perfiles que cargan la cabina.
- Se ajusto el perfil base para manejar correctamente una variable de Windows que podia venir vacia.
- Se verifico que PowerShell 7 abra limpio.
- Se verifico que Windows PowerShell tambien abra limpio.
- Se confirmo que `az` y PAC siguen disponibles.
- Se revisaron los repos locales y no se encontraron copias versionadas del bug que requieran una correccion masiva.

## Impacto

- Menos ruido en la terminal.
- Lecturas y validaciones mas claras.
- Menor riesgo de confundir un aviso de perfil con un error real del trabajo.
- La cabina queda mas estable para seguir operando bajo demanda.

## Que no se toco

- No se hicieron escrituras en Dataverse.
- No se ejecutaron flows.
- No se hicieron imports, patches ni cambios productivos.
- No se tocaron secretos.
- No se modificaron repos sin evidencia de impacto.

## Estado final

PowerShell quedo limpio y disponible.
La correccion quedo documentada para no volver a introducir el mismo patron.

Acta tecnica de respaldo:

- `operativa/ACTA_SESHAT_ERRADICACION_POWERSHELL_20260618.md`

## Proximo paso

Publicar los commits locales pendientes de `main` si se quiere dejar el respaldo tambien en remoto.
