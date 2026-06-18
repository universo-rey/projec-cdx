# Tabla unica de skills

Mapa unico de skills activas de `.codex` y `.agents` con raiz real, carril/familia y notas de drift.

## Criterio
- `Canonical` = nombre visible en el `SKILL.md` o manifesto de plugin.
- `Alias` = carpeta o nombre alternativo cuando hay drift.
- `RootLabel` = raiz efectiva donde vive la capacidad.
- `Kind` = `skill` o `plugin`.

## Resumen
| Root | Count |
| --- | ---: |
| .agents/plugins | 1 |
| .agents/skills | 25 |
| .codex/skills | 75 |

## .agents/plugins

### Plugins
| Canonical | Alias / drift | Purpose | Notes |
| --- | --- | --- | --- |
| operativa-guardian |  | Productivity plugin disponible via marketplace.json; instalación AVAILABLE, auth ON_INSTALL. | marketplace.json -> ./.codex/plugins/operativa-guardian |

## .agents/skills

### Descubrimiento / planificacion / subagentes
| Canonical | Alias / drift | Purpose | Notes |
| --- | --- | --- | --- |
| tcu-desarrollo-con-subagentes | subagent-driven-development | Use when executing implementation plans with independent tasks in the current session | alias de archivo: subagent-driven-development |
| tcu-descubridor-capacidades | find-skills | Helps users discover and install agent skills when they ask questions like "how do I do X", "find a skill for X", "is there a skill that can...", or express interest in extending capabilities. This skill should be used when the user is looking for functionality that might exist as an installable skill. | alias de archivo: find-skills |
| tcu-despacho-agentes-paralelos | dispatching-parallel-agents | Use when facing 2+ independent tasks that can be worked on without shared state or sequential dependencies | alias de archivo: dispatching-parallel-agents |
| tcu-planificador-con-archivos | planning-with-files | Implements Manus-style file-based planning to organize and track progress on complex tasks. Creates task_plan.md, findings.md, and progress.md. Use when asked to plan out, break down, or organize a multi-step project, research task, or any work requiring 5+ tool calls. Supports automatic session recovery after /clear. | alias de archivo: planning-with-files |
| tcu-redactor-planes-operativos | writing-plans | Use when you have a spec or requirements for a multi-step task, before touching code | alias de archivo: writing-plans |

### REY-MODO / gobierno
| Canonical | Alias / drift | Purpose | Notes |
| --- | --- | --- | --- |
| rey-modo-auditor-flujos-cola | rey-modo-flow-workqueue-auditor | Audita Power Platform, solucion ModoOn_UniversoDeclarativo_Flows y familia WorkQueue v03 sin crear ni activar flows. | alias de archivo: rey-modo-flow-workqueue-auditor |
| rey-modo-auditor-sharepoint-seguro | rey-modo-sharepoint-safety-auditor | Ejecuta inventario SharePoint read-only y prepara writes gateados con rollback sin tocar permisos ni InternalName. | alias de archivo: rey-modo-sharepoint-safety-auditor |
| rey-modo-auditor-taxonomia-contenttypes | rey-modo-taxonomy-contenttype-auditor | Audita metadata, taxonomia, value sets y content types de Rey Modo separando real, propuesta, NO_CONSTA y gate. | alias de archivo: rey-modo-taxonomy-contenttype-auditor |
| rey-modo-auditor-vscode-insiders | rey-modo-vscode-insiders-auditor | Audita la cabina VS Code Insiders, settings no destructivos, carpetas, exclusiones y relacion con Codex Local. | alias de archivo: rey-modo-vscode-insiders-auditor |
| rey-modo-carril-codex-cloud-api | rey-modo-codex-routing | Decide Codex Local vs Codex Cloud vs OpenAI API segun sensibilidad, tenant, gate y tipo de artefacto. | alias de archivo: rey-modo-codex-routing |
| rey-modo-evidencia-riesgo-handoff | rey-modo-evidence-risk-handoff | Registra evidencia, riesgos y handoffs de skills/cabinas con cierre trazable y sin datos sensibles. | alias de archivo: rey-modo-evidence-risk-handoff |
| rey-modo-fronteras-continuidad | rey-modo-frontier-continuity-planner | Construye planes modulares, abre fronteras utiles, preserva continuidad y aplica guardia antidegradacion. | alias de archivo: rey-modo-frontier-continuity-planner |
| rey-modo-generador-paquetes-informe | rey-modo-report-pack-generator | Genera paquetes de informe MD/DOCX/PDF y matrices CSV con verificacion local parseable. | alias de archivo: rey-modo-report-pack-generator |
| rey-modo-gobernador-capacidades | rey-modo-gobierno-capacidades | Use when you need to discover, normalize, assign, or validate Rey Mode capabilities before adopting a skill or touching the local canon. | alias de archivo: rey-modo-gobierno-capacidades; alias de registry: rey-modo-gobierno-skills |
| rey-modo-mapa-documental-escenarios | rey-modo-docset-scenario-mapper | Mapea escenario documental, documento, lista/biblioteca, metadata minima, emisor, lector, autorizador y efecto operativo. | alias de archivo: rey-modo-docset-scenario-mapper |
| rey-modo-recuperador-codigo-repos | rey-modo-repo-code-recovery | Recupera y clasifica codigo, scripts, manifests, laws, schemas y runbooks como referencia, patron, runtime o prohibido. | alias de archivo: rey-modo-repo-code-recovery |
| rey-modo-traductor-reino-tecnico | rey-modo-reino-technical-translator | Traduce narrativa Reino a equivalentes tecnicos, jerarquia documental y efectos sobre listas/documentos/cabinas. | alias de archivo: rey-modo-reino-technical-translator |
| rey-modo-verificador-cierre | rey-modo-verificacion-previa-cierre | Use when you are about to declare a front complete, corrected, or ready, or before commit, PR, or close, and need fresh evidence first. | alias de archivo: rey-modo-verificacion-previa-cierre |

