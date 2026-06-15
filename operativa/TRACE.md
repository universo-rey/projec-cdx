# Trace

Cadena operativa de `PROJEC CDX`.

## Cadena Actual

- Fuente: pedido del usuario de organizar el trabajo punta a punta y repartir atomicidad.
- Proceso: normalizacion con entradas cortas, mapas, hitos, carril `operativa`, workbook, playbooks, Dataverse gobernado, manifests, retencion, anclas on-demand y validador local.
- Salida: workbench local navegable, accionable, retomable por hilos nuevos y verificable por delta.
- Hito: `hitos/20260615-cierre-workbench-v1`.
- Cierre: semaforo verde local si `tools/validate_proj_cdx_workbench.ps1` pasa sin fallas.

## Consolidacion Operativa En Waves

- Fuente: pedido del usuario de consolidar la operativa en waves cortas.
- Proceso: fijar el delta nuevo, registrar la wave en evidencia local y validar solo el tramo tocado.
- Salida: `operativa/CONSOLIDACION_OPERATIVA_EN_WAVES_20260615.md`.
- Hito: `operativa/CONSOLIDACION_OPERATIVA_EN_WAVES_20260615.md`.
- Cierre: la consolidacion queda visible por capas y sin abrir frentes paralelos.

## Anclas On Demand

- Fuente: pedido del usuario de dejar el prompt y el ancla Dataverse on demand tambien para el resto de procesos.
- Proceso: separar el prompt corto del hub de anclas y sacar Dataverse de la ruta principal para abrirlo solo cuando el delta lo pide.
- Salida: `operativa/PROMPT_CIERRE_WAVE.md`, `operativa/ANCLAS_ON_DEMAND.md`.
- Cierre: cada superficie se abre solo por necesidad real, sin cargar carriles extra por costumbre.

## Procedencia Layout On Demand

- Fuente: pedido del usuario de tener recetas para este tipo de procesos y no repetir la limpieza de tono/procedencia.
- Proceso: separar procedencia tecnica, lectura visible y apertura on-demand en una receta y un proceso reutilizables.
- Salida: `recipes/procedencia-layout-on-demand.md`, `procesos/procedencia-layout-on-demand.md`.
- Cierre: el patron queda reusable para TGE, Dataverse y futuras superficies con la misma forma.

## Complementos On Demand

- Fuente: pedido del usuario de tener acceso visible a todos los complementos desde `PROJEC CDX`.
- Proceso: clasificar cada pedido como `MCP directo` o `plugin activo`, abrir solo el minimo complemento necesario y marcar `NO_DISPONIBLE` si falta.
- Salida: `operativa/COMPLEMENTOS_ON_DEMAND.md`, `recipes/complementos-on-demand.md`, `procesos/complementos-on-demand.md`.
- Cierre: el acceso queda on-demand, gobernado y sin inventar disponibilidad.

## Agentes Atomicos Algoritmicos

- Fuente: pedido del usuario de tener un ancla para usar agentes atomicos algoritmicos.
- Proceso: delegar solo lanes disjuntos con paquete exacto, retorno exacto y fan-in claro.
- Salida: `operativa/ANCLA_AGENTES_ATOMICOS_ALGORITMICOS.md`.
- Cierre: la delegacion queda gobernada por scope minimo, evidencia y validador antes de fan-in.

## Agentes Atomicos Algoritmicos En Waves

- Fuente: pedido del usuario de llevar esa delegacion a waves.
- Proceso: partir el trabajo en waves cortas, un agente por lane, y exigir fan-in antes de abrir otra wave.
- Salida: `recipes/agentes-atomicos-algoritmicos-en-waves.md`, `procesos/agentes-atomicos-algoritmicos-en-waves.md`.
- Cierre: la wave se cierra antes de crecer y no mezcla lanes paralelos.
- Hito: `hitos/20260615-agentes-atomicos-algoritmicos-en-waves-v1`.

## Cobertura Atomica Energetica

- Fuente: pedido del usuario de introducir el elemento atomico energetico en vez de solo decidirlo.
- Proceso: declarar fase e impulso visible en superficies gobernadas y referenciar el contrato cuando la superficie sea de soporte o generada.
- Salida: `operativa/COBERTURA_ATOMICA_ENERGETICA_20260615.md`, `operativa/ANCLA_ENERGIA_ATOMICA.md`.
- Cierre: la energia queda visible desde la entrada minima y se versiona como hito.
- Hito: `hitos/20260615-cobertura-atomica-energetica-v1`.

