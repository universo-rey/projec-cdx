---
artifact_id: operativa/PLAN_MAESTRO_ATOMICO_TENANT_DATAVERSE_CODEX_CLOUD_20260617.md
categoria: operativa
tipo: plan
estado: aprobado
version: 2026.06.21
autoridad:
  tipo: owner
  referencia: '@SeshatSgin'
origen: GitHub
ubicacion_repo: operativa/PLAN_MAESTRO_ATOMICO_TENANT_DATAVERSE_CODEX_CLOUD_20260617.md
etiquetas:
- operativa
- plan
- metadata
relacionados:
- operativa/MAPA.md
descripcion: Plan maestro atomico para tenant Dataverse y Codex Cloud.
fecha_evento: '2026-06-17'
---

# VIVO: Plan Maestro Atomico Tenant Dataverse Codex Cloud 20260617

Estado: `PLAN_PREPARADO_VERSIONABLE`
Fecha: `2026-06-17`
Owner humano: `Enzo Figueroa`
Tenant: `Escribania Bitsch`
Tenant id: `858a0852-44a1-413e-a0fe-f053949797d6`
Dataverse principal observado: `HUBDesarrollo`
Dataverse URL: `https://org084965d9.crm.dynamics.com`
Codex Cloud branch: `codex/dataverse-corte-ejecutora-v1`
Modo base: `metadata-only / read-only / local-first`
Modo Corte: `CORTE_EJECUTORA_GOVERNED`

## Formula Operativa

Mi orden viva activa el sistema.
Codex ejecuta y razona rapido.
Dataverse contiene memoria estructural de largo plazo.
Los agentes consumen, corrigen, hidratan y devuelven evidencia.
El tenant es superficie gobernada, no territorio desconocido.
Cada delta nace atomico, idempotente, trazable, reversible y versionable.

## Frontera Canon Workbench

`.codex` es infraestructura local de runtime, memoria operativa y canon global promovido.
`PROJEC CDX` es workbench, espejo operativo versionable y plano de preparacion.
`Documents/GitHub` es la raiz canonica de repos.

Ningun hito local se considera promovido a canon global hasta que una wave lo declare en su evidencia, postcheck y cierre.

## Objetivo

Ordenar, corregir y asegurar la integracion total entre:

- repos canonicos en `C:/Users/enzo1/Documents/GitHub`;
- workbench local `C:/Users/enzo1/PROJEC CDX`;
- tenant Escribania Bitsch;
- Dataverse `HUBDesarrollo`;
- Power Platform, colas y agentes;
- SharePoint/Teams/Planner como superficies Microsoft gobernadas;
- Codex Cloud como centro rapido de ejecucion y razonamiento;
- skills, recetas, indices, patrones, tools e hitos.

El plan no declara cierre total todavia. Declara la secuencia de cierre por waves atomicas.

## Estado De Partida

Evidencia base:

- `inventarios/WORKBENCH_COMPLETION_REPOS_20260617.csv`
- `inventarios/WORKBENCH_COMPLETION_ENVIRONMENTS_20260617.csv`
- `inventarios/WORKBENCH_COMPLETION_GAPS_20260617.csv`
- `operativa/READBACK_FAN_IN_CORTE_WORKBENCH_COMPLETION_20260617.md`
- `operativa/READBACK_DATAVERSE_POWER_PLATFORM_TENANT_ESCRIBANIA_BITSCH_20260616.md`
- `operativa/READBACK_CODEX_CLOUD_BRIDGE_20260617.md`

Foto actual:

- Superficies GitHub relevadas: `19`.
- Repos Git: `17`.
- Carpetas no repo: `2`.
- Repos con worktree dirty: `13`.
- Gap `github_repos_missing_mapa`: `17`.
- Gap `workbench_root_missing_mapa`: `1`.
- Gap `dirty_worktree`: `13`.
- Gap `not_git_repo`: `2`.
- Codex Cloud bridge local: `PASS`.
- Gate Microsoft/Dataverse/Power Platform: no live write salvo orden atomica explicita.

## Principios No Negociables