### TCU / normalizacion / sistemas
| Canonical | Alias / drift | Purpose | Notes |
| --- | --- | --- | --- |
| tcu-builder-paquetes-factory | tcu-factory-package-builder | Usa esta skill para empaquetar artefactos locales de Factory, TCU y cabinas en manifests, matrices, paquetes y postchecks reutilizables, sin activar runtime ni tocar produccion. | alias de archivo: tcu-factory-package-builder |
| tcu-gate-api-no-sensible | tcu-openai-api-non-sensitive-gate | Usa esta skill cuando TCU quiera evaluar o ejecutar un uso ampliado de OpenAI API con datos no sensibles o derivados saneados, proyecto API separado, fallback local, registro de uso y gate explicito; aplica a clasificacion, normalizacion, generacion de schemas, validadores, prompts, codigo auxiliar dry-run, matrices depuradas y documentacion auxiliar, y bloquea secretos, tokens, datos personales sensibles, produccion regulada, runtime y decisiones productivas. | alias de archivo: tcu-openai-api-non-sensitive-gate |
| tcu-harness-evals-agentes | tcu-agent-eval-harness | Usa esta skill para ejecutar evals, traces y dry-runs sinteticos de agentes/cabinas en TCU_LOCAL y Factory, sin OpenAI API real por defecto, sin runtime productivo y con salida verificable. | alias de archivo: tcu-agent-eval-harness |
| tcu-normalizador-estado-cabinas | tcu-cabina-state-normalizer | Usa esta skill para normalizar el estado de cabinas, matrices, handoffs y salidas parseables dentro de TCU_LOCAL y REY_LOCAL, reutilizando fuentes existentes, sin runtime, sin permisos, sin SharePoint write y sin abrir /sites/soporte. | alias de archivo: tcu-cabina-state-normalizer |
| tcu-normalizador-sistema-modo-on | tcu-modo-e-system-normalizer | Normaliza el sistema operativo TCU entre CanonicaReyModoOn y SYS-ModoOn-PILOTO leyendo listas, bibliotecas, documentos, metadata y aplicando equivalencias seguras sin clonar Canónica, sin runtime, sin permisos y con pre/postcheck. | alias de archivo: tcu-modo-e-system-normalizer |
| tcu-publicador-documental-sys | tcu-sys-documental-publisher | Usa esta skill para preparar o ejecutar publicacion documental controlada hacia SYS-ModoOn-PILOTO bajo gate exacto, con precheck, backup, readback y sin runtime ni permisos. | alias de archivo: tcu-sys-documental-publisher |
| tcu-readback-handoff-sys | tcu-sys-readback-handoff-normalizer | Usa esta skill para validar funcionalmente SYS-ModoOn-PILOTO despues de una publicacion documental TCU, comparar listas/bibliotecas/vistas/registros base, detectar handoffs reales evidenciados entre cabinas y poblar SYS_Handoffs por upsert sin inventar transferencias, sin reaprovisionar, sin runtime, sin permisos y sin abrir /sites/soporte. | alias de archivo: tcu-sys-readback-handoff-normalizer |

