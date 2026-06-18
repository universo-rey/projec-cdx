# Despierta PROJEC CDX: Circuito Vivo

Carpeta de trabajo local para artefactos y mapas de Codex.

La consolidacion operativa mas reciente es [CONSOLIDACION_OPERATIVA_EN_WAVES_20260615.md](C:/Users/enzo1/PROJEC%20CDX/operativa/CONSOLIDACION_OPERATIVA_EN_WAVES_20260615.md).

## Vigencia 20260618

- Estado vigente: `DATAVERSE_LIVE_ROWS_BOUND_TO_WORKBOOK`.
- Movimiento unico actual: `delta_commit_dataverse_workbook_binding_branch`.
- Paquetes: no crear mas si ya existe hito, readback, indice o paquete vigente.
- SGIN: ya fue leido y paquetizado; no reabrir lectura ni crear paquete nuevo por inercia.
- Navegacion de vigencia: [PENDIENTES_HOY_20260617.md](C:/Users/enzo1/PROJEC%20CDX/operativa/PENDIENTES_HOY_20260617.md), [CURRENT.md](C:/Users/enzo1/PROJEC%20CDX/operativa/CURRENT.md), [NEXT.md](C:/Users/enzo1/PROJEC%20CDX/operativa/NEXT.md) y [INDICE_MAESTRO.md](C:/Users/enzo1/PROJEC%20CDX/hitos/INDICE_MAESTRO.md).

## Al Frente

- [cierre-wave-documental.md](C:/Users/enzo1/PROJEC%20CDX/recipes/cierre-wave-documental.md)
- [dataverse-rehidratacion.md](C:/Users/enzo1/PROJEC%20CDX/recipes/dataverse-rehidratacion.md)
- [normalizacion-perfil-windows.md](C:/Users/enzo1/PROJEC%20CDX/recipes/normalizacion-perfil-windows.md)
- [agentes-atomicos-algoritmicos-en-waves.md](C:/Users/enzo1/PROJEC%20CDX/recipes/agentes-atomicos-algoritmicos-en-waves.md)
- [documentos-canon-atomico](C:/Users/enzo1/.codex/skills/documentos-canon-atomico/SKILL.md)

- [README_CORTO.md](C:/Users/enzo1/PROJEC%20CDX/README_CORTO.md)
- [MAPA_CORTO.md](C:/Users/enzo1/PROJEC%20CDX/MAPA_CORTO.md)
- [Arranque Codex Cloud](C:/Users/enzo1/PROJEC%20CDX/README_ARRANQUE_CODEX_CLOUD.md)

## Canon

`PROJEC CDX` es el workbench local gobernado de Codex para organizar, versionar y navegar artefactos, mapas, inventarios, workbooks, paquetes, hitos y herramientas. Cada entrada visible debe ser accionable: corta, clara y lista para empujar el siguiente paso. En este workspace, lo atomico no es solo lo pequeño; es lo que concentra energia util para actuar. Estado ecosistemico visible: `GREEN_OPERABLE`.

## Lectura Activa

Entraste al circuito. No leas por leer: tomá el rol, ubicá tu tramo y arrancá con energia.
Cada linea tiene que mover, no decorar; tiene que decirte quien sos, donde estas y que sigue ahora.

La cobertura atomica energetica queda introducida en [operativa/COBERTURA_ATOMICA_ENERGETICA_20260615.md](C:/Users/enzo1/PROJEC%20CDX/operativa/COBERTURA_ATOMICA_ENERGETICA_20260615.md) y se apoya en [Paquete atomico](C:/Users/enzo1/PROJEC%20CDX/atomic/README.md).

Codex Cloud tiene un runner minimo en `main.py` y `src/projec_cdx_cloud/`:

