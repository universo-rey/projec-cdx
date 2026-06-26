# CDF Agent Teams

Status: `CDF_AGENT_TEAMS_SYNTHETIC_READY`

Runtime capability alignment: `CDF_AGENT_RUNTIME_CAPABILITY_ALIGNMENT_EXECUTABLE_DRY_RUN_READY_FOR_GATED_LIVE`

Runtime mode: `LOCAL_DOCUMENTAL_SYNTHETIC_RUNTIME_EXECUTABLE_DRY_RUN_NO_LIVE_ACTION`

CDF prepares teams of agents before live runtime. Each agent has instructions, guardrails, a scope of tools, handoffs and local eval cases.

The design follows the current OpenAI agent model: an agent needs instructions, guardrails and tools; more complex systems orchestrate multiple agents; evaluation and tracing come before production runtime.

## Team

Manifest: `04_AGENTS_SDK/teams/cdf_agent_team_manifest.json`.

Local router: `04_AGENTS_SDK/team_router.py`.

Synthetic evals: `04_AGENTS_SDK/evals/cases.jsonl`.

Run:

```powershell
python 04_AGENTS_SDK\evals\run_local.py
```

This local route does not call OpenAI API, Microsoft, SharePoint, Power Platform, Azure or external MCP.

## Runtime Capability Alignment

Gate: `CDF_GATE_68A_AGENT_RUNTIME_CAPABILITY_ALIGNMENT_NO_RUNTIME`

Next live gate: `CDF_GATE_68_TENANT_WIDE_ADMIN_AND_DATAVERSE_LIVE_APPLY`

The CDF runtime is prepared as a local/documentary synthetic runtime before Gate 68. It can read capability registries, select repo-local skills and recipes, prepare tool/plugin preflight, create agent orders, run a deterministic local dry-run and produce runtime readiness readbacks.

Topic derivation matrix:

`03_OPERACION/AGENT_RUNTIME_CAPABILITY_ALIGNMENT/CDF_AGENT_RUNTIME_TOPIC_DERIVATION_MATRIX.csv`

Every active topic is routed to a primary agent, supporting agents, sources, work library, gate requirement, blocked actions, expected output, reviewer, postcheck and next gate. This covers tenant/admin permissions, cabinas/extensions, SharePoint IA, site discovery, shared documents, Word, spreadsheets, formulas, PowerPoint, SGSD-TC, Dataverse/Power Apps, Power Automate, Teams/Planner/Outlook, OpenAI/RAG, adoption and evidence/readback.

Repo-wide matrix network:

`03_OPERACION/REPO_WIDE_STATE_RUNTIME_NORMALIZATION/CDF_REPO_WIDE_MATRIX_CONNECTION_GRAPH.csv`

Generated order matrix:

`03_OPERACION/REPO_WIDE_STATE_RUNTIME_NORMALIZATION/CDF_REPO_WIDE_AGENT_GENERATED_ORDER_MATRIX.csv`

Generated order deck:

`04_AGENTS_SDK/runtime/orders/gate69_matrix_activation_orders.json`

The repo-wide network connects artifact derivation, topic routing, agent activation, matrix graph, matrix edges, matrix groups and agent usage. The generated orders activate agents only in local/documentary mode. Microsoft live requires `MICROSOFT_LIVE_REQUIRES_EXPLICIT_AUTHORIZATION`; production requires `PRODUCTION_REQUIRES_EXPRESS_AUTHORIZATION`.

Dry-run:

```powershell
python 04_AGENTS_SDK\runtime\run_cdf_runtime_dry_run.py --check --out 08_EVIDENCIA\2026-05-27_CDF_AGENT_RUNTIME_CAPABILITY_ALIGNMENT\CDF_AGENT_RUNTIME_DRY_RUN_RESULT.json
```

It cannot execute tenant live work, Microsoft writes, Power Platform mutations, Dataverse table creation, Power Automate runs, OpenAI API fresh calls, production deployment or external MCP runtime without explicit gate authorization by surface and object.

Primary package:

`03_OPERACION/AGENT_RUNTIME_CAPABILITY_ALIGNMENT/`