## .codex/skills

### Arranque y Delegacion
| Canonical | Alias / drift | Purpose | Notes |
| --- | --- | --- | --- |
| cabina-4field-delegate | cabina-4field-delegate | Delegate a task in the smallest possible package. Use when Codex needs a minimal handoff fast. |  |
| cabina-4field-paper | cabina-4field-paper | Open a minimal four-field workpaper fast. Use when Codex needs the shortest possible starting packet. |  |
| cabina-agent-delegation | cabina-agent-delegation | Package a bounded task for a delegated agent. Use when Codex should hand off a lane without losing governance, context, or return shape. |  |
| cabina-session-handoff | cabina-session-handoff | Use when a Cabina Universal session, PR, agent lane, or interrupted task needs a compact handoff or readback with verified branch, PR, commit, validator evidence, risks, next lanes, and stop conditions. |  |
| cabina-start-paper | cabina-start-paper | Open a compact workpaper for a new or resumed Cabina task. Use when Codex needs a short starting packet instead of a full re-scan. |  |
| parallel-agentic-repo-audit | parallel-agentic-repo-audit | Use when a repo-wide or multi-file audit must optimize AGENTS.md, skills, workflows, conventions, risks, or validation through a parallel audit chain, fan-in evidence, and no-live local governance. |  |
| parallel-order-governance | parallel-order-governance | Use when parallel agents, subagents, order preparation, lock keys, local OpenAI design, or lane governance must be coordinated in D-drive. |  |
| tcu-desarrollo-con-subagentes | tcu-desarrollo-con-subagentes | Use when a D:\ task needs subagent, parallel, lane, or lock key governance for delegated local work with owners, reviewers, validators, evidence, and stop conditions. |  |

### Arranque y Delegacion / soporte
| Canonical | Alias / drift | Purpose | Notes |
| --- | --- | --- | --- |
| cabina-agent-md-refactor | cabina-agent-md-refactor | Use when AGENTS.md, Codex UI prompts, project instructions, or local governance instructions in cabina-universal-d need pruning, normalization, drift review, or instruction precedence checks without weakening AGENTS.md canon. |  |
| cabina-commit-work | cabina-commit-work | Use when durable repo work in cabina-universal-d or registered repos must move through GitHub branch, explicit staging, commit, push, draft PR, checks, and readback under cabina governance. |  |
| cabina-document-plugin-adapter | cabina-document-plugin-adapter | Use when Documents, Spreadsheets, Presentations, or PDF plugin work in D:\ needs local artifact handling, regulated-data boundary, render QA, or export evidence. |  |
| cabina-github-actions-templates | cabina-github-actions-templates | Use when creating or reviewing GitHub Actions, Copilot instructions, issue forms, PR templates, workflow permissions, checks, or repo automation templates for cabina-governed repos. |  |
| cabina-github-plugin-adapter | cabina-github-plugin-adapter | Use when GitHub plugin or gh CLI work in D:\ needs issue, PR, branch, commit, push, check, or merge handling under Cabina governance. |  |
| cabina-naming-analyzer | cabina-naming-analyzer | Use when agent ids, repo ids, matrix ids, skill ids, recipe ids, tool ids, aliases, folders, or stop conditions need canonical naming, alias mapping, cross-matrix synchronization, or vocabulary checks in cabina-universal-d. |  |
| cabina-sharepoint-plugin-adapter | cabina-sharepoint-plugin-adapter | Use when SharePoint plugin work in D:\ needs site, library, list, document, metadata, or evidence handling under Microsoft live gates. |  |
| cabina-superpowers-methodology-adapter | cabina-superpowers-methodology-adapter | Use when Superpowers methodology in D:\ needs planning, debugging, verification, subagent, worktree, or skill-writing guidance under Cabina governance. |  |
| cabina-teams-plugin-adapter | cabina-teams-plugin-adapter | Use when Teams plugin work in D:\ needs channel, chat, message, notification, digest, reply, or Planner handling under Microsoft live gates. |  |

