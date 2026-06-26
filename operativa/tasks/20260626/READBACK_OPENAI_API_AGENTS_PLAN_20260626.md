# READBACK_OPENAI_API_AGENTS_PLAN_20260626

## Estado

HECHO_VERIFICADO:

- Se preparo plan para una celda de agentes con OpenAI API.
- No se inspecciono ninguna clave.
- No se ejecuto ninguna llamada OpenAI API.
- No se escribio codigo de agentes.
- No se tocaron runtime, Git remoto, Microsoft live ni secretos.

## Sistemas tocados

- Repo local `C:\CEO\project-cdx`: se agregaron artefactos documentales bajo `operativa/tasks/20260626`.

## Sistemas no tocados

- OpenAI API: no llamada.
- `OPENAI_API_KEY`: no inspeccionada, no impresa, no modificada.
- Git remoto: no fetch, no push, no PR.
- Git index: no stage.
- Microsoft, Dataverse, SharePoint, watchdog runtime, scheduler, NOC web: no tocados.

## Cambios

Artefactos creados:

- `operativa/tasks/20260626/PLAN_OPENAI_API_AGENTS_CELL_20260626.md`
- `operativa/tasks/20260626/READBACK_OPENAI_API_AGENTS_PLAN_20260626.md`

## Validacion

- Se leyo `pyproject.toml`: `openai-agents>=0.17.5` ya esta declarado.
- Se leyeron contratos locales de runtime/agentes en `.cabina\SDU_RUNTIME_ROOT`.
- Se consulto documentacion oficial OpenAI Agents para orientar el plan.
- Se aplico el gate de `openai-platform-api-key`: no build/run/test/config API antes de decidir credenciales.

## Riesgos

- La autorizacion de OpenAI API no equivale a permiso para Microsoft live, Dataverse, produccion o secretos.
- La implementacion debe enviar solo datos saneados y acotados al modelo.
- Si se empieza con demasiados especialistas, se duplica complejidad antes de probar el camino minimo.

## Rollback

Rollback local documental:

- Remover este readback.
- Remover `PLAN_OPENAI_API_AGENTS_CELL_20260626.md`.
- Recalcular `VERSION_STATE.json`.

## Proximos carriles

1. Aprobar credential gate.
2. Decidir reutilizar clave existente o crear nueva mediante OpenAI Platform.
3. Crear contrato local `docs/openai-agents/contracts.md`.
4. Implementar orquestador minimo con tools read-only.
5. Agregar evals de secretos/live/remoto/destructivo.

## Output Contract

- `agente`: Codex
- `orden`: preparar plan para agentes con OpenAI API
- `superficie`: C:\CEO\project-cdx
- `skill`: openai-developers:agents-sdk; openai-developers:openai-platform-api-key; planning-with-files
- `receta`: plan-only, no api call, credential gate first
- `tool`: PowerShell read-only; apply_patch
- `estado`: PLAN_READY_NO_API_CALLS
- `evidencia`: PLAN_OPENAI_API_AGENTS_CELL_20260626.md
- `validador`: lectura pyproject + contratos locales + docs oficiales
- `riesgo`: secretos/datos sensibles/live gates
- `rollback`: documental local
- `stop_condition`: falta decision credential gate
- `proximos_carriles`: credential gate + contrato local