1. Inspect first: ningun repo dirty se limpia, revierte, mueve o stagea sin clasificar su diff.
2. Atomicidad: un delta toca una superficie coherente, con un owner, una evidencia y un rollback.
3. Idempotencia: reejecutar el delta no duplica archivos, filas, punteros, tareas ni evidencia.
4. Trazabilidad: toda salida se registra como fuente -> proceso -> salida -> hito -> cierre.
5. Dataverse es estructura de orden y memoria: no se lo trata como superficie extrana ni como permiso implicito para mutar.
6. Codex Cloud ejecuta rapido, pero no reemplaza autoridad: no imprime secretos, no toca produccion, no escribe live sin gate.
7. Stop condition no es bloqueo permanente: se expresa como `EN_ESPERA_DE_CIERRE` o `next_delta` salvo impasse real repetido.
8. Solo autoridad humana establece o deroga bloqueos institucionales.
9. Ningun agente se aprueba a si mismo en live, permisos, costo, produccion o borrado.
10. Los repos canonicos viven en `Documents/GitHub`; `PROJEC CDX` es workbench y plano de gobierno.
11. Toda wave tiene `audit_status` separado del estado operativo.
12. Toda live gate exige owner humano, target exacto, candidate count, permission scope, rollback, postcheck, validator y evidence sink.

## Corte Y Agentes

| Agente | Funcion | Salida Esperada |
| --- | --- | --- |
| `Seshat` | Canon, lenguaje, identidad y mapa semantico | README/AGENTS/MAPA coherentes, sin contradiccion canonica |
| `Thot` | Arquitectura tecnica, repo topology, Dataverse schema | matrices, crosswalks, validators, comandos reproducibles |
| `Anubis` | Gates, idempotencia, seguridad y no-live | semaforo por delta, rollback, stop conditions |
| `Maat` | Cumplimiento, evidencia, consistencia institucional | readback verificable y cadena de custodia documental |
| `Horus` | Riesgo, drift, colas y superficie amplia | riesgos priorizados, drift map, delta unico siguiente |
| `Narrador` | Integracion, energia de lectura y closeout | acta/readback que despierte accion, no texto plano |
| `Einstein` | Arquitectura atomica y sistema de principios | criterio de arquitectura e idempotencia global |
| `Faraday` | Integracion tenant/Dataverse/Codex Cloud | preflight, gates, smoke y puente operativo |
| `Ramanujan` | Secuencia, conteo, orden fino y convergencia | orden de waves, metricas y cierre sin duplicados |

## Fan-In De Subagentes

La mesa tecnica devolvio tres ajustes que quedan incorporados:

- Einstein: no mezclar saneamiento documental, repos Git, Dataverse, tenant y Codex Cloud en una misma PR; cada lane debe producir una matriz reejecutable con ids estables.
- Faraday: toda integracion tenant/Dataverse/Codex Cloud debe separar `local_evidence`, `metadata_only`, `prepared_not_executed`, `observed_read_only` y `live_requires_gate`.
- Ramanujan: resolver primero repos de mayor impacto canonico y runtime; dejar repos complejos con evidencia nueva para paquete propio; no crear `MAPA.md` por reflejo.

## Fan-In De Revision De Corte

La Corte reviso el plan en modo read-only y devolvio veredicto integrado `OBSERVED_APTO_PARA_W1_READ_ONLY`.

- Seshat: pidio explicitar `CORTE_EJECUTORA_GOVERNED`, frontera `.codex`/workbench y checkpoint de identidad.
- Thot: pidio `postcheck`, validadores de cadena y separar Codex Cloud local pass de Cloud task pendiente.
- Anubis: pidio candidate count, acciones permitidas/bloqueadas, permission scope y rollback no destructivo para Dataverse.
- Maat: pidio owner humano por wave, decision humana auditable, evidence sink y custodia.
- Horus: pidio separar metricas de mapas, declarar snapshot Dataverse y no avanzar a W4/W5/W6 sin cerrar W1.
- Narrador: pidio readback W0 antes de W1 y mantener el proximo delta unico.

Evidencia: `operativa/READBACK_REVISION_CORTE_PLAN_MAESTRO_ATOMICO_20260617.md`.

## Waves Encadenadas

### W0 - Preflight De Mesa

Objetivo: congelar la foto de arranque sin congelar la operacion.