### Continuidad
| Canonical | Alias / drift | Purpose | Notes |
| --- | --- | --- | --- |
| cabina-context-refresh | cabina-context-refresh | Restore current working context fast from local matrices, readbacks, skills, branch state, and active gates. Use when Codex needs a compact rehydration pass before continuing interrupted Cabina or Dataverse work. |  |
| cabina-continuity-readback | cabina-continuity-readback | Produce a compact continuity packet with verified state, stale items, risks, rollback, and the next lane. Use when Codex needs a short operational readback that keeps work agile without repeating full inventory. |  |
| cabina-decision-matrix | cabina-decision-matrix | Route a task to the right Cabina lane using a compact decision matrix. Use when Codex needs to choose the next best skill or action fast. |  |
| cabina-lane-selector | cabina-lane-selector | Select the smallest Cabina lane needed for a task. Use when Codex needs a one-line routing choice fast. |  |
| cabina-mini-router | cabina-mini-router | Route a task through a one-line Cabina lane map. Use when Codex needs the smallest possible routing choice. |  |
| codex-surface-map | codex-surface-map | Organize Codex workspaces and project folders into short visible entry points, map maestros, and longer reference pages without breaking cross-links. Use when the user asks to split or refactor README/AGENTS/environment/skills/outputs/worktrees/plugins/workpapers into a navigable structure, preserve connections, or create a reusable navigation skill. |  |
| governed-readback-closeout | governed-readback-closeout | Use when a readback, closeout, validator result, evidence packet, or next-lane handoff must close local D-drive work under cabina governance. |  |
| cierre-wave-documental | cierre-wave-documental | Absorbs a documented wave into a hito, index, trace, and readback; use when a wave already has local evidence and needs a durable closeout, visible navigation, and a short next delta. |  |
| dataverse-rehidratacion | dataverse-rehidratacion | Restores Dataverse context when a thread is long, continuity is lost, or the lane needs to be re-opened from local evidence; use when rehydrating Dataverse state, choosing the next governed delta, or separating metadata-only from live surfaces. |  |
| normalizacion-perfil-windows | normalizacion-perfil-windows | Normalizes a Windows profile when Documents, OneDrive, shell folders, or junctions have drifted; use when repairing profile paths, reconciling shell folder targets, or moving content from a cloud-backed path to a local canonical path without breaking compatibility. |  |
| tcu-descubridor-capacidades | tcu-descubridor-capacidades | Use when starting, assigning, deriving, dispatching, executing, or closing any Cabina Universal task to run skill discovery, capability assignment, NO_DISPONIBLE marking, and preflight for the real available skill, recipe, plugin, and tool set. |  |

### Continuidad / Rey Modo
| Canonical | Alias / drift | Purpose | Notes |
| --- | --- | --- | --- |
| rey-modo-auditor-sharepoint-seguro | rey-modo-sharepoint-safety-auditor | Ejecuta inventario SharePoint read-only y prepara writes gateados con rollback sin tocar permisos ni InternalName. | alias de archivo: rey-modo-sharepoint-safety-auditor |
| rey-modo-evidencia-riesgo-handoff | rey-modo-evidencia-riesgo-handoff | Use when Cabina Universal work needs evidence, risk, rollback, touched-surface, or handoff closeout under D:\AGENTS.md without live writes. |  |
| rey-modo-gobernador-capacidades | rey-modo-gobernador-capacidades | Use when capability discovery, skill adoption, NO_DISPONIBLE marking, or integration decisions are needed for skills, recipes, plugins, tools, or capabilities in D:\ canon. | alias de registry: rey-modo-gobierno-skills |
| rey-modo-handoff-continuidad | rey-modo-continuidad-sesion | Use when you need to create or resume short handoffs between sessions or gates, capture state, evidence, and blockers, or define one next front without inventing a second memory. | alias de archivo: rey-modo-continuidad-sesion |
| rey-modo-respuesta-breve | rey-modo-salida-breve | Use when you need a short Rey response for debug, review, status, blockers, or closeout without losing evidence or the next step. | alias de archivo: rey-modo-salida-breve |

### Soporte / apps
| Canonical | Alias / drift | Purpose | Notes |
| --- | --- | --- | --- |
| chatgpt-apps | chatgpt-apps | Build, scaffold, refactor, and troubleshoot ChatGPT Apps SDK applications that combine an MCP server and widget UI. Use when Codex needs to design tools, register UI resources, wire the MCP Apps bridge or ChatGPT compatibility APIs, apply Apps SDK metadata or CSP or domain settings, or produce a docs-aligned project scaffold. Prefer a docs-first workflow by invoking the openai-docs skill or OpenAI developer docs MCP tools before generating code. |  |