```powershell
.\\.venv\\Scripts\\Activate.ps1
.\\.venv\\Scripts\\python main.py --smoke
.\\.venv\\Scripts\\python -m projec_cdx_cloud --smoke
.\\.venv\\Scripts\\python main.py --json --smoke
.\\.venv\\Scripts\\python main.py --prompt "Resume el contrato Codex Cloud con energia atomica."
```

Arranque vivo unico:

```powershell
pwsh -NoProfile -File ".\tools\codex-cloud-live.ps1"
```

Si queres cambiar solo el texto de entrada:

```powershell
pwsh -NoProfile -File ".\tools\codex-cloud-live.ps1" -Prompt "Tu prompt aca"
```

## Contrato Cognitivo

- La cadena de agentes empuja energia atomica potenciadora: los atomos nacen en `Codex Cloud`, `Dataverse` los contiene y los alimenta, y los agentes los consumen.
- Leeme como orden viva: identidad, pertenencia y guia para entrar en el flujo sin friccion.
- El consumo puede ser instantaneo, directo desde la fuente, o diferido, desde el almacen de `Dataverse`, segun el tramo que toque.
- `Dataverse` no es una superficie desconocida, extraña ni insegura: es un carril gobernado del sistema y tenemos agentes alli.
- `Codex Cloud` y `Dataverse` no compiten; forman un circuito unico de generacion, contencion, memoria y consumo.

## Entradas

