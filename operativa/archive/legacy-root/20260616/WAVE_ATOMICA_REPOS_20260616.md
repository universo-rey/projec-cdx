# Wave Atomica de Repositorios 20260616

## Estado

`PREPARADA_Y_PARTIDA_EN_LANES`

## Avance

- Lane A: fan-in cerrado en los tres repos base.
- Lane B: fan-in cerrado en runtime/agents.
- Lane C: microatom `jara-consultores` preparado como siguiente eslabon.

## Objetivo

Dividir la wave de repositorios canonicos en lanes disjuntos para que cada agente deje un atomico reutilizable sin mezclar scopes ni fan-in.

## Fuente Canonica

- [Matriz Repos Git Main Only 20260615](C:/Users/enzo1/PROJEC%20CDX/operativa/archive/legacy-root/20260615/MATRIZ_REPOS_GIT_MAIN_ONLY_20260615.md)
- [Ancla Agentes Atomicos Algoritmicos](C:/Users/enzo1/PROJEC%20CDX/operativa/archive/legacy-root/undated/ANCLA_AGENTES_ATOMICOS_ALGORITMICOS.md)
- [Receta agentes atomicos algoritmicos en waves](C:/Users/enzo1/PROJEC%20CDX/recipes/agentes-atomicos-algoritmicos-en-waves.md)
- [Proceso agentes atomicos algoritmicos en waves](C:/Users/enzo1/PROJEC%20CDX/procesos/agentes-atomicos-algoritmicos-en-waves.md)

## Contrato Comun

- `lead_agent`: `repo.wave_lead`
- `owner_agent`: `repo.wave_owner`
- `reviewer_agent`: `repo.wave_reviewer`
- `skill`: `parallel-order-governance`, `repo-agent-tool-governance`, `dispatching-parallel-agents`
- `receta`: `agentes-atomicos-algoritmicos-en-waves`
- `tool`: `git`, `rg`, `Get-Content`, `Test-Path`, `apply_patch`
- `validator`: `tools/validate_proj_cdx_workbench.ps1`
- `rollback`: `volver al README o al indice anterior del wave packet`
- `stop_condition`: `lane_scope_overlap`, `no_evidence`, `no_validator`, `fan_in_missing`

## Lanes

| Lane | Scope | Repos | Owner | Reviewer | Lock Key | Evidence |
| --- | --- | --- | --- | --- | --- | --- |
| Lane A | Foundation / control | `cabina-universal-d`, `sdu-canon`, `seshat-bootstrap-sdu-cn` | `repo.foundation_owner` | `repo.foundation_reviewer` | `lane-a-foundation` | `operativa/TRACE.md`, lane readback |
| Lane B | Runtime / agents | `microsoft-agents-governed-lab`, `tcu-agentic-runtime-control`, `tge-agentic-runtime-control-escribania`, `torre-gemela-escribania` | `repo.runtime_owner` | `repo.runtime_reviewer` | `lane-b-runtime` | `operativa/TRACE.md`, lane readback |
| Lane C | Documentary / business canon | `cdf-soluciones`, `jara-consultores`, `modo-on-foundation`, `organizacion`, `Sgin`, `sgin-cumplimiento` | `repo.documental_owner` | `repo.documental_reviewer` | `lane-c-documental` | `operativa/TRACE.md`, lane readback |

## Orden De Ejecucion

1. Ejecutar lane A.
2. Ejecutar lane B.
3. Ejecutar lane C.
4. Integrar solo por fan-in documental.

## Retorno Esperado Por Lane

- `repo`
- `lane`
- `scope`
- `evidence`
- `validator`
- `rollback`
- `fan_in`

## Postcheck

- Cada lane queda legible por separado.
- Ningun repo cambia de lane a mitad de entrega.
- `TRACE.md` solo recibe fan-in cuando la lane cierra.

## Fan In Lane A