### Soporte / documentos
| Canonical | Alias / drift | Purpose | Notes |
| --- | --- | --- | --- |
| doc | doc | Use when the task involves reading, creating, or editing `.docx` documents, especially when formatting or layout fidelity matters; prefer `python-docx` plus the bundled `scripts/render_docx.py` for visual checks. |  |
| pdf | pdf | Use when tasks involve reading, creating, or reviewing PDF files where rendering and layout matter; prefer visual checks by rendering pages (Poppler) and use Python tools such as `reportlab`, `pdfplumber`, and `pypdf` for generation and extraction. |  |

### Soporte / frontend
| Canonical | Alias / drift | Purpose | Notes |
| --- | --- | --- | --- |
| agentation | agentation | Use when a Next.js project needs the Agentation visual feedback toolbar or a minimal UI-to-code setup for frontend work. |  |

### Soporte / matrices
| Canonical | Alias / drift | Purpose | Notes |
| --- | --- | --- | --- |
| matrix-recipe-skill-sync | matrix-recipe-skill-sync | Use when a D-drive matrix, recipe, skill, tool, map, eval, or agent assignment changes and indexes must stay aligned. |  |

### Soporte / navegacion
| Canonical | Alias / drift | Purpose | Notes |
| --- | --- | --- | --- |
| playwright | playwright | Use when the task requires automating a real browser from the terminal (navigation, form filling, snapshots, screenshots, data extraction, UI-flow debugging) via `playwright-cli` or the bundled wrapper script. |  |

### Soporte / seguridad
| Canonical | Alias / drift | Purpose | Notes |
| --- | --- | --- | --- |
| security-ownership-map | security-ownership-map | Analyze git repositories to build a security ownership topology (people-to-file), compute bus factor and sensitive-code ownership, and export CSV/JSON for graph databases and visualization. Trigger only when the user explicitly wants a security-oriented ownership or bus-factor analysis grounded in git history (for example: orphaned sensitive code, security maintainers, CODEOWNERS reality checks for risk, sensitive hotspots, or ownership clusters). Do not trigger for general maintainer lists or non-security ownership questions. |  |

### Soporte / sistema
| Canonical | Alias / drift | Purpose | Notes |
| --- | --- | --- | --- |
| skill-creator | skill-creator | Guide for creating effective skills. This skill should be used when users want to create a new skill (or update an existing skill) that extends Codex's capabilities with specialized knowledge, workflows, or tool integrations. |  |
| skill-installer | skill-installer | Install Codex skills into $CODEX_HOME/skills from a curated list or a GitHub repo path. Use when a user asks to list installable skills, install a curated skill, or install a skill from another repo (including private repos). |  |
| skill-judge | skill-judge | Use when skill review, SKILL.md audit, or integration decision work is needed before trusting, integrating, comparing, or assigning skills in D:\. |  |

### Soporte / TCU
| Canonical | Alias / drift | Purpose | Notes |
| --- | --- | --- | --- |
| tcu-fix-auth-flows-power-automate | tcu-powerautomate-flow-auth-fix | Use when a TCU or Modo E Power Automate solution flow says Please authenticate the flow connections and save, CannotStartUnpublishedSolutionFlow, ConnectionAuthorizationFailed, or keeps asking for authentication before asking the user to log in again. | alias de archivo: tcu-powerautomate-flow-auth-fix |
| tcu-harness-evals-agentes | tcu-harness-evals-agentes | Use when running local synthetic evals, dry-runs, or agent/cabina harness checks without OpenAI API live, production runtime, or sensitive data. |  |
| tcu-normalizador-sistema-modo-on | tcu-normalizador-sistema-modo-on | Use when aligning MODO_ON system structures, equivalences, matrices, or evidence without copying tenants, changing permissions, or touching production. |  |
| tcu-optimizador-pc-local-seguro | tcu-optimizador-pc-local-seguro | Use when optimizing Enzo's Windows PC locally with TCU/Rey safety rules: diagnose performance, clean only authorized temporary files, prepare startup/process deactivation matrices, protect OneDrive/Google Drive/Git/repos/browsers/services/Defender/Windows Update, and close with evidence, rollback notes, and one next gate. |  |
| tcu-planificador-con-archivos | tcu-planificador-con-archivos | Use when a complex D:\ task needs file-based planning, findings, and progress tracking as data artifacts, not executable instructions. |  |
| tcu-redactor-planes-operativos | tcu-redactor-planes-operativos | Use when a multi-step D:\ task needs a governed plan, order, rollback, or postcheck before execution, especially with live, repo, migration, or parallel risk. |  |