## Repos Git Codex Y Agents

- Fuente: pedido de conectar `.codex` y `.agents` a GitHub y revisar si convenia renombrar los remotos.
- Proceso: versionar cada superficie como repo propio, publicar `main` y validar que el borde quede limpio.
- Salida: `operativa/ACTA_REPOS_SURFACE_GITHUB_20260615.md`.
- Cierre: los nombres `codex-root` y `agents-root` se mantienen por ahora porque ya son precisos y no agregan ruido.
- Siguiente candidata: `dataverse/PLAN_SEGUNDA_PASADA.md` para la segunda pasada de Dataverse.

## Dataverse Segunda Pasada

- Fuente: pedido de seguir en orden con la segunda pasada de Dataverse.
- Proceso: extender workbook y validador para exponer `dataverse_estado`, `ambiente`, `target_exacto`, `gate_live` y `postcheck`, con alertas y stop conditions.
- Salida: `operativa/ACTA_DATAVERSE_SEGUNDA_PASADA_20260615.md`.
- Validacion: `PASS`.
- Cierre: Dataverse queda visible por estado y gobernado por el gate local, sin live write por inferencia.
- Siguiente paso: si se sigue la secuencia, versionar la segunda pasada en hito.

## Dataverse Segunda Pasada Versionada

- Fuente: confirmacion del usuario para seguir con DV5.
- Proceso: crear el hito `20260615-projec-cdx-dataverse-v1` con README, manifest, indice, evidencia y readback.
- Salida: `hitos/20260615-projec-cdx-dataverse-v1`.
- Cierre: la segunda pasada queda versionada como hito local y lista para readback futuro.

## Ultimo Delta Cerrado

- Fuente: `operativa/PLAN_COMPLETAR_ESTRUCTURA.md`.
- Proceso: Fases 1 a 7 completadas en superficie local.
- Salida: `START_HERE`, `PROMPT_NUEVO_HILO`, playbooks `00` a `06`, validador, workbook real, manifests y retencion.
- Hito: `20260615-cierre-workbench-v1`.
- Cierre: sin live writes, sin secretos, con Dataverse en carril metadata-only/local.

## Ultimo Delta Cerrado 13

- Consolidar la superficie operativa por waves cortas.
- Mantener una sola energia util por tramo.
- Evidencia: `operativa/CONSOLIDACION_OPERATIVA_EN_WAVES_20260615.md`.
- Validacion local: `PASS`.
- Cierre: la wave nueva queda visible en `operativa` sin abrir frentes paralelos.

## Diagnostico Limpieza Pc

- Fuente: pedido del usuario de dejar lista la ultima limpieza con diagnostico registrado.
- Proceso: medir la foto local, dejar evidencia y no tocar `Temp` sin gate explicito.
- Salida: `operativa/ACTA_DIAGNOSTICO_LIMPIEZA_PC_20260615.md`.
- Evidencia: `C:/Users/enzo1/CodexLocal/OPTIMIZACION_PC/OPT_PC_SKILL_20260615_091635`.
- Cierre: el equipo queda diagnosticado y el tramo de limpieza sigue bloqueado por falta de gate para ejecutar.

## Cierre Repos Git Main Only

- Fuente: pedido del usuario de confirmar los 13 repos Git, dejar solo `main`, archivar y resolver el unico desvio.
- Proceso: verificar inventario, resolver `organizacion` a `main`, publicar `origin/main` y registrar acta por repo.
- Salida: `operativa/ACTA_CIERRE_REPOS_GIT_MAIN_ONLY_20260615.md`.
- Hito: esta wave queda absorbida como cierre documental local de repos Git.
- Cierre: los 13 repos confirmados quedan en `main` y limpios; `organizacion` ya esta publicado y alineado.

## Archivo Ramas Historicas

- Fuente: pedido del usuario de dejar una lista corta de ramas historicas para archivo.
- Proceso: registrar solo ramas vivas fuera de `main` sin borrarlas.
- Salida: `operativa/ACTA_ARCHIVO_RAMAS_HISTORICAS_20260615.md` y `operativa/MATRIZ_RAMAS_HISTORICAS_20260615.xlsx`.
- Hito: `hitos/20260615-archivo-ramas-historicas-v1`.
- Cierre: el archivo queda listo para consulta sin tocar repos ni worktrees.