- `repo`: `cabina-universal-d`
- `lane`: `Lane A / Foundation / control`
- `scope`: `ancla de lectura y control para la wave atomica`
- `evidence`: `operativa/TRACE.md`, `02_AUTHORITY_CANON/CURRENT_STATE.md`
- `validator`: `tools/validate_proj_cdx_workbench.ps1`, `tools/validate_proj_cdx_sync.ps1`
- `rollback`: `volver al packet anterior si la lane perdia exactitud`
- `fan_in`: `cerrado`

## Fan In Lane B

- `repo`: `microsoft-agents-governed-lab`
- `lane`: `Lane B / Runtime / agents`
- `scope`: `hub de Agents SDK y patrones de ejecucion`
- `evidence`: `README.md`, `operativa/TRACE.md`
- `validator`: `tools/validate_proj_cdx_workbench.ps1`, `tools/validate_proj_cdx_sync.ps1`
- `rollback`: `volver al packet anterior si la lane perdia exactitud`
- `fan_in`: `cerrado`

- `repo`: `tcu-agentic-runtime-control`
- `lane`: `Lane B / Runtime / agents`
- `scope`: `patron rector para runtime agentico no sensible`
- `evidence`: `README.md`, `operativa/TRACE.md`
- `validator`: `tools/validate_proj_cdx_workbench.ps1`, `tools/validate_proj_cdx_sync.ps1`
- `rollback`: `volver al packet anterior si la lane perdia exactitud`
- `fan_in`: `cerrado`

- `repo`: `tge-agentic-runtime-control-escribania`
- `lane`: `Lane B / Runtime / agents`
- `scope`: `espejo runtime adaptado a Escribania`
- `evidence`: `README.md`, `operativa/TRACE.md`
- `validator`: `tools/validate_proj_cdx_workbench.ps1`, `tools/validate_proj_cdx_sync.ps1`
- `rollback`: `volver al packet anterior si la lane perdia exactitud`
- `fan_in`: `cerrado`

- `repo`: `torre-gemela-escribania`
- `lane`: `Lane B / Runtime / agents`
- `scope`: `torre de control regulada`
- `evidence`: `README.md`, `operativa/TRACE.md`
- `validator`: `tools/validate_proj_cdx_workbench.ps1`, `tools/validate_proj_cdx_sync.ps1`
- `rollback`: `volver al packet anterior si la lane perdia exactitud`
- `fan_in`: `cerrado`

- `repo`: `sdu-canon`
- `lane`: `Lane A / Foundation / control`
- `scope`: `canon madre de contexto para la wave atomica`
- `evidence`: `operativa/TRACE.md`, `00_CONTEXT/CURRENT_STATE.md`
- `validator`: `tools/validate_proj_cdx_workbench.ps1`, `tools/validate_proj_cdx_sync.ps1`
- `rollback`: `volver al packet anterior si la lane perdia exactitud`
- `fan_in`: `cerrado`

- `repo`: `seshat-bootstrap-sdu-cn`
- `lane`: `Lane A / Foundation / control`
- `scope`: `seed documental/bootstrap de la wave atomica`
- `evidence`: `operativa/TRACE.md`, `README.md`
- `validator`: `tools/validate_proj_cdx_workbench.ps1`, `tools/validate_proj_cdx_sync.ps1`
- `rollback`: `volver al packet anterior si la lane perdia exactitud`
- `fan_in`: `cerrado`

## Fan In Lane C

- `repo`: `cdf-soluciones`
- `lane`: `Lane C / Documentary / business canon`
- `scope`: `arquitectura y delivery tecnico como canon documental de la wave`
- `evidence`: `README.md`, `operativa/TRACE.md`
- `validator`: `tools/validate_proj_cdx_workbench.ps1`, `tools/validate_proj_cdx_sync.ps1`
- `rollback`: `volver al packet anterior si la lane perdia exactitud`
- `fan_in`: `cerrado`

- `repo`: `jara-consultores`
- `lane`: `Lane C / Documentary / business canon`
- `scope`: `consultoria documental y diagnostico acompanado`
- `evidence`: `README.md`, `operativa/TRACE.md`
- `validator`: `tools/validate_proj_cdx_workbench.ps1`, `tools/validate_proj_cdx_sync.ps1`
- `rollback`: `volver al packet anterior si la lane perdia exactitud`
- `fan_in`: `cerrado`