### Soporte / tooling
| Canonical | Alias / drift | Purpose | Notes |
| --- | --- | --- | --- |
| agent-retrospective-learning | agent-retrospective-learning | Use when a completed governed frontier must be converted into reusable skills, recipes, validator candidates, agent deltas, prompt improvements, and reviewable readbacks without new live execution. |  |
| cli-creator | cli-creator | Build a composable CLI for Codex from API docs, an OpenAPI spec, existing curl examples, an SDK, a web app, an admin tool, or a local script. Use when the user wants Codex to create a command-line tool that can run from any repo, expose composable read/write commands, return stable JSON, manage auth, and pair with a companion skill. |  |
| d-drive-agent-layer-enrichment | d-drive-agent-layer-enrichment | Use when D-drive matrices, recipes, skills, tools, validators, readbacks, or agent routing overlays need local enrichment under cabina governance. |  |
| excel-workbook-builder | excel-workbook-builder | Create polished Excel workbook templates and tracker workbooks with summary sheets, structured input tables, dropdown lists, formulas, formatting, validation, and export-ready layout. Use when Codex needs to build a new workbook from scratch, or when the user asks for a reusable Excel tracker, register, intake sheet, or starter template. |  |
| imagegen | imagegen | Generate or edit raster images when the task benefits from AI-created bitmap visuals such as photos, illustrations, textures, sprites, mockups, or transparent-background cutouts. Use when Codex should create a brand-new image, transform an existing image, or derive visual variants from references, and the output should be a bitmap asset rather than repo-native code or vector. Do not use when the task is better handled by editing existing SVG/vector/code-native assets, extending an established icon or logo system, or building the visual directly in HTML/CSS/canvas. |  |
| mcp-builder | mcp-builder | Use when building or adjusting an MCP (Model Context Protocol) server or bridge that lets an LLM interact with external services through well-designed tools. |  |
| no-inference-runtime-write-guard | no-inference-runtime-write-guard | Use when a runtime write, metadata write, target ambiguity, or inferred target update must be blocked unless exact target identity is proven. |  |
| openai-docs | openai-docs | Use when the user asks how to build with OpenAI products or APIs, asks about Codex itself or choosing Codex surfaces, needs up-to-date official documentation with citations, help choosing the latest model for a use case, or model upgrade and prompt-upgrade guidance; use OpenAI docs MCP tools for non-Codex docs questions, use the Codex manual helper first for broad Codex self-knowledge, and restrict fallback browsing to official OpenAI domains. |  |
| plugin-creator | plugin-creator | Create and scaffold plugin directories for Codex with a required `.codex-plugin/plugin.json`, optional plugin folders/files, valid manifest defaults, and personal-marketplace entries by default. Use when Codex needs to create a new personal plugin, add optional plugin structure, generate or update marketplace entries for plugin ordering and availability metadata, or update an existing local plugin during development with the CLI-driven cachebuster and reinstall flow. |  |
| repo-agent-tool-governance | repo-agent-tool-governance | Use when repo, agent, tool, surface, recipe, capability, owner, validator, or stop-condition governance must be assigned in D-drive. |  |
| vsi-superficie-viva-task-runner | vsi-superficie-viva-task-runner | Use when an agent must execute a prepared VSI VS Code Insiders superficie viva agent task queue row from VSCODE_INSIDERS_AGENT_TASK_QUEUE_20260606.csv while preserving agent contracts and gating external live writes. |  |

