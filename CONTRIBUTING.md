# Contributing

Este repositorio opera bajo gobierno SDU. Todo cambio debe preservar
trazabilidad, validacion y coherencia entre repo, runtime, NOC, policy y
watchdog.

## Modelo De Ramas

- `codex/*`: trabajo asistido local, preparacion de deltas y cambios gobernados.
- `control-plane/*`: cambios del plano de control, governance o superficies de
  operacion.
- `freeze/*`: estabilizacion, contencion o cierre temporal de una superficie.
- `main`: estado promovido, revisado y listo como referencia institucional.

## Ciclo G2 A G6

La promocion de cambios sigue un ciclo controlado:

1. G2: preparar delta con alcance exacto.
2. G3: validar metadata, rutas y evidencia.
3. G4: ejecutar quality checks y pruebas.
4. G5: revisar seguridad, policy y riesgos.
5. G6: promover solo con evidencia, rollback y postcheck.

Checks minimos antes de promocion:

- `meta-validate`.
- `quality`.
- `codeql`.
- validadores SDU cuando el cambio toque operacion, runtime, governance o NOC.

## Reglas De Promocion

- El cambio debe tener objetivo claro, alcance acotado y destino exacto.
- No se aceptan cambios inferidos por cercania, historial o nombre parecido.
- La evidencia debe estar disponible antes de cerrar el gate.
- El rollback debe ser claro cuando exista mutacion persistente.
- El postcheck debe comprobar que no hay drift entre repo y runtime.
- Los indices de metadata deben quedar consistentes con `schema.json`.

## No Live Execution Fuera De Promocion

El estado institucional del sistema es `LIVE`, pero las ramas no promovidas no
autorizan ejecucion live por si mismas.

En ramas no promovidas queda prohibido:

- activar acciones externas.
- modificar SharePoint, Dataverse, Microsoft, OpenAI o cloud.
- aplicar cambios destructivos.
- ejecutar acciones sin aprobacion humana cuando afecten sistemas externos.
- simular evidencia live.

Las pruebas locales, validaciones, analisis y cambios documentales estan
permitidos si respetan el alcance del gate.

## Codex Cloud Boundary

Codex Cloud remains `read-observe` only. It may inspect, summarize, compare and
report, but must not write files, install dependencies, run migrations, create
branches, stage, commit, push, open pull requests, deploy, or mutate external
services.

GitHub Actions are a separate execution surface. CI workflows may run checks.
The promotion workflow may mutate only through manual workflow dispatch with
owner gate, rollback and postcheck.

The current local source tree root is `C:/Users/enzo1/Documents/GitHub`.
`C:/CEO/repos` is retired/not declared because it does not currently exist.
Codex Cloud must use repo-relative paths only and treat all Windows absolute
paths as local evidence references.

## Evidencia Obligatoria

Cada cambio gobernado debe indicar:

- archivos tocados.
- razon del cambio.
- fuente de autoridad.
- validadores ejecutados.
- resultado del postcheck.
- riesgos residuales.
- rollback o razon de no aplicacion.

Para cambios SDU, la evidencia debe referenciar las fuentes canonicas que
correspondan:

- `C:\CEO\watchdog\state\sdu-system-state.json`.
- `C:\CEO\project-cdx\noc\noc-state.json`.
- `C:\CEO\project-cdx\noc\operacion-en-vivo.json`.
- `C:\CEO\project-cdx\.sdu\risk-policy.json`.
- `C:\CEO\governance\reports\sdu-decision-log.json`.

## Seguridad

- No imprimir secretos.
- No persistir tokens.
- No ampliar permisos sin gate explicito.
- No ejecutar writes externos desde workflows o agentes sin aprobacion.
- No cerrar como aprobado si falta evidencia, rollback o postcheck.

## Cierre

Un cambio solo se considera listo cuando los validadores pasan, el estado queda
coherente y la salida documenta el resultado formal del gate.
