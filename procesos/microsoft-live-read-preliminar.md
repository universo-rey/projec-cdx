# Proceso Microsoft Live Read Preliminar

Estado: `ACTIVE_GOVERNED_READ`.

## Entrada

- Pedido explicito de pasada Microsoft preliminar.
- Evidencia local disponible.
- Capability autenticada, binding vigente y contrato `NO_WRITE`.
- Target exacto y alcance minimizado; una lista candidata sólo habilita preparación local, no live.

## Algoritmo

1. Rehidratar contexto local desde `dataverse/GATE.md`, `procesos/dataverse-gobernado.md`, `recipes/dataverse-rehidratacion.md` y evidencia de inventarios.
2. Si falta target exacto, no abrir conector live.
3. Si el target es SharePoint, iniciar por sitio exacto: `_get_site`, luego `_list_site_drives`, luego `_list_folder_items`.
4. Si el target es Teams, iniciar por `_list_teams`, luego `_list_channels`, luego mensajes acotados si el canal queda confirmado.
5. Si el target es Planner, iniciar por grupo/equipo confirmado, luego plan y tareas.
6. Si el target es Dataverse o Power Platform, ejecutar lectura metadata acotada cuando existan environment, org, target, owner, binding, rollback `N/A_READ_ONLY`, postcheck y evidencia esperada.
7. Clasificar cada hallazgo como `confirmado`, `probable` o `inferido`.
8. Registrar readback local y no declarar cierre total.

## Validadores

- No hubo tool de write.
- No se imprimio ni copio secreto.
- No se hizo export amplio.
- No se cambio permiso, lista, archivo, mensaje, tarea, app, flow, solution ni environment.
- El target quedo nombrado o la wave cerro como `NO_CONCLUYENTE`.

## Retorno Por Agente

| Agente | Retorno |
| --- | --- |
| `seshat-normativa` | Canon local, frontera y targets candidatos. |
| `thot-tecnico` | Orden tecnico de probes y limites. |
| `anubis-gate` | Permitidos, items en espera de cierre y condiciones de pausa. |
| `maat-cumplimiento` | Formato de evidencia, RACI y hito sugerido. |
| `horus-riesgo` | Riesgos, mitigaciones y que no tocar. |
| `narrador-normativo` | Frase de apertura y cierre verbal. |

## Cierre

La pasada queda cerrada solo como preliminar si:

- el plan queda versionado;
- el gate queda visible;
- las tools de write quedan en espera de cierre explicito;
- el proximo movimiento unico exige target exacto.