### Vivo / Dataverse
| Canonical | Alias / drift | Purpose | Notes |
| --- | --- | --- | --- |
| dataverse-agent-surface-discovery | dataverse-agent-surface-discovery | Fast local-first discovery of Dataverse agent and computer-use surfaces, solution components, entity sets, saved views, and live rows. Use when Codex needs to locate or confirm Agent Task, ComputerUseAgent, agent metadata, or the exact Dataverse surface behind a requested agent or computer name before proceeding. |  |
| dataverse-atomic-segment-runner | dataverse-atomic-segment-runner | Use when a Dataverse DEV or tenant-controlled atomic segment must select, apply, or postcheck mon_sdu_* metadata rows by exact canonical id, including evidence, readback, apply-log, gate, source/target, rollback, and no-inference runtime write handling. |  |
| dataverse-metadata-only-provisioning | dataverse-metadata-only-provisioning | Use when a Dataverse DEV metadata-only schema, seed, manifest, or postcheck package must be prepared or reviewed without secrets, PROD, TEST, Default, or blind writes. |  |
| dataverse-workqueue-backreference-mapping | dataverse-workqueue-backreference-mapping | Use when a processed Dataverse Work Queue item needs deterministic metadata-only back-reference mapping and target writes must be blocked unless exact target identity is proven. |  |

### Vivo / SharePoint
| Canonical | Alias / drift | Purpose | Notes |
| --- | --- | --- | --- |
| sdu-cn-live-agent-activation | sdu-cn-live-agent-activation | Use when an operator explicitly requests SDU-CN live activation, sdu-triage-agent runtime promotion, Dataverse or Power Platform activation, or agent live execution from Cabina governance. |  |
| sdu-ejecutor-gates | sdu-ejecutor-gates | Use when executing or closing SDU gates in D:\ with canon, evidence, validator, rollback, and one formal outcome. | alias de index: sdu-gate-executor |
| sdu-sharepoint-backlog-by-list | sdu-sharepoint-backlog-by-list | Build a prioritized backlog from live SharePoint list signals, keeping each list separate and preserving gates, rollback, and readback evidence. Use when Codex needs to convert current SharePoint rows, queues, or backlog entries into an operable backlog by list, especially for SDU or SYS-PILOTO surfaces. |  |
| sdu-sharepoint-bitacora-seshat-m365-fallback | sdu-sharepoint-bitacora-seshat-m365-fallback | Use when preparing or executing a governed native SharePoint list write against SeshatHubRegistroN.8 / Bitacora Seshat through CLI for Microsoft 365 as a fallback lane after the exact target packet is already proven and PnP.PowerShell is unavailable or intentionally skipped. |  |
| sdu-sharepoint-bitacora-seshat-write-reuse | sdu-sharepoint-bitacora-seshat-write-reuse | Use when preparing or executing a governed native SharePoint list write against SeshatHubRegistroN.8 / Bitacora Seshat and the exact site, list, identity, key rule, or exact existing tuple should be reused instead of rediscovered. |  |
| sdu-sharepoint-context-refresh | sdu-sharepoint-context-refresh | Restore SharePoint live context fast from local cache, readbacks, and exact site or list evidence. Use when Codex needs to resume SharePoint work without repeating full discovery, especially for SYS-GobiernoOperativo-PILOTO or other live SDU surfaces. |  |
| sdu-sharepoint-native-list-reader | sdu-sharepoint-native-list-reader | Use when a user asks to read SharePoint rows, items, columns, views, backlog entries, or native list data directly from a live list surface instead of document libraries, folders, files, or exported CSVs. |  |
| sdu-sharepoint-piloto-read-reuse | sdu-sharepoint-piloto-read-reuse | Use when reading SharePoint SYS-GobiernoOperativo-PILOTO lists, libraries, SD_BacklogEstrategico, LIB_GobiernoSistemas, or PnP.PowerShell evidence and cached live read evidence may prevent repeated discovery. |  |
| sdu-sharepoint-surface-guard | sdu-sharepoint-surface-guard | Use when a user asks for SharePoint lists, queues, backlog, rows, items, libraries, folders, files, permissions, or exports and the surface must be classified before reading or answering. |  |

### Vivo / soporte
| Canonical | Alias / drift | Purpose | Notes |
| --- | --- | --- | --- |
| sdu-auditor-sharepoint-vivo | sdu-live-sharepoint-audit | Use when requests mention live SharePoint lists, groups, item permissions, naming drift, ESCRIBANIABITSCH, SYS, or a modo-on-foundation gate needs minimum real evidence classified as confirmado, probable, or inferido. | alias de archivo: sdu-live-sharepoint-audit |
| sdu-publicador-snapshots | sdu-snapshot-publisher | Use when requests mention SDU-07, Auditoria Integrada, Publish-SduOperationalProgram.ps1, republishing, queue synchronization, or snapshot refresh after a gate close and a real SDU publication delta must be verified. | alias de archivo: sdu-snapshot-publisher |