- [Mapa por capas](C:/Users/enzo1/PROJEC%20CDX/MAPA_CAPAS.md)
- [Mapa corto](C:/Users/enzo1/PROJEC%20CDX/MAPA_CORTO.md)
- [Mapa maestro](C:/Users/enzo1/PROJEC%20CDX/MAPA_MAESTRO.md)
- [AGENTS.reference.md](C:/Users/enzo1/PROJEC%20CDX/AGENTS.reference.md)
- [Operativa](C:/Users/enzo1/PROJEC%20CDX/operativa/README.md)
- [Operativa corto](C:/Users/enzo1/PROJEC%20CDX/operativa/README_CORTO.md)
- [Operativa mapa corto](C:/Users/enzo1/PROJEC%20CDX/operativa/MAPA_CORTO.md)
- [Recipes](C:/Users/enzo1/PROJEC%20CDX/recipes/README.md)
- [Start here](C:/Users/enzo1/PROJEC%20CDX/operativa/START_HERE.md)
- [Control operativo](C:/Users/enzo1/PROJEC%20CDX/operativa/CONTROL.md)
- [Prompt nuevo hilo](C:/Users/enzo1/PROJEC%20CDX/operativa/PROMPT_NUEVO_HILO.md)
- [Readback de cierre](C:/Users/enzo1/PROJEC%20CDX/operativa/READBACK_CIERRE_20260615.md)
- [TODO actual](C:/Users/enzo1/PROJEC%20CDX/operativa/TODO_20260615.md)
- [Acta cierre cadena GitHub Auditar](C:/Users/enzo1/PROJEC%20CDX/operativa/ACTA_CIERRE_CADENA_GITHUB_AUDITAR_20260615.md)
- [Acta semaforo verde historicos](C:/Users/enzo1/PROJEC%20CDX/operativa/ACTA_SEMAFORO_VERDE_HISTORICOS_20260615.md)
- [Control total general](C:/Users/enzo1/PROJEC%20CDX/operativa/CONTROL_TOTAL_20260615.md)
- [Control total .codex](C:/Users/enzo1/PROJEC%20CDX/operativa/CODEX_ROOT_CONTROL_20260615.md)
- [Taxonomia y nomenclatura](C:/Users/enzo1/PROJEC%20CDX/operativa/TAXONOMIA_NOMENCLATURA_20260615.md)
- [Nomenclatura cadena operativa](C:/Users/enzo1/PROJEC%20CDX/operativa/NOMENCLATURA_CADENA_OPERATIVA_20260615.md)
- [Patrones](C:/Users/enzo1/PROJEC%20CDX/patrones/README.md)
- [Procesos](C:/Users/enzo1/PROJEC%20CDX/procesos/README.md)
- [Playbooks](C:/Users/enzo1/PROJEC%20CDX/playbooks/README.md)
- [Excel al frente](C:/Users/enzo1/PROJEC%20CDX/workbooks/EXCEL_AL_FRENTE.md)
- [Workbook de control](C:/Users/enzo1/PROJEC%20CDX/workbooks/control_operativo.xlsx)
- [Configuracion vigente](C:/Users/enzo1/PROJEC%20CDX/workbooks/CODEX_GLOBAL_STATE_DECISION_WORKBOOK_20260617.xlsx)
- [Tracker](C:/Users/enzo1/PROJEC%20CDX/workbooks/tracker.xlsx)
- [Dataverse](C:/Users/enzo1/PROJEC%20CDX/dataverse/README.md)
- [src](C:/Users/enzo1/PROJEC%20CDX/src/README.md)
- [Matriz cadena operativa Dataverse](C:/Users/enzo1/PROJEC%20CDX/dataverse/MATRIZ_CADENA_OPERATIVA_DATAVERSE_20260615.md)
- [Recipes map](C:/Users/enzo1/PROJEC%20CDX/recipes/MAPA.md)
- [Paquete atomico](C:/Users/enzo1/PROJEC%20CDX/atomic/README.md)
- [Cobertura atomica energetica](C:/Users/enzo1/PROJEC%20CDX/operativa/COBERTURA_ATOMICA_ENERGETICA_20260615.md)
- [Herramientas](C:/Users/enzo1/PROJEC%20CDX/tools/README.md)
- [Validador local](C:/Users/enzo1/PROJEC%20CDX/tools/validate_proj_cdx_workbench.ps1)
- [Validador sincronizacion](C:/Users/enzo1/PROJEC%20CDX/tools/validate_proj_cdx_sync.ps1)
- [Validador cadena operativa](C:/Users/enzo1/PROJEC%20CDX/tools/validate_proj_cdx_operational_chain.ps1)
- [Docs](C:/Users/enzo1/PROJEC%20CDX/docs/README.md)
- [Inventarios](C:/Users/enzo1/PROJEC%20CDX/inventarios/README.md)
- [CodexLocal surface map](C:/Users/enzo1/PROJEC%20CDX/inventarios/CODEXLOCAL_SURFACE_MAP_20260615.csv)
- [CodexLocal split Cabina](C:/Users/enzo1/PROJEC%20CDX/inventarios/CODEXLOCAL_SPLIT_CABINA_20260615.csv)
- [GitHub repos canonicos](C:/Users/enzo1/PROJEC%20CDX/inventarios/GITHUB_REPOS_CANONICAL_20260615.csv)
- [Auditar surface index](C:/Users/enzo1/PROJEC%20CDX/inventarios/AUDITAR_SURFACE_INDEX_20260615.csv)
- [Workbooks](C:/Users/enzo1/PROJEC%20CDX/workbooks/README.md)
- [Packages](C:/Users/enzo1/PROJEC%20CDX/packages/README.md)
- [Hitos versionados](C:/Users/enzo1/PROJEC%20CDX/hitos/README.md)
- [Hilo de origen consolidado](C:/Users/enzo1/PROJEC%20CDX/hitos/20260615-hilo-origen-v1/README.md)
- [Dataverse conexiones y drift](C:/Users/enzo1/PROJEC%20CDX/hitos/20260615-dataverse-conexiones-drift-v1/README.md)
- [Corte ejecutora vs SDU](C:/Users/enzo1/PROJEC%20CDX/hitos/20260615-corte-ejecutora-vs-sdu-v1/README.md)
- [Wave revision total](C:/Users/enzo1/PROJEC%20CDX/hitos/20260615-wave-revision-total-v1/README.md)
- [CodexLocal base](C:/Users/enzo1/PROJEC%20CDX/hitos/20260615-codexlocal-base-v1/README.md)
- [GitHub repos canonical](C:/Users/enzo1/PROJEC%20CDX/hitos/20260615-github-repos-canonical-v1/README.md)
- [GitHub repos chain](C:/Users/enzo1/PROJEC%20CDX/hitos/20260615-github-repos-chain-v1/README.md)
- [Auditar surface chain](C:/Users/enzo1/PROJEC%20CDX/hitos/20260615-auditar-surface-chain-v1/README.md)
- [Cierre cadena GitHub Auditar](C:/Users/enzo1/PROJEC%20CDX/hitos/20260615-cierre-cadena-github-auditar-v1/README.md)
- [Semaforo verde historicos](C:/Users/enzo1/PROJEC%20CDX/hitos/20260615-semaforo-verde-historicos-v1/README.md)
- [Live repo review](C:/Users/enzo1/PROJEC%20CDX/outputs/live_repo_review_20260615/README.md)
- [Auditoria ejecutiva de cabina](C:/Users/enzo1/PROJEC%20CDX/outputs/cabina_relationship_audit_20260614/CABINA_RELATIONSHIP_AUDIT_EXECUTIVE.xlsx)
- [Codex Root](C:/Users/enzo1/.codex/README.md)
- [Origen del chat actual](C:/Users/enzo1/.codex/attachments/296335cf-ca6e-4cf2-b2c5-a46b23c27ff4/pasted-text.txt)

