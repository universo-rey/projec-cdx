# Registro de hitos del hilo anterior

Version: `v1`
Fecha: `2026-06-14`
Raiz: `C:\Users\enzo1\PROJEC CDX`

## Hitos

### Alineacion inicial

1. Se definio continuar desde el handoff del hilo pesado.
2. Se fijo como primer control `codex-control-total.ps1`.
3. Se mantuvo la regla de no leer secretos.
4. Se mantuvo la regla de no tocar `auth.json`.
5. Se mantuvo la regla de no tocar `cap_sid`.
6. Se mantuvo la regla de no editar `global-state` sin orden explicita.
7. Se mantuvo la regla de no editar SQLite sin orden explicita.
8. Se fijo que cualquier cambio en repo requiere rama o artefacto separado.

### Canon y entorno

9. Se leyo el canon global de Codex.
10. Se leyo el mapa corto de entorno.
11. Se leyo el handoff `HANDOFF_THREAD_HEAVY_20260614.md` dentro del paquete versionado del hilo.
12. Se verifico que la superficie activa era `C:\Users\enzo1\PROJEC CDX`.
13. Se separo el estado historico del estado vivo.

### PowerShell y runtime local

14. Se valido `integratedTerminalShell = "pwsh"`.
15. Se valido `pwsh` en PowerShell 7.6.2.
16. Se valido el perfil Codex con `LAYOUT_OK`.
17. Se dejo documentada la opcion de rollback a `powershell` si `pwsh` fallara.

### Control total

18. Se creo o confirmo `tools\codex-control-total.ps1`.
19. Se ejecuto el control total rapido.
20. Resultado original: 15 verdes, 6 guardrails, 0 rojos.
21. Checks: `21`.
22. Verdes: `15`.
23. Amarillos: `6`.
24. Rojos: `0`.
25. Se clasifico el estado como continuidad habilitada con observaciones.

### Amarillos

26. Se marco el backup raiz de `global-state` como amarillo.
27. Se decidio comparar generaciones antes de mover ese backup.
28. Se identificaron repos limpios en `main`.
29. Se trato `main` como rama protegida.
30. Se fijo crear rama antes de cambios en repos.

### Codex root

31. Se genero o confirmo `CODEX_ROOT_INVENTORY.csv`.
32. El inventario clasifico `74` filas.
33. Se genero o confirmo `CODEX_ROOT_MOVE_PLAN.json`.
34. El plan dejo `move_safe` vacio.
35. El plan dejo `auth.json` como `blocked_review`.
36. El plan dejo `cap_sid` como `blocked_review`.
37. El plan dejo `.codex-global-state.json.bak` como `blocked_review`.
38. Se genero o confirmo `CODEX_ROOT_MOVE_RESULTS.json`.
39. Se registraron `118` movimientos con `status=DONE`.
40. Se registraron `85` movimientos hacia `backups`.
41. Se registraron `22` movimientos hacia `workpapers`.
42. Se registraron `9` movimientos hacia `tmp`.
43. Se registraron `2` movimientos hacia `log`.
44. Se ordenaron temporales de `global-state` bajo `tmp\global-state`.
45. Se ordenaron backups de `global-state` bajo `backups\global-state`.
46. Se ordenaron backups SQLite bajo `backups\sqlite`.
47. Se ordenaron backups de configuracion bajo `backups\config`.
48. Se ordenaron backups de `AGENTS.md` bajo `backups\agents`.
49. Se ordenaron scripts y logs historicos bajo `workpapers\maintenance`.
50. Se ordenaron logs de sandbox bajo `log\sandbox`.

### Outputs

51. Se confirmo `outputs\README.md` como entrada corta de salidas.
52. Se confirmo `outputs\MAPA.md` como mapa unico de corridas.
53. Se registro `cabina_relationship_audit_20260614`.
54. Se registro `workbook_base_20260613`.
55. Se registro `tracker_general_20260613`.
56. Se registro `tracker_workbook_20260613`.
57. Se registro `inicio_workbook_20260613`.
58. Se registro `dataverse_blocker_frontier_20260614`.

### Cabina

59. Se genero auditoria ejecutiva de relaciones de `cabina-universal-d`.
60. Se genero auditoria profunda de relaciones de `cabina-universal-d`.
61. Se dejaron salidas en `.xlsx`, `.md` y `.csv`.
62. Se identificaron nodos de governance, reference, docs, folders e inventories.

### Workbooks

63. Se genero `workbook_base.xlsx`.
64. Se genero `tracker.xlsx`.
65. Se genero `tracker_workbook.xlsx`.
66. Se genero `excel_inicio.xlsx`.
67. Se dejaron scripts de generacion por corrida.
68. Se dejaron capturas `.png` por corrida.
69. Se dejaron inspecciones `.ndjson` por corrida.
70. Se dejaron `formula_errors.ndjson` como control de formulas.

### Dataverse frontier

71. Se genero `dataverse_blocker_frontier.xlsx`.
72. Se registraron `12` fronteras.
73. Se confirmo que la frontera dominante es humana/gate: identidad, approvals, live writes y target exacto.

## Cierre

Semaforo cierre posterior: `GREEN_ARCHIVED`.
Bloqueos rojos: `0`.
Proximo movimiento unico: abrir rama o artefacto separado antes de cambios sobre repos.