- Owner: `Narrador`
- Reviewer: `Maat`
- Read scope: `operativa`, `inventarios`, `hitos`, `dataverse`, estado Git local.
- Write scope: solo plan, matriz, readback e hito en `PROJEC CDX`.
- Lock key: `plan-maestro-20260617`
- Evidencia: este plan y matriz `operativa/MATRIZ_PLAN_MAESTRO_ATOMICO_20260617.csv`.
- Validador: `git diff --check`; `tools/validate_proj_cdx_workbench.ps1`; `tools/validate_proj_cdx_sync.ps1`; `tools/validate_proj_cdx_operational_chain.ps1`.
- Postcheck: readback W0 versionado, matriz ampliada, git limpio o diff acotado, sin live writes.
- Rollback: revertir este paquete de plan y la entrada de indice.
- Stop condition: `plan_without_validator`.
- Estado esperado: `PLAN_PREPARADO_VERSIONABLE`.

### W1 - Triage Repos Dirty

Objetivo: clasificar los `13` repos dirty sin staging ciego.

- Owner: `Ramanujan`
- Reviewer: `Anubis`
- Read scope: `C:/Users/enzo1/Documents/GitHub/*`, solo `git status`, `git diff --stat`, `git diff --name-status`.
- Write scope: ninguno durante scouting; despues, solo repo/branch del paquete aprobado.
- Lock key: `repo-dirty-triage-by-surface`
- Evidencia: matriz de diffs por repo, owner, tipo de cambio, accion propuesta.
- Validador: `git status --short --branch` por repo; si existe, validador propio del repo.
- Postcheck: matriz read-only de los `13` dirty con recomendacion `commit/archive/pending` y sin staged changes.
- Rollback: no aplica en scouting; en ejecucion, commit reversible o branch dedicada.
- Stop condition: `repo_diff_unclassified`.
- Estado esperado: `OBSERVED_READ_ONLY`.

Orden sugerido:

1. `cabina-universal-d`: autoridad/canon, mayor impacto.
2. `sdu-canon`: canon compartido antes de satelites.
3. `tcu-agentic-runtime-control`: runtime control.
4. `tge-agentic-runtime-control-escribania`: runtime Escribania.
5. `torre-gemela-escribania`: base Escribania.
6. `seshat-bootstrap-sdu-cn`: identidad/prompt Corte, alto valor semantico.
7. `Sgin`: superficie documental SGIN y carpeta `torres`.
8. `sgin-cumplimiento`: satelite SGIN.
9. `cdf-soluciones`: paquetes delegados Seshat/Corte, evidencia operativa; requiere paquete propio.
10. Repos README-only de cierre: `jara-consultores`, `microsoft-agents-governed-lab`, `modo-on-foundation`, `organizacion`.

### W2 - Mapas Minimos Por Repo

Objetivo: resolver `missing_mapa_md=18` sin fabricar mapas ruidosos.

- Owner: `Seshat`
- Reviewer: `Thot`
- Read scope: README/AGENTS/estructura raiz de cada repo.
- Write scope: `MAPA.md` solo si aporta navegacion real; si no, registrar decision `README+AGENTS_SUFFICIENT`.
- Lock key: `repo-map-minimal-canon`
- Evidencia: decision por repo con `map_required`, `map_created`, `map_deferred`.
- Validador: links relativos validos y `git diff --check`.
- Postcheck: `identity_drift_check` y decision `MAPA.md` vs `README+AGENTS_SUFFICIENT` por repo.
- Rollback: remover el mapa creado o volver a README/AGENTS como unica superficie.
- Stop condition: `map_would_duplicate_readme`.
- Estado esperado: `DELTA_APLICADO` o `NO_OP_LISTO`.

### W3 - Carpetas No Repo

Objetivo: clasificar `Auditar` y `cdf_gate68_solution_clone`.

- Owner: `Thot`
- Reviewer: `Horus`
- Read scope: nombre, tamanio, manifiestos, indicadores de origen.
- Write scope: ninguno hasta decision de owner.
- Lock key: `nongit-folder-classification`
- Evidencia: `archive_reference`, `promote_to_repo`, `move_to_archive`, o `keep_as_external_surface`.
- Validador: existencia antes/despues, ruta absoluta y razon.
- Postcheck: ninguna carpeta movida sin destino, owner y comando inverso.
- Rollback: si se mueve, manifestar origen/destino y comando inverso.
- Stop condition: `folder_identity_ambiguous`.
- Estado esperado: `OBSERVED_READ_ONLY`.

