# Mapa De Conexiones Dataverse

Bloque faltante del carril Dataverse: superficies de conexion, gates y evidencia de semilla.

## Fuente

- `C:\Users\enzo1\.codex\matrices\dataverse\data\seed_connection_surfaces.csv`
- `C:\Users\enzo1\.codex\matrices\dataverse\data\seed_connection_gates.csv`
- `C:\Users\enzo1\.codex\matrices\dataverse\data\seed_connection_evidence.csv`
- `C:\Users\enzo1\.codex\matrices\dataverse\validation\DATAVERSE_DRIFT_RULES.md`
- `C:\Users\enzo1\.codex\tge.config.toml` como perfil local de procedencia para conexiones TGE relacionadas.

## Cobertura

- 15 superficies de conexion
- 6 gates de conexion
- 5,222 filas de evidencia de conexion

## Superficies

| Canonical Id | Superficie | Gate |
| --- | --- | --- |
| `surface.agents_sdk` | `Agents SDK` | `GATE_OPENAI_LIVE_GOVERNED_ORDER` |
| `surface.azure_openai` | `Azure OpenAI` | `GATE_OPENAI_LIVE_GOVERNED_ORDER` |
| `surface.codex_connector` | `Codex Connector` | `GATE_CONNECTOR_REGISTRY_NO_SECRET` |
| `surface.entra_id` | `Entra ID` | `GATE_MICROSOFT_LIVE_GOVERNED_ORDER` |
| `surface.github_actions` | `GitHub Actions` | `GATE_GITHUB_REPO_SCOPED` |
| `surface.mcp_server` | `MCP Server` | `GATE_CONNECTOR_REGISTRY_NO_SECRET` |
| `surface.microsoft_365_admin` | `Microsoft 365 Admin` | `GATE_MICROSOFT_LIVE_GOVERNED_ORDER` |
| `surface.microsoft_graph` | `Microsoft Graph` | `GATE_MICROSOFT_LIVE_GOVERNED_ORDER` |
| `surface.openai_api` | `OpenAI API` | `GATE_OPENAI_LIVE_GOVERNED_ORDER` |
| `surface.planner` | `Planner` | `GATE_MICROSOFT_LIVE_GOVERNED_ORDER` |
| `surface.power_platform_admin` | `Power Platform Admin` | `GATE_POWER_PLATFORM_DEV_TARGET_EXPLICIT` |
| `surface.semantic_kernel` | `Semantic Kernel` | `GATE_CONNECTION_SURFACE_CLASSIFICATION_REQUIRED` |
| `surface.sharepoint` | `SharePoint` | `GATE_MICROSOFT_LIVE_GOVERNED_ORDER` |
| `surface.teams` | `Teams` | `GATE_MICROSOFT_LIVE_GOVERNED_ORDER` |
| `surface.unknown_por_definir` | `Unknown / POR_DEFINIR` | `GATE_CONNECTION_SURFACE_CLASSIFICATION_REQUIRED` |

## Gates

- `GATE_CONNECTION_SURFACE_CLASSIFICATION_REQUIRED`
- `GATE_CONNECTOR_REGISTRY_NO_SECRET`
- `GATE_GITHUB_REPO_SCOPED`
- `GATE_MICROSOFT_LIVE_GOVERNED_ORDER`
- `GATE_OPENAI_LIVE_GOVERNED_ORDER`
- `GATE_POWER_PLATFORM_DEV_TARGET_EXPLICIT`

## Matrices Auxiliares

- `seed_connection_instances.csv`: unifica `repo`, `surface`, `provider`, `tenant_scope`, gate, secreto, clase canonica y stop condition por `connection_canonical_id`.
- `seed_connection_risks.csv`: baja cada conexion a `risk_level` y `mitigation`.
- `seed_connection_secret_boundaries.csv`: fija `secret_required`, `secret_status`, almacenamiento permitido y almacenamiento bloqueado.

## Evidencia

La evidencia ya no es un resumen corto: vive como registro masivo por `connection_canonical_id`.

- Formato: `evidence.conn_canon_*`
- Tipo: `metadata_pointer_only`
- Uso: trazar origen, gate y stop condition antes de cualquier live order

## Drift

- Cambio de esquema sin cobertura de manifiesto: bloquea
- Workflow DEV con `prod`, `production` o `default`: bloquea
- Cambio de publisher o solution sin readback: bloquea
- Falta de apply log tras import/export: bloquea
- Hash de seed desalineado o familias duplicadas: aviso

## Lectura Operativa

- Este mapa queda en carril metadata-only.
- No convierte las matrices `.codex` en permiso de escritura live.
- `tge.config.toml` solo aporta procedencia y contexto de layout; no habilita ningun live write.
- Si una superficie o gate queda ambiguo, el siguiente paso es clasificar antes de escribir.
