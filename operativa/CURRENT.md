# Current

Estado actual del trabajo de `PROJEC CDX`.

## Activo

Cierre local de completitud del workbench `PROJEC CDX` y estado final de limpieza de la PC.

## Por Que Importa

`PROJEC CDX` ya no debe funcionar solo como archivo ordenado. Debe operar como mesa viva: cada frente visible tiene entrada, mapa y una pieza siguiente accionable.

## Cierre De Esta Ronda

- Inventario final de la PC guardado en `operativa/INVENTARIO_FINAL_PC_20260615.md`.
- Superficie de busqueda del usuario recortada: `DisableSearchBoxSuggestions`, `BingSearchEnabled`, `CortanaConsent` y `ShowSearchHighlights`.
- Servicios auxiliares deshabilitados: Adobe, AnyDesk, Google Updaters, HP, McAfee, PAD/UIFlow, WAPC, GlobalSecureAccess, OneDrive updater, Omen, Edge update.
- Borrado/paro de ruido visible: `SearchHost`, `msedgewebview2`, `WSearch` y `Spooler` quedaron fuera de la superficie activa de trabajo.
- Infraestructura base de Windows dejada intacta: `BrokerInfrastructure`, `DcomLaunch`, `PlugPlay`, `Power` y `SystemEventsBroker`.

- Raiz visible: `README.md`, `AGENTS.md`, `MAPA_MAESTRO.md`.
- Carriles normalizados: `atomic`, `docs`, `hitos`, `inventarios`, `operativa`, `outputs`, `packages`, `tools`, `workbooks`.
- Arranque de hilos: `operativa/START_HERE.md` y `operativa/PROMPT_NUEVO_HILO.md`.
- Entrada on-demand: `operativa/PROMPT_CIERRE_WAVE.md` y `operativa/ANCLAS_ON_DEMAND.md`.
- Receta reusable: `recipes/procedencia-layout-on-demand.md`.
- Complementos on-demand: `recipes/complementos-on-demand.md`.
- Agentes atomicos algoritmicos: `operativa/ANCLA_AGENTES_ATOMICOS_ALGORITMICOS.md`.
- Agentes atomicos algoritmicos en waves: `recipes/agentes-atomicos-algoritmicos-en-waves.md`.
- Cobertura atomica energetica: `operativa/COBERTURA_ATOMICA_ENERGETICA_20260615.md`.
- Playbooks: secuencia `00` a `06` completa.
- Validacion: `tools/validate_proj_cdx_workbench.ps1`.
- Workbook: `workbooks/control_operativo.xlsx` regenerado desde `operativa/` con hoja `Alertas`.
- Hito: `hitos/20260615-cierre-workbench-v1`.
- Proxima regla: todo nuevo trabajo entra primero por `operativa/NEXT.md`, valida con `playbooks/04-validar-delta.md` y cierra contra `operativa/TRACE.md`.

## Ultimo Delta Cerrado 19

- Guardar el inventario final de la PC y dejar el cierre local de limpieza documentado.
- Mantener la base de Windows intacta y solo recortar superficie auxiliar y de busqueda.
- Validacion local: `PASS`.
- Evidencia: `operativa/INVENTARIO_FINAL_PC_20260615.md`.

## Ultimo Delta Cerrado

- Levantar patrones reutilizables en `patrones/`.
- Levantar procesos ejecutables en `procesos/`.
- Versionar cierre en `hitos/20260615-patrones-procesos-v1`.
- Validador local: `PASS`.

## Ultimo Delta Cerrado 2

- Rehidratar Dataverse local y cruzarlo con sincronizacion tiempo real.
- Mantener el gate live cerrado.
- Validador sync: `PASS`.
- Hito: `hitos/20260615-sincronizacion-tiempo-real-v1`.

## Ultimo Delta Cerrado 3

- Trackear todo el hilo de origen en un hito padre versionado.
- Mantener intactos los hitos hijos y sus evidencias.
- Validacion local: `PASS`.
- Hito: `hitos/20260615-hilo-origen-v1`.