### W4 - Dataverse Metadata Hydration

Objetivo: preparar metadata estructurada para Dataverse sin duplicar punteros ni escribir por inferencia.

- Owner: `Faraday`
- Reviewer: `Anubis`
- Read scope: readbacks Dataverse, promotion manifests, matrices, `WORKBENCH_COMPLETION_*`.
- Write scope: paquetes locales `dataverse/`, `operativa/`, `hitos/`; live solo con orden especifica.
- Lock key: `dataverse-metadata-hydration`
- Evidencia: manifest YAML, matriz CSV y readback por wave.
- Validador: `tools/validate_sdu_dataverse_metadata_wave.ps1` si existe; si no, `candidate_count=1` y conteo `source/evidence`.
- Postcheck: `candidate_count=1`, `allowed_action` compatible con gate y `blocked_action` no ejecutada.
- Rollback: supersede/disable pointer por `canonical_id` bajo orden humana; borrado solo con gate destructivo separado.
- Stop condition: `candidate_count_not_one`.
- Estado esperado: `METADATA_ONLY_PREPARED`.

Shape canonico:

```csv
wave_id,metadata_id,tenant_id,environment_name,surface,source_artifact,target_entity_set,target_logical_name,canonical_id,display_name,classification,status,owner,evidence_ref,rollback,postcheck,validator,stop_condition,notes
```

Shape operativo extendido para integracion:

```csv
source_surface,tenant_id,environment_url,entity_set,record_key,candidate_count,classification,allowed_action,blocked_action,evidence_file,stop_condition
```

Regla de idempotencia Dataverse:

- `tenant_id + environment_name + target_entity_set + canonical_id` debe resolver a `0` o `1`.
- Si resuelve a `0`, queda preparado o crea solo bajo gate.
- Si resuelve a `1` y el hash/canonical payload coincide, resultado `NO_OP_LISTO`.
- Si resuelve a `>1`, resultado `EN_ESPERA_DE_CIERRE` con delta de deduplicacion.

### W5 - Tenant Y Power Platform Readback

Objetivo: mantener tenant, Power Platform, colas, bots, Teams, Planner y SharePoint como superficie gobernada y no mezclada.

- Owner: `Horus`
- Reviewer: `Maat`
- Read scope: summaries saneados, conteos, ids de entorno, colas y soluciones.
- Write scope: readback local; no Teams/Planner/SharePoint/flow write.
- Lock key: `tenant-readback-no-payload`
- Evidencia: conteos, ids, URLs, candidate count, sin payload sensible.
- Validador: tenant id coincide con `858a0852-44a1-413e-a0fe-f053949797d6`.
- Postcheck: evidencia marcada como snapshot si no se refresca antes de hidratar.
- Rollback: no aplica en read-only; retirar readback si se detecta tenant mismatch.
- Stop condition: `tenant_mismatch`.
- Estado esperado: `OBSERVED_READ_ONLY`.

### W6 - Codex Cloud Runner Y Smoke

Objetivo: dejar Codex Cloud como centro de ejecucion rapida sin depender de memoria de UI ni rutas Windows.

- Owner: `Faraday`
- Reviewer: `Thot`
- Read scope: branch remota, setup cloud, smoke task, cloud bridge.
- Write scope: prompts y readbacks locales; Cloud task solo via UI/API autorizada y sin secretos.
- Lock key: `codex-cloud-runner-smoke`
- Evidencia: salida `--smoke`, `--cloud-bridge`, `--agentic-cloud-bridge`.
- Validador: `python -m projec_cdx_cloud --smoke`; `python -m projec_cdx_cloud --cloud-bridge`.
- Rollback: revertir cambios del runner; resetear cache Cloud si la UI conserva ruta vieja.
- Stop condition: `cloud_workspace_path_windows`.
- Estado esperado: `LOCAL_PASS` y `CLOUD_TASK_PENDING`.

Contrato Codex Cloud:

- Workspace path Linux: `/workspace/projec-cdx`.
- No usar `C:\Users\...` en setup cloud.
- No variable con guion como `EATOMIC-ON`.
- No imprimir `OPENAI_API_KEY`.
- Smoke responde PASS/OBSERVED/FAIL con evidencia.
- El commit probado en Cloud debe declararse; si difiere de la rama local, estado `context_drift`.

