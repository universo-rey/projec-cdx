# READBACK_RELEVAMIENTO_MAQUINA_PRECHECK_20260619

## Estado
PRECHECK_COMPLETO_SIN_LIMPIEZA

## Maquina Viva
- Equipo: `HP Laptop 15-fc0xxx`.
- Fabricante: `HP`.
- CPU: `AMD Ryzen 7 7730U with Radeon Graphics`.
- RAM fisica: aproximadamente `7.34 GB`.
- Windows: `Microsoft Windows 11 Home Insider Preview Single Language`.
- Build: `26300`.
- Ultimo arranque: `2026-06-19 15:21:02 -03:00`.
- Usuario: `CEO\enzo1`.
- Elevacion actual: `false`.

## Discos
- Disco fisico: `SAMSUNG MZVL8512HELU-00BH1`, `512 GB`, estado `OK`.
- Volumen logico visible: `C:`.
- Espacio libre en `C:`: aproximadamente `189 GB`.
- `D:\`: no visible / no montado en esta lectura.

## Cabina Y Perfil
- `C:\CEO` esta activo como hub de gobierno.
- `C:\CEO\project-cdx` es junction a `C:\Users\enzo1\PROJEC CDX`.
- Carpetas shell del usuario apuntan a `C:\CEO\Desktop`, `C:\CEO\Documents`, `C:\CEO\Downloads`, `C:\CEO\Pictures`, `C:\CEO\Music` y `C:\CEO\Videos`.
- Variables `CEO_*`, `CODEX_*` y `SOURCE_TREE_PATH` estan persistidas en ambito `User`.

## Repos Y Capas
- `C:\CEO\repos`: existe, vacio.
- `C:\CEO\worktrees`: existe, vacio.
- `C:\CEO\agents`: existe, vacio.
- `C:\CEO\skills`: existe, vacio.
- `C:\CEO\chains`: existe, vacio.
- `C:\CEO\m365`: existe, vacio.
- `C:\CEO\dataverse`: existe, vacio.
- Repos reales detectados en `C:\Users\enzo1\Documents\GitHub`: `17` repos Git directos.
- Repos con cambios detectados: `cabina-universal-d`, `seshat-bootstrap-sdu-cn`, `Sgin`.
- Worktrees `Sgin__wt_*`: presentes como carpetas Git sin rama/origin directo visible en esta lectura.

## Procesos Y Startup
- Evidencia generada: `C:\Users\enzo1\CodexLocal\OPTIMIZACION_PC\OPT_PC_SKILL_20260619_195202`.
- Modo ejecutado: `MatrixOnly`.
- No se borro nada.
- No se desactivo nada.
- Temporales usuario: aproximadamente `387 MB`.
- Startup rows: `7`.
- Process rows: `252`.
- Procesos pesados observados: `MsMpEng`, `Memory Compression`, `msedge`, `Codex`, `msedgewebview2`, `pwsh`.
- Startup candidatos a decision, no ejecucion: `HPSEU_Host_Launcher`, `MicrosoftEdgeAutoLaunch_*`.

## Tools
- `git`: presente.
- `pwsh`: `7.6.2`.
- `node`: `v24.14.0`.
- `npm`: `11.9.0`.
- `pac`: `2.8.1`.
- `az`: presente.
- `python`: alias de Microsoft Store, no runtime real confirmado.
- `py`: no presente.
- `rg`: no presente.
- `gh`: no presente.
- `code`: no presente.

## Que Necesitamos Relevar En La Wave
1. `MATRIZ_SISTEMA.csv`: host, Windows, BIOS, CPU, RAM, arranque, elevacion.
2. `MATRIZ_DISCOVERY_DISCOS.csv`: volumenes, particiones, espacio, ausencia/presencia de `D:\`.
3. `MATRIZ_PERFIL_CEO.csv`: shell folders, junctions, variables, terminal, perfiles PowerShell.
4. `MATRIZ_REPOS_WORKTREES.csv`: repos reales, ramas, dirty state, origins, worktrees y destino canonico.
5. `MATRIZ_CAPAS_CEO.csv`: `repos`, `worktrees`, `agents`, `skills`, `chains`, `m365`, `dataverse`, `runtime`, `tools`.
6. `MATRIZ_PROCESOS.csv`: procesos pesados, clasificacion, riesgo y gate de cierre.
7. `MATRIZ_STARTUP.csv`: startup protegido, candidato y bloqueado.
8. `MATRIZ_CARPETAS_PESADAS.csv`: tamanios recursivos controlados, excluyendo rutas protegidas.
9. `MATRIZ_TOOLS_RUNTIMES.csv`: herramientas reales vs alias, versiones y rutas.
10. `RIESGOS_Y_BLOQUEOS.md`: superficies protegidas, decisiones humanas y stop conditions.

## Superficies Protegidas
- No tocar Defender, Windows Update, servicios, drivers ni Registro por inferencia.
- No tocar OneDrive, Google Drive, SharePoint, Power Platform ni sincronizadores.
- No borrar repos, `.git`, `node_modules`, navegadores, credenciales ni tokens.
- No cerrar procesos con trabajo abierto.
- No mover `Documents\GitHub` hacia `C:\CEO\repos` sin matriz de migracion y gate exacto.

## Deltas Detectados
- `D:\` no esta montado.
- `C:\CEO\repos` y `C:\CEO\worktrees` existen pero no contienen los repos reales.
- Python no esta operativo como runtime local general; lo visible es alias de Microsoft Store.
- Faltan `rg`, `gh` y `code` en PATH para relevamientos mas rapidos y operaciones GitHub/editor.
- Hay varios procesos Codex/Edge activos; no cerrar sin gate por nombre/proceso.

## Proximo Gate Unico
Ejecutar wave de inventario completo, metadata-only, sin limpieza:

`RELEVAMIENTO_MAQUINA_WAVE_01_MATRIX_ONLY`

Salida esperada:
- carpeta de evidencia unica;
- matrices CSV;
- readback ejecutivo;
- lista de decisiones humanas;
- cero limpiezas;
- cero cambios en startup;
- cero cierres de procesos.

## Stop Condition
- Aparece `D:\` con contenido no mapeado.
- El scan recursivo entra en nube, repos, `.git`, `node_modules`, navegadores o credenciales.
- Una matriz propone ejecutar accion sin owner, rollback y postcheck.
- Se requiere elevacion para lectura que no sea imprescindible.
