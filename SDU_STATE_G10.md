---
artifact_id: SDU_STATE_G10.md
categoria: operativa
tipo: readback
estado: aprobado
version: g10-20260626
fecha_evento: '2026-06-26'
autoridad:
  tipo: sistema
  referencia: SDU_REPO_HYGIENE_G10
origen: GitHub
ubicacion_repo: SDU_STATE_G10.md
etiquetas:
  - sdu
  - g10
  - repo-hygiene
  - canon-boundary
relacionados:
  - SYSTEM_NERVOUS_INDEX.json
  - SDU_SYSTEM_CONTRACT.md
  - MAPA_MAESTRO.md
descripcion: Estado gobernado G10 de frontera canonica del repo y separacion de artefactos experimentales sin mutacion runtime.
---
# SDU State G10

Estado: REPO_CANONICAL_BOUNDARY_ESTABLISHED

## Canon Aprobable

Se mantiene como canon aprobable del repo:

- `SYSTEM_NERVOUS_INDEX.json`
- `contracts/schemas/system-nervous-index.schema.json`
- `SDU_SYSTEM_CONTRACT.md`
- `.agileagentcanvas-context/sdu/*`
- `MAPA_MAESTRO.md`

## Promocion G10

Archivos nuevos promovidos a tracking:

- `SDU_SYSTEM_CONTRACT.md`
- `.agileagentcanvas-context/sdu/artifacts/sdu-system.json`

Este archivo marca el limite G10 y tambien queda como estado local del corte.

## Experimental En HOLD

Se movio fuera del repo, sin borrar, hacia evidencia historica:

`C:\CEO\evidence\historical\SDU_REPO_HYGIENE_G10_20260626_021825`

Contenido preservado:

- `tools/sdu-*.ps1`
- `out/duplication-diagnostic-test/`

Manifest:

`C:\CEO\evidence\historical\SDU_REPO_HYGIENE_G10_20260626_021825\manifest.json`

## Estado Operativo

- G8-G9 quedan intactos en runtime.
- G1-G7 no se promueven como canon operativo en este corte.
- Diagnostico de duplicacion queda en `WARN` y no es resolutivo para limpieza.
- No se ejecuta limpieza en Power Platform.
- No se toca Dataverse.
- No se toca SharePoint.
- No se modifica runtime.

## Frontera

Este corte solo separa canon aprobable de artefactos experimentales.

No autoriza:

- deletes
- writes live
- scheduler
- Dataverse
- SharePoint
- Power Platform cleanup
- ejecucion automatica de G8/G9

## Validacion

- JSON canonico validado: `SYSTEM_NERVOUS_INDEX.json`, schema, Canvas `sdu-system`, project, relationships y `PATH_CANONICAL.json`.
- Runtime local no modificado y NOC owner responde `HTTP 200` en `http://localhost:8080/noc-web/owner.html`.
- Experimentales restantes en repo: `0` archivos `tools/sdu-*.ps1`.
- Diagnostico duplicacion restante en repo: `false`.
- Evidencia historica preservada: `18` scripts y `out/duplication-diagnostic-test/`.
- Validadores `.agents\codex\tools\local_validate_operational_chain.ps1` y `local_validate_skill_metadata.ps1`: no presentes en este checkout; se uso validacion local equivalente de JSON, Git status, presencia de evidencia y NOC HTTP.

## Closeout Gobernado

- agente: Codex
- orden: SDU_REPO_HYGIENE_G10
- superficie: repo local `C:\CEO\project-cdx`
- skill: no-inference-runtime-write-guard, governed-readback-closeout
- receta: separar CANON_APROBABLE vs DIAGNOSTICO_NO_CANON
- tool: PowerShell local, `git add --`, `apply_patch`
- estado: REPO_CANONICAL_BOUNDARY_ESTABLISHED
- evidencia: `C:\CEO\evidence\historical\SDU_REPO_HYGIENE_G10_20260626_021825\manifest.json`
- validador: JSON parse OK, NOC HTTP 200, Git status reducido, evidencia historica presente
- riesgo: diagnostico duplicacion sigue en WARN y no autoriza limpieza
- rollback: restaurar desde manifest historico
- stop_condition: ninguna activa para higiene local; live writes siguen bloqueados

## Rollback

Para revertir el traslado experimental, mover de vuelta desde:

`C:\CEO\evidence\historical\SDU_REPO_HYGIENE_G10_20260626_021825`

hacia las rutas originales indicadas en el manifest.