### W7 - Integracion De Skills, Recetas, Tools E Indices

Objetivo: promover aprendizaje estable a canon reusable.

- Owner: `Seshat`
- Reviewer: `Narrador`
- Read scope: skills usadas, recetas, patrones, validators, readbacks.
- Write scope: `recipes/`, `procesos/`, `patrones/`, `tools/`, indices e hito.
- Lock key: `canon-recipe-skill-sync`
- Evidencia: matriz skill/recipe/tool/patron con source readback.
- Validador: `git diff --check`; validador especifico si existe.
- Postcheck: aprendizaje promovido a skill/recipe/tool/patron o declarado `NO_OP_LISTO`.
- Rollback: revertir archivo nuevo o retirar entrada de indice.
- Stop condition: `knowledge_left_only_in_chat`.
- Estado esperado: `DELTA_APLICADO`.

### W8 - Cierre Por Hitos Y Semaforo

Objetivo: convertir cada wave aplicada en hito auditable y cierre legible.

- Owner: `Narrador`
- Reviewer: `Maat`
- Read scope: paquetes generados, validadores, git status, readbacks.
- Write scope: `hitos/<wave-id>`, `hitos/INDICE_MAESTRO.csv`, `operativa/TRACE.md`, `operativa/NEXT.md`.
- Lock key: `hito-closeout-atomic`
- Evidencia: README, MANIFEST, INDICE, READBACK, EVIDENCIA.
- Validador: `git diff --check`; `tools/validate_proj_cdx_workbench.ps1`; `tools/validate_proj_cdx_sync.ps1`; `tools/validate_proj_cdx_operational_chain.ps1`.
- Postcheck: hito contiene README, MANIFEST, INDICE, READBACK, EVIDENCIA y entrada de `TRACE`.
- Rollback: retirar hito y entradas de indice/trace.
- Stop condition: `evidence_missing`.
- Estado esperado: `DELTA_APLICADO` o `EN_ESPERA_DE_CIERRE`.

## Semaforo

| Frente | Estado | Lectura |
| --- | --- | --- |
| Plan maestro | `PLAN_PREPARADO_VERSIONABLE` | Este paquete fija la secuencia. |
| Repos dirty | `EN_ESPERA_DE_CIERRE` | Falta clasificar diffs antes de escribir. |
| Mapas por repo | `DELTA_PREPARADO` | Crear solo si aporta navegacion real. |
| Dataverse | `METADATA_ONLY_PREPARED` | Live solo con target exacto y candidate count `1`. |
| Tenant Microsoft | `OBSERVED_READ_ONLY` | No hay bloqueo; hay gates por superficie. |
| Codex Cloud | `READY_FOR_CODEX_CLOUD_UI` | Runner local PASS; Cloud UI/task requiere ejecucion separada. |
| Skills/recetas/tools | `DELTA_PREPARADO` | Promover aprendizaje estable por wave. |

## Semaforo De Revision De Corte

| Agente | Estado | Lectura |
| --- | --- | --- |
| Seshat | `OBSERVED` | Plan despierta accion; pide frontera canon/workbench y modo Corte. |
| Thot | `OBSERVED` | Arquitectura apta; pide postcheck y validadores de cadena. |
| Anubis | `OBSERVED` | Gates correctos; pide candidate count, permission scope y rollback no destructivo. |
| Maat | `OBSERVED` | Plan gobernable; pide custodia humana auditable por wave. |
| Horus | `OBSERVED` | Secuencia correcta; pide W1 antes de mapas, Dataverse o Cloud. |
| Narrador | `OBSERVED` | Cadena clara; pide readback W0 antes de ejecutar W1. |

## Packet Para Agente

Cada agente que tome un carril debe devolver:

```yaml
agente:
modo_corte:
orden:
surface:
read_scope:
write_scope:
lock_key:
status:
audit_status:
owner_humano:
decision_humana_required:
decision_id:
evidence:
evidence_sink:
validator:
rollback:
postcheck:
stop_condition:
next_delta:
```

## Proximo Delta Unico

`delta_repo_dirty_worktree_triage_by_surface`

Primera accion: generar matriz de diffs por los `13` repos dirty, sin staged changes, sin revert, sin move, sin live write.