## Matriz Repos Git Main Only

- Fuente: pedido del usuario de convertir el archivo de ramas historicas en una matriz por repo.
- Proceso: resumir repo, ruta, rama, estado, motivo y accion sugerida.
- Salida: `operativa/MATRIZ_REPOS_GIT_MAIN_ONLY_20260615.md`, `operativa/MATRIZ_REPOS_GIT_MAIN_ONLY_20260615.csv` y `operativa/MATRIZ_REPOS_GIT_MAIN_ONLY_20260615.xlsx`.
- Cierre: la wave Git queda consultable por repo en una sola tabla.

## Control Total Rapido

- Resultado: `GREEN_OPERABLE`.
- Conteo: 21 checks gobernados, 0 red.
- Evidencia: `operativa/CONTROL_TOTAL_20260615.md`.
- Lectura: sin rojos; los guardrails de backup `.codex` y repos en `main` quedan como reglas activas no bloqueantes.

## Levantamiento De Patrones Y Procesos

- Fuente: playbooks, gate Dataverse, readback de cierre, control total y hallazgos de agentes.
- Proceso: separar patrones reutilizables de procesos ejecutables.
- Salida: `patrones/` y `procesos/` con README, MAPA e indices.
- Hito: `hitos/20260615-patrones-procesos-v1`.
- Cierre: validar links y registrar readback.

## Sincronizacion Tiempo Real

- Fuente: pedido del usuario de mantener todo sincronizado en tiempo real y rehidratar Dataverse.
- Proceso: declarar contrato de sincronia local, documentar el validador, y separar Dataverse local/metadata-only del carril live gateado.
- Salida: `patrones/sincronizacion-tiempo-real.md`, `procesos/sincronizacion-tiempo-real.md`, `tools/validate_proj_cdx_sync.ps1`.
- Hito: `hitos/20260615-sincronizacion-tiempo-real-v1`.
- Cierre: la fuente viva y la corrida asociada quedan alineadas, con Dataverse aun bajo gate.

## Hilo De Origen Consolidado

- Fuente: pedido del usuario de trackear todo el hilo de origen como indice versionado.
- Proceso: consolidar los hitos previos en un hito padre sin perder los paquetes detallados.
- Salida: `hitos/20260615-hilo-origen-v1`.
- Hito: `hitos/20260615-hilo-origen-v1`.
- Cierre: el hilo de origen queda navegable por capas, con detalle en hitos hijos y resumen en indice padre.

## Dataverse Fronteras

- Fuente: workbook `outputs/dataverse_blocker_frontier_20260614/dataverse_blocker_frontier.xlsx`.
- Proceso: convertir cada fila en `blocker_case`, `human_decision`, `evidence_required` y `resolution_action`.
- Salida: `dataverse/REGISTRO_BLOQUEOS.md`, `playbooks/07-dataverse-fronteras.md`.
- Hito: `hitos/20260615-hilo-origen-v1`.
- Cierre: la frontera queda absorbida en el indice padre y en el workbook de control, sin apertura live por inferencia.

## Comparacion De Workbooks

- Fuente: pedido de comparar `workbooks/inicio.xlsx` y `workbooks/tracker.xlsx` contra sus corridas generadas.
- Proceso: diff de hojas, dimensiones y celdas para los pares espejo.
- Salida: `inicio.xlsx` coincide con `outputs/inicio_workbook_20260613/excel_inicio.xlsx`; `tracker.xlsx` coincide con `outputs/tracker_general_20260613/tracker.xlsx`.
- Revalidacion 2026-06-15: `inicio.xlsx` y `outputs/inicio_workbook_20260613/excel_inicio.xlsx` comparten `SHA256 2249246A2C1386BEC7CFEB78427823D0D691DDBA6D3483421E77CAD01ED98D7F`; `tracker.xlsx` y `outputs/tracker_general_20260613/tracker.xlsx` comparten `SHA256 EDF7AF9D51D13CBADC01E9B466059B78C6C9D0DFB76D4B548EBEA5BA40D9A456`.
- Hito: `hitos/20260615-hilo-origen-v1`.
- Cierre: no hay drift en los espejos primarios; `tracker_workbook.xlsx` queda como variante alterna distinta por diseño.

