---
artifact_id: operativa/MATRIZ_REPOS_GIT_MAIN_ONLY_20260615.md
categoria: operativa
tipo: matriz
estado: en_revision
version: 2026.06.21
autoridad:
  tipo: owner
  referencia: '@SeshatSgin'
origen: GitHub
ubicacion_repo: operativa/MATRIZ_REPOS_GIT_MAIN_ONLY_20260615.md
etiquetas:
- operativa
- matriz
- metadata
relacionados:
- operativa/MAPA.md
descripcion: Matriz de repositorios restringidos a main con trazabilidad parcial.
fecha_evento: '2026-06-15'
---

# Matriz Repos Git Main Only 20260615

## Estado

- Fecha: 2026-06-15
- Alcance: matriz por repo de la wave de cierre Git
- Resultado: `MATRIZ_REPOS_GIT_MAIN_ONLY`
- Repos confirmados: `13`
- Companero filtrable: `MATRIZ_REPOS_GIT_MAIN_ONLY_20260615.csv`
- Companero workbook: `MATRIZ_REPOS_GIT_MAIN_ONLY_20260615.xlsx`

## Contrato

- `agente`: `repo.governance_registrar`
- `orden`: `Confirmar 13 repos, dejar solo main, archivar ramas historicas y resolver desvio unico`
- `superficie`: `C:/Users/enzo1/Documents/GitHub`
- `skill`: `repo-agent-tool-governance`
- `receta`: `repo_agent_tool_governance`
- `tool`: `git`, `validate_proj_cdx_workbench.ps1`
- `evidencia`: `operativa/ACTA_CIERRE_REPOS_GIT_MAIN_ONLY_20260615.md`
- `validador`: `PASS`
- `riesgo`: `bajo`
- `rollback`: `volver a la rama historica o revertir el push de la resolucion si se ordena`
- `stop_condition`: `no borrar ramas ni tocar remotos sin orden atomica explicita`
- `proximos_carriles`: `archivo de ramas historicas o nueva wave documental`

## Matriz

| Repo | Ruta | Rama | Estado | Motivo | Accion sugerida |
| --- | --- | --- | --- | --- | --- |
| cabina-universal-d | `C:/Users/enzo1/Documents/GitHub/cabina-universal-d` | `main` | clean | repo canonico, ramas laterales historicas ya identificadas | mantener `main` y conservar ramas historicas como archivo |
| cdf-soluciones | `C:/Users/enzo1/Documents/GitHub/cdf-soluciones` | `main` | clean | repo canonico ya alineado | mantener `main` sin cambios |
| jara-consultores | `C:/Users/enzo1/Documents/GitHub/jara-consultores` | `main` | clean | repo canonico ya alineado | mantener `main` sin cambios |
| microsoft-agents-governed-lab | `C:/Users/enzo1/Documents/GitHub/microsoft-agents-governed-lab` | `main` | clean | repo canonico ya alineado | mantener `main` sin cambios |
| modo-on-foundation | `C:/Users/enzo1/Documents/GitHub/modo-on-foundation` | `main` | clean | repo canonico ya alineado | mantener `main` sin cambios |
| organizacion | `C:/Users/enzo1/Documents/GitHub/organizacion` | `main` | clean | resuelto desde `codex/service-design-documental-20260605` y publicado en `origin/main` | mantener `main` y archivar la rama historica |
| sdu-canon | `C:/Users/enzo1/Documents/GitHub/sdu-canon` | `main` | clean | repo canonico ya alineado | mantener `main` sin cambios |
| seshat-bootstrap-sdu-cn | `C:/Users/enzo1/Documents/GitHub/seshat-bootstrap-sdu-cn` | `main` | clean | repo canonico ya alineado | mantener `main` sin cambios |
| Sgin | `C:/Users/enzo1/Documents/GitHub/Sgin` | `main` | clean | repo canonico ya alineado | mantener `main` sin cambios |
| sgin-cumplimiento | `C:/Users/enzo1/Documents/GitHub/sgin-cumplimiento` | `main` | clean | repo canonico ya alineado | mantener `main` sin cambios |
| tcu-agentic-runtime-control | `C:/Users/enzo1/Documents/GitHub/tcu-agentic-runtime-control` | `main` | clean | repo canonico ya alineado | mantener `main` sin cambios |
| tge-agentic-runtime-control-escribania | `C:/Users/enzo1/Documents/GitHub/tge-agentic-runtime-control-escribania` | `main` | clean | repo canonico ya alineado | mantener `main` sin cambios |
| torre-gemela-escribania | `C:/Users/enzo1/Documents/GitHub/torre-gemela-escribania` | `main` | clean | repo canonico ya alineado | mantener `main` sin cambios |

## Lectura

- Todos los repos Git confirmados quedaron en `main` y `clean`.
- El unico desvio real ya fue resuelto en `organizacion`.
- Las ramas historicas no se borran; solo quedan registradas para archivo.