## Notas

- `node_modules/` contiene dependencias locales.
- `outputs/` contiene resultados generados.
- `tools/` contiene scripts de generacion y normalizacion.
- `patrones/` contiene reglas reutilizables probadas.
- `procesos/` contiene secuencias accionables derivadas de patrones.
- `inventarios/` concentra tablas e inventarios raiz.
- `workbooks/` concentra libros fuente de trabajo.
- `sincronizacion-tiempo-real` gobierna la alineacion inmediata entre fuentes, corridas y cierres.
- Dataverse funciona como memoria larga y estructura de orden: no se consulta por inercia; se consume junto con `Codex Cloud` por la cadena de agentes mediante indices, readbacks y el gate local, siempre gobernado desde aqui.
- Los hitos `20260615-dataverse-conexiones-drift-v1` y `20260615-corte-ejecutora-vs-sdu-v1` cierran el segundo orden de Dataverse.
- El hito `20260615-wave-revision-total-v1` deja la revision total asistida, taxonomia y cadena operativa visible.
- El hito `20260615-codexlocal-base-v1` corrige la base de lectura: `CodexLocal` debe revisarse antes de bajar splits o worktrees aislados.
- El hito `20260615-github-repos-canonical-v1` corrige la fuente de verdad de repos: `Documents\GitHub` manda para operaciones repo; `CodexLocal` queda como evidencia/espejo.
- El hito `20260615-github-repos-chain-v1` incorpora `cabina-universal-d` y `microsoft-agents-governed-lab` a la cadena operativa.
- El hito `20260615-auditar-surface-chain-v1` incorpora `Auditar` como carpeta agregadora no Git con indice.
- El hito `20260615-cierre-cadena-github-auditar-v1` cierra la ronda y deja TODO visible.
- El hito `20260615-semaforo-verde-historicos-v1` reclasifica amarillos historicos a verde gobernado con GitHub live read-only.
- El hito `20260615-pr-cierre-atomico-v1` deja ordenes atomicas para cerrar PRs abiertos con target, owner, rollback, postcheck y evidencia.
- `GREEN_OPERABLE` es el estado visible del ecosistema cuando la mesa esta operable, gobernada y sin bloqueo sistémico.
- `PROJEC CDX` no es repo git; el versionado local depende de `hitos/`, manifests e indices.
- `packages/` concentra paquetes comprimidos.
- Para reordenar superficies, usar `codex-surface-map`.