## Ultimo Delta Cerrado 4

- Convertir el workbook de Dataverse fronteras en un playbook corto.
- Declarar Dataverse como registro de bloqueos, decisiones y escaladas humanas.
- Derivar frontera a resolucion minima antes de cualquier live.
- Validacion local: PASS.
- Hito: `hitos/20260615-hilo-origen-v1` como indice padre donde queda absorbida la frontera.

## Ultimo Delta Cerrado 5

- Comparar `workbooks/inicio.xlsx` y `workbooks/tracker.xlsx` contra sus corridas generadas.
- `inicio.xlsx` queda identico a `outputs/inicio_workbook_20260613/excel_inicio.xlsx`.
- `tracker.xlsx` queda identico a `outputs/tracker_general_20260613/tracker.xlsx`.
- `tracker_workbook.xlsx` queda como variante distinta por diseño, no como espejo del fuente.
- Validacion local: PASS.
- Hito: `hitos/20260615-hilo-origen-v1`.

## Ultimo Delta Cerrado 6

- Versionar el bloque faltante de Dataverse: superficies de conexion, gates, evidencia y drift.
- Dejar el mapa corto de conexiones al frente sin convertir metadata en escritura live.
- Validacion local: PASS.
- Hito: `hitos/20260615-dataverse-conexiones-drift-v1`.

## Ultimo Delta Cerrado 7

- Diferenciar la corte ejecutora del roster SDU y de la cola de trabajo.
- Registrar la frontera en acta y en la traza corta.
- Validacion local: PASS.
- Hito: `hitos/20260615-corte-ejecutora-vs-sdu-v1`.

## Ultimo Delta Cerrado 8

- Incorporar `CodexLocal` como base local de lectura y `Documents/GitHub` como fuente canonica de repos.
- Incorporar `Auditar` como carpeta agregadora no Git con indice propio.
- Registrar acta de cierre de cadena y TODO visible.
- Validacion local: PASS.
- Hito: `hitos/20260615-cierre-cadena-github-auditar-v1`.

## Ultimo Delta Cerrado 9

- Incorporar `Auditar` como carpeta agregadora no Git con indice propio y mantenerla navegable.
- Conservar la cadena operativa sin abrir limpieza ni promocion por inferencia.
- Validacion local: PASS.
- Hito: `hitos/20260615-auditar-surface-chain-v1`.

## Ultimo Delta Cerrado 10

- Cerrar la cadena GitHub Auditar y dejar TODO visible en la ronda.
- Mantener `Documents/GitHub` como fuente canonica de repos y `Auditar` como superficie agregadora.
- Validacion local: PASS.
- Hito: `hitos/20260615-cierre-cadena-github-auditar-v1`.

## Ultimo Delta Cerrado 11

- Reclasificar amarillos historicos a verde gobernado.
- Sostener GitHub remote read-only sin write remoto.
- Validacion local: PASS.
- Hito: `hitos/20260615-semaforo-verde-historicos-v1`.

## Ultimo Delta Cerrado 12

- Abrir ordenes atomicas por PR para cierres reales de PRs abiertos.
- Dejar target, owner, rollback, postcheck y evidencia por cada orden.
- Validacion local: PASS.
- Hito: `hitos/20260615-pr-cierre-atomico-v1`.

## Ultimo Delta Cerrado 13

- Consolidar la superficie operativa por waves cortas.
- Mantener una sola energia util por tramo.
- Evidencia: `operativa/CONSOLIDACION_OPERATIVA_EN_WAVES_20260615.md`.
- Validacion local: PASS.
- Cierre: la wave nueva queda visible en `operativa` sin abrir frentes paralelos.

## Ultimo Delta Cerrado 14

- Cerrar el archivo de ramas historicas con su matriz Excel compañera.
- Absorber la wave en un hito versionado propio.
- Validacion local: PASS.
- Hito: `hitos/20260615-archivo-ramas-historicas-v1`.

## Ultimo Delta Cerrado 15

