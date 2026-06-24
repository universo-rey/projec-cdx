# Orden Agentes Microsoft Preliminar 20260616

Estado: `PREPARED_ONLY`.
Semaforo: `AMARILLO_CONTROLADO`.
Live Microsoft: `NO_EJECUTADO`.

## Mandato

Abrimos orden viva preliminar para lectura Microsoft: observar, contrastar y registrar sin ejecutar cambios.

## Mesa

| Agente | Orden | Receta | Tool |
| --- | --- | --- | --- |
| `seshat-normativa` | Rehidratar canon local y frontera `metadata_only`. | `recipes/microsoft-live-read-preliminar.md` | local files only |
| `thot-tecnico` | Preparar probes minimos por superficie. | `procesos/microsoft-live-read-preliminar.md` | SharePoint/Teams read-only solo con target |
| `anubis-gate` | Bloquear writes, secretos, permisos y targets ambiguos. | `dataverse/GATE.md` | ninguna hasta gate |
| `maat-cumplimiento` | Definir evidencia, RACI y readback si se ejecuta. | `recipes/cierre-wave-documental.md` | local files only |
| `horus-riesgo` | Marcar riesgos, rollback, postcheck y no tocar. | `recipes/microsoft-live-read-preliminar.md` | ninguna hasta target |
| `narrador-normativo` | Mantener voz viva y cierre verbal. | `cabina-continuity-readback` | local files only |

## Retorno De La Corte

- `seshat-normativa`: estado `metadata_only`, `prepared_not_executed`; en espera de cierre explicito quedan `pac auth`, `pac env fetch`, lectura live y writes sin orden.
- `thot-tecnico`: secuencia SharePoint `_get_site -> _list_site_drives -> _list_folder_items -> _fetch` puntual; Teams y Planner solo acotados.
- `anubis-gate`: en espera de cierre explicito quedan writes Microsoft, cambios de permisos, imports, activaciones, exports amplios y secretos.
- `maat-cumplimiento`: si se ejecuta, hito sugerido `hitos/20260616-microsoft-preliminar-read-v1` con README, READBACK, MANIFEST e INDICE.
- `horus-riesgo`: semaforo `AMARILLO_CONTROLADO`; no tocar `.env.local`, `auth.json`, certificados, tokens, backups `.reg`, `outputs/`, registro, red, Defender ni firewall.
- `narrador-normativo`: "Mesa alineada; ojos listos, manos quietas hasta gate explicito."

## Proximo Movimiento Unico

Elegir un target exacto antes de ejecutar live:

- SharePoint: hostname y site path exactos.
- Teams: equipo/canal/chat exacto.
- Planner: grupo/equipo y plan exacto.
- Dataverse/Power Platform: environment, org y target exactos.

Sin target exacto, la orden cierra como `PREPARED_ONLY / NO_LIVE_EXECUTION`.