## Canal Dataverse Corte Ejecutora

- Fuente: pedido de activar el canal Dataverse porque alli hay mas agentes.
- Proceso: reutilizar el packet activo del apply worker, abrir el subcarril en metadata-only y fijar la acta local sin live fetch repetido.
- Salida: `dataverse/ACTA_CORTE_EJECUTORA_20260615.md` como acta operativa unica del canal.
- Salida auxiliar: `dataverse/MAPA_AGENTES.md` con el mapa corto de agentes resuelto.
- Salida auxiliar: `dataverse/MAPA_AGENTES_SDU.md` con el roster SDU postcheckeado.
- Salida auxiliar: `dataverse/MAPA_COLA_TRABAJO_SDU.md` con la cola de trabajo SDU.
- Hito: `hitos/20260615-hilo-origen-v1`.
- Cierre: canal activo como carril gobernado local; el packet conocido sigue en `NO_OP_LISTO_ALREADY_ACTIVE` hasta nuevo target unico.
- Registro adicional: la corte ejecutora deja asentado que este tramo tambien fue obra propia y queda firmado en acta.

## Dataverse Conexiones Y Drift

- Fuente: pedido de llevar a hitos versionados el bloque faltante de Dataverse.
- Proceso: versionar superficies de conexion, gates, evidencia de semilla y drift como mapa corto separado.
- Salida: `dataverse/MAPA_CONEXIONES_DATAVERSE.md`.
- Hito: `hitos/20260615-dataverse-conexiones-drift-v1`.
- Cierre: las superficies, gates y matrices auxiliares quedan al frente sin convertir metadata en write live.

## Corte Ejecutora Vs SDU

- Fuente: pedido de diferenciar la corte ejecutora de los agentes SDU.
- Proceso: separar autoridad/continuidad de roster/cola y registrar esa frontera en acta.
- Salida: `dataverse/ACTA_CORTE_EJECUTORA_20260615.md`, `dataverse/MAPA_AGENTES_SDU.md`, `dataverse/MAPA_COLA_TRABAJO_SDU.md`.
- Hito: `hitos/20260615-corte-ejecutora-vs-sdu-v1`.
- Cierre: la corte ejecutora queda distinguida del roster SDU y de la cola de trabajo.

## Cierre Cadena GitHub Auditar

- Fuente: pedido de usar `CodexLocal` como base, reconocer repos en `Documents/GitHub` y agregar `Auditar` porque ya tiene indice.
- Proceso: cruzar inventarios versionados, cadena operativa, hito GitHub y superficie `Auditar` sin abrir Git write ni live write.
- Salida: `operativa/ACTA_CIERRE_CADENA_GITHUB_AUDITAR_20260615.md`, `operativa/TODO_20260615.md`, `inventarios/GITHUB_REPOS_CANONICAL_20260615.csv`, `inventarios/AUDITAR_SURFACE_INDEX_20260615.csv`.
- Hito: `hitos/20260615-cierre-cadena-github-auditar-v1`.
- Cierre: la ronda queda visible; el unico movimiento natural siguiente es clasificar hijos de `Auditar`.

## Clasificacion Hijos Auditar

- Fuente: pedido de cerrar la clasificacion fina de los hijos indexados de `Auditar`.
- Proceso: separar `support_folder` de superficies `nested_repo_or_folder`, mantener el indice local y no mover ni borrar carpetas.
- Salida: `operativa/ACTA_AUDITAR_CLASIFICACION_20260615.md`.
- Hito: `hitos/20260615-auditar-surface-chain-v1`.
- Cierre: los buckets tecnicos quedan como `REFERENCE_ONLY` y los hijos indexados quedan retenidos sin promocion ni limpieza.

## Semaforo Verde Historicos

- Fuente: pedido de bajar amarillos historicos a semaforo totalmente verde.
- Proceso: reclasificar historicos como archivados, guardrails activos o referencia cerrada, con GitHub remote read-only y sin write remoto.
- Salida: `operativa/ACTA_SEMAFORO_VERDE_HISTORICOS_20260615.md`, indices maestros e hitos actualizados.
- Hito: `hitos/20260615-semaforo-verde-historicos-v1`.
- Cierre: semaforo global local queda verde; pendientes futuros quedan como deltas nuevos, no como bloqueo historico.