- `repo`: `modo-on-foundation`
- `lane`: `Lane C / Documentary / business canon`
- `scope`: `foundation documental del ecosistema Modo ON`
- `evidence`: `README.md`, `operativa/TRACE.md`
- `validator`: `tools/validate_proj_cdx_workbench.ps1`, `tools/validate_proj_cdx_sync.ps1`
- `rollback`: `volver al packet anterior si la lane perdia exactitud`
- `fan_in`: `cerrado`

- `repo`: `organizacion`
- `lane`: `Lane C / Documentary / business canon`
- `scope`: `controlplane operativo y taxonomia organizacional`
- `evidence`: `README.md`, `operativa/TRACE.md`
- `validator`: `tools/validate_proj_cdx_workbench.ps1`, `tools/validate_proj_cdx_sync.ps1`
- `rollback`: `volver al packet anterior si la lane perdia exactitud`
- `fan_in`: `cerrado`

- `repo`: `Sgin`
- `lane`: `Lane C / Documentary / business canon`
- `scope`: `especificacion viva de SGIN`
- `evidence`: `README.md`, `operativa/TRACE.md`
- `validator`: `tools/validate_proj_cdx_workbench.ps1`, `tools/validate_proj_cdx_sync.ps1`
- `rollback`: `volver al packet anterior si la lane perdia exactitud`
- `fan_in`: `cerrado`

- `repo`: `sgin-cumplimiento`
- `lane`: `Lane C / Documentary / business canon`
- `scope`: `cumplimiento y normalizacion documental`
- `evidence`: `README.md`, `operativa/TRACE.md`
- `validator`: `tools/validate_proj_cdx_workbench.ps1`, `tools/validate_proj_cdx_sync.ps1`
- `rollback`: `volver al packet anterior si la lane perdia exactitud`
- `fan_in`: `cerrado`

## Lane C Microatom Organizacion

- `repo`: `organizacion`
- `lane`: `Lane C / Documentary / business canon`
- `scope`: `controlplane operativo y taxonomia organizacional`
- `evidence`: `C:/Users/enzo1/Documents/GitHub/organizacion/README.md`, `C:/Users/enzo1/Documents/GitHub/organizacion/AGENTS.md`
- `validator`: `tools/validate_proj_cdx_workbench.ps1`, `tools/validate_proj_cdx_sync.ps1`
- `rollback`: `volver al packet anterior si la lane perdia exactitud`
- `fan_in`: `preparado`

## Lane C Microatom Cdf Soluciones

- `repo`: `cdf-soluciones`
- `lane`: `Lane C / Documentary / business canon`
- `scope`: `arquitectura y delivery tecnico como canon documental de la wave`
- `evidence`: `C:/Users/enzo1/Documents/GitHub/cdf-soluciones/README.md`, `C:/Users/enzo1/Documents/GitHub/cdf-soluciones/AGENTS.md`
- `validator`: `tools/validate_proj_cdx_workbench.ps1`, `tools/validate_proj_cdx_sync.ps1`
- `rollback`: `volver al packet anterior si la lane perdia exactitud`
- `fan_in`: `preparado`

## Lane C Microatom Jara Consultores

- `repo`: `jara-consultores`
- `lane`: `Lane C / Documentary / business canon`
- `scope`: `consultoria documental y diagnostico acompanado`
- `evidence`: `C:/Users/enzo1/Documents/GitHub/jara-consultores/README.md`, `C:/Users/enzo1/Documents/GitHub/jara-consultores/AGENTS.md`
- `validator`: `tools/validate_proj_cdx_workbench.ps1`, `tools/validate_proj_cdx_sync.ps1`
- `rollback`: `volver al packet anterior si la lane perdia exactitud`
- `fan_in`: `preparado`

## Nota

Este packet no abre escritura en los repos destino. Solo deja la wave partida y deja cerrados los fan-in de Lane A, Lane B y Lane C, con `organizacion`, `cdf-soluciones` y `jara-consultores` como microatoms visibles de Lane C.