## Mandatory Chain

Every CDF agent order must follow:

1. `cdf.project_manager_delegador`
2. `cdf.prompt_router`
3. assigned CDF agent
4. reviewers for evidence/postcheck, risk/boundary, canon/language and technical consistency

The chain is local and documentary by default. It does not promote any live runtime, Microsoft write, API call or production action without a separate gate.

## Agents

- `cdf.project_manager_delegador`: first filter for scope, gate, sources, assignment and reviewer chain.
- `cdf.prompt_router`: routes approved intake to the right CDF agent using manifest and boundary matrices.
- `cdf.connection_control_guard`: inventories and gates Microsoft, OpenAI, GitHub, MCP, PAC, PnP and connector surfaces.
- `cdf.local_cabina_extension_guard`: governs VS Code Insiders cabinas, extensions, MCP config and local tool surfaces.
- `cdf.solution_architect`: creates the architecture brief.
- `cdf.microsoft_graph_guard`: protects identity, Graph and permission boundaries.
- `cdf.sharepoint_information_architect`: designs document, metadata and view structure.
- `cdf.sharepoint_site_discovery_agent`: validates the exact SharePoint site, libraries and folders before work.
- `cdf.sharepoint_shared_doc_maintainer`: prepares status, roadmap and governance document maintenance.
- `cdf.sharepoint_word_doc_agent`: prepares Word document edits with structure and style preservation.
- `cdf.sharepoint_spreadsheet_agent`: prepares workbook analysis and safe spreadsheet changes.
- `cdf.sharepoint_formula_agent`: designs formula fixes and rollout checks for workbook work.
- `cdf.sharepoint_powerpoint_agent`: prepares deck edits with template fidelity controls.
- `cdf.sharepoint_sgsd_site_improvement_agent`: prepares improvements for the SGSD-TC site.
- `cdf.collaboration_operator`: designs Teams, Outlook and Planner operating loops.
- `cdf.rag_search_architect`: designs Azure AI Search and RAG shape with synthetic corpora.
- `cdf.adoption_coach`: prepares adoption and training handoffs.
- `cdf.evidence_validator`: checks evidence, gates and closure wording.

## SharePoint Specialization

Status: `CDF_SHAREPOINT_SPECIALIST_AGENTS_READY_FOR_SOPORTE_SDU_SITE_GATE`

CDF now carries a SharePoint specialist pod derived from the OpenAI SharePoint plugin skill surface:

- `sharepoint-site-discovery`;
- `sharepoint-shared-doc-maintenance`;
- `sharepoint-word-docs`;
- `sharepoint-spreadsheets`;
- `sharepoint-spreadsheet-formula-builder`;
- `sharepoint-powerpoint`;
- `sharepoint`.

Target site for the next gate:

`https://escribaniabitsch.sharepoint.com/sites/Soporte-Gobierno-Sistema-Declarativo-Torre-Control`

This specialization is preparation only. The first live gate must run read-only site discovery and inventory. Any page, navigation, metadata, library, permission or content write requires explicit human approval, rollback and postcheck.

## SharePoint Location

Status: `CDF_SHAREPOINT_AGENT_LOCATION_MAPPED_READONLY_NO_LIVE_WRITE`

All current CDF agents are mapped to the corporate Modo ON SharePoint site:

`https://modoe.sharepoint.com/sites/gestion`

Planned folder:

`Documentos compartidos/00_CORPORATIVO_MODO_ON/04_CELULAS_Y_ECOSISTEMA/CDF_SOLUCIONES/AGENTES`

The SharePoint-ready package lives in:

`00_STORY/sharepoint_package/cdf_soluciones/agentes/`

This package is not live-published yet. Publication requires `CDF_GATE_05_SHAREPOINT_AGENT_PLACEMENT_WRITE`.

## CDF_AGENT_VERSIONING_REPO_ONLY_ACTIVE_20260601

Gate 74 repo-only versioning adds 3_OPERACION/AGENT_VERSIONING with role, surface, responsibility, process, work papers, skills, recipes, tools, plugins, validator and readback for each CDF agent. Live Microsoft and production remain explicitly gated.