## Ordenes Atomicas PR

- Fuente: pedido de abrir orden atomica por PR con target exacto, owner, rollback, postcheck y evidencia.
- Proceso: fijar metadatos exactos de los PR abiertos observados y separar los que estan bloqueados de los que quedan preparados para cierre.
- Salida: `hitos/20260615-pr-cierre-atomico-v1/README.md`, `hitos/20260615-pr-cierre-atomico-v1/INDICE.csv`, `hitos/20260615-pr-cierre-atomico-v1/ORDEN_PR-*.md`.
- Hito: `hitos/20260615-pr-cierre-atomico-v1`.
- Cierre: el cierre real queda gobernado por orden atomica, no por inference ni por estado visual suelto.

## Limpieza Local PC

- Fuente: pedido de revisar la computadora a fondo, recortar ruido y dejar el sistema gobernable desde esta sesion.
- Proceso: inventario de procesos y servicios, deshabilitacion de auxiliares, recorte de superficie de busqueda y cierre de WebView/SearchHost visibles.
- Salida: `operativa/INVENTARIO_FINAL_PC_20260615.md`, `operativa/CURRENT.md`, `operativa/NEXT.md`.
- Hito: `hitos/20260615-cierre-workbench-v1`.
- Cierre: la limpieza local quedo documentada, la superficie de busqueda del usuario quedo recortada y la base de Windows quedo intacta.

## Skill Recipe Sync Limpieza Pc Local Segura

- Fuente: pedido de convertir la limpieza local en piezas reutilizables y registrarla en Dataverse local.
- Proceso: extraer receta, proceso y registro local, engancharlos al skill y mantener el carril local-only.
- Salida: `recipes/limpieza-pc-local-segura.md`, `procesos/limpieza-pc-local-segura.md`, `dataverse/REGISTRO_LIMPIEZA_PC_LOCAL_20260615.md`.
- Hito: `hitos/20260615-cierre-workbench-v1`.
- Cierre: la limpieza queda reusable y registrada sin write live.

## Codex UI Entorno

- Fuente: pedido de dejar configurado el entorno en la UI de Codex y llevarlo a receta.
- Proceso: espejar el entorno del carril en `.codex/config.toml` para el root canonico y el worktree activo, con `shell_environment_policy` y variables del runner.
- Salida: `.codex/config.toml` en `C:\\Users\\enzo1\\PROJEC CDX` y en `C:\\Users\\enzo1\\.codex\\worktrees\\49ea\\PROJEC CDX`; el trust del worktree queda agregado en `~/.codex/config.toml`.
- Cierre: el entorno visible queda alineado con el arranque atomico, sin secretos embebidos, y la receta reusable queda limpia.

## Codex Cloud Scaffold

- Fuente: pedido de no dejar solo el acceso vivo, sino espejar el resto del scaffold del runner.
- Proceso: declarar el entorno seleccionable en `.codex/environments/environment.toml`, espejar setup y cleanup, y completar `pyproject.toml` mas `src/projec_cdx_cloud`.
- Salida: `hitos/20260615-codex-cloud-scaffold-v1`.
- Hito: `hitos/20260615-codex-cloud-scaffold-v1`.
- Cierre: el runner, la UI y el contrato quedan versionados juntos como una sola unidad durable.

## Politica Ramas Versionado

- Fuente: pedido de cerrar la politica para que el scaffold no quedara suelto.
- Proceso: incorporar el scaffold de Codex Cloud como delta durable dentro de `operativa/POLITICA_RAMAS_VERSIONADO_20260615.md`.
- Salida: `hitos/20260615-politica-ramas-versionado-v1`.
- Hito: `hitos/20260615-politica-ramas-versionado-v1`.
- Cierre: la politica local absorbe el scaffold y deja el lane de versionado limpio.

## Repos Surface GitHub

- Fuente: pedido de documentar la wave que dejo `.codex` y `.agents` versionados en GitHub.
- Proceso: absorber la acta local y dejar el cierre sin renombrar `codex-root` ni `agents-root`.
- Salida: `hitos/20260615-repos-surface-github-v1`.
- Hito: `hitos/20260615-repos-surface-github-v1`.
- Cierre: la wave de repos surface queda cerrada como evidencia durable.

## Regla

Toda nueva entrega debe poder leerse como `fuente -> proceso -> salida -> hito -> cierre`.