- Formalizar la receta reusable para procedencia, layout y anclas on-demand.
- Separar procedencia tecnica de lectura visible sin confundirla con habilitacion live.
- Validacion local: PASS.
- Hito: `hitos/20260615-procedencia-layout-on-demand-v1`.

## Ultimo Delta Cerrado 16

- Abrir acceso on-demand a complementos, plugins y MCP directos sin inventar disponibilidad.
- Separar `MCP directo` de `plugin activo` y marcar `NO_DISPONIBLE` si falta la capacidad.
- Validacion local: PASS.
- Hito: `hitos/20260615-complementos-on-demand-v1`.

## Ultimo Delta Cerrado 17

- Abrir una ancla para agentes atomicos algoritmicos y empaquetarlos en waves cortas.
- Delegar con scope minimo, retorno exacto y fan-in claro.
- Validacion local: PASS.
- Hito: `hitos/20260615-agentes-atomicos-algoritmicos-en-waves-v1`.

## Ultimo Delta Cerrado 18

- Introducir el elemento atomico energetico como contrato visible para superficies gobernadas.
- Declarar fase, impulso y stop condition desde la primera entrada visible minima.
- Validacion local: PASS.
- Hito: `hitos/20260615-cobertura-atomica-energetica-v1`.

## Ultimo Delta Cerrado 19

- Guardar el inventario final de la PC y dejar el cierre local de limpieza documentado.
- Mantener la base de Windows intacta y solo recortar superficie auxiliar y de busqueda.
- Validacion local: PASS.
- Evidencia: `operativa/INVENTARIO_FINAL_PC_20260615.md`.

## Ultimo Delta Cerrado 20

- Convertir la limpieza local de PC en skill, receta, proceso y registro local de Dataverse.
- Mantener el carril local-only y no abrir live write.
- Validacion local: PASS.
- Evidencia: `recipes/limpieza-pc-local-segura.md`, `procesos/limpieza-pc-local-segura.md`, `dataverse/REGISTRO_LIMPIEZA_PC_LOCAL_20260615.md`.

## Ultimo Delta Cerrado 21

- Convertir `.codex` y `.agents` en repos Git publicados y limpios.
- Mantener los nombres remotos por ahora: `codex-root` y `agents-root`.
- Siguiente superficie candidata: segunda pasada de Dataverse.
- Evidencia: `operativa/ACTA_REPOS_SURFACE_GITHUB_20260615.md`.

## Ultimo Delta Cerrado 22

- Cerrar la segunda pasada de Dataverse en el workbook de control y en el validador.
- Agregar estados Dataverse, ambiente, target exacto, gate live y postcheck a la mesa viva.
- Validacion: PASS.
- Evidencia: `operativa/ACTA_DATAVERSE_SEGUNDA_PASADA_20260615.md`.

## Ultimo Delta Cerrado 23

- Versionar la segunda pasada de Dataverse en un hito propio.
- Mantener el carril gobernado sin live write por inferencia.
- Evidencia: `hitos/20260615-projec-cdx-dataverse-v1`.

## Ultimo Delta Cerrado 24

- Versionar el scaffold completo de Codex Cloud, incluyendo entorno UI seleccionable y runner Python.
- Mantener el gate en `metadata-only` y el humo local verificable.
- Evidencia: `hitos/20260615-codex-cloud-scaffold-v1`.

## Ultimo Delta Cerrado 25

- Ajustar la politica de ramas y versionado para absorber el scaffold de Codex Cloud.
- Mantener el scaffold separado del live y versionado como hito local propio.
- Evidencia: `hitos/20260615-politica-ramas-versionado-v1`.

## Ultimo Delta Cerrado 26

- Versionar la acta local de repos surface GitHub como hito propio.
- Mantener `codex-root` y `agents-root` sin renombre por ahora.
- Evidencia: `hitos/20260615-repos-surface-github-v1`.

## Regla

Toda nueva entrega debe poder leerse como `fuente -> proceso -> salida -> hito -> cierre`.
