# Indice seguro - C:\CEO\.metadata

Fecha UTC: 2026-06-26
Modo: READ_ONLY_METADATA_INDEX_G1

## Resultado

`C:\CEO\.metadata` es evidencia local mixta: auditoria de maquina, backups/configuracion, cleanup/quarantine, matrices de herramientas, devcontainers, devdrive, incoming documental y VS Code Insiders.

No es canon directo. Es evidencia gobernada para consulta puntual.

## Buckets

| Bucket | Funcion | Tratamiento |
|---|---|---|
| `audit` | Inventario de sistema, procesos, servicios, tareas, red, paquetes, entorno | Sensible-adyacente; abrir solo con gate |
| `local-cleanup` | Evidencia de limpiezas, cuarentena, caches, logs, schemas temporales | Evidencia historica; no promover directo |
| `tooling-fine-config` | Matrices de herramientas, PATH, servicios, Docker/devcontainers, integridad | Util para decisiones de tooling |
| `local-config-backups` | Backups de `.codex`, `.agents`, skills/config | Riesgo drift/secreto indirecto |
| `devcontainers` | Readbacks/matrices/scripts/logs VMP/devcontainers | Lectura puntual segura si no ejecuta |
| `devdrive` | Forensics/recuperacion D:, scripts PowerShell y diskpart | Alto riesgo operativo |
| `incoming` | Skeleton documental entrante | Borrador, no canon |
| `env-backups` | Backups/diffs de entorno | No abrir sin gate |
| `vscode-insiders` | Backup/readback configuracion VS Code Insiders | Soporte local |

## Conteos

Lectura Thot profunda read-only:

- 92 carpetas.
- 630 archivos.
- 101.5 MB aprox.
- 3 archivos excluidos por nombre sensible.

Snapshot compacto local:

- 62 carpetas escaneadas.
- 236 archivos escaneados.
- 95.8 MB aprox.
- 2 senales sensibles por nombre visibles dentro de la profundidad compacta.

La diferencia se explica por profundidad de lectura y exclusiones.

## Indices Utiles

- `incoming\docs_skeleton_20260621\docs_skeleton\docs\index.md`
- `incoming\docs_skeleton_20260621\docs_skeleton\docs\datos\manifiestos\index.md`
- `local-cleanup\quarantine\WAVE_5_CACHE_SAFE_20260621-043138\MANIFEST.csv`
- `tooling-fine-config\fine-tuning-expanded-20260621-063740\00_FINE_TUNING_MASTER_MATRIX.csv`
- `tooling-fine-config\fine-tuning-expanded-20260621-063740\99_INTEGRITY_CHECK.csv`
- `devcontainers\REPO_ENV_ISOLATION_MATRIX_20260621.csv`

## No Abrir Sin Gate

- Cualquier nombre que matchee `.env`, `secret`, `token`, `credential`, `password`, `.pem`, `.pfx`, `.key`.
- `*.ps1`, `*.bat`, `*.diskpart`, `*.py`, `*.mjs`.
- `audit\ceo_inventory.csv`, `audit\environment.csv`, `audit\processes.csv`, `audit\services.csv`, `audit\scheduled_tasks.csv`, `audit\netstat.txt`, `audit\path.txt`.
- `env-backups\*`.
- `local-config-backups\*` salvo lectura puntual.
- `local-cleanup\quarantine\*\tmp\global-state\*`.
- Logs grandes bajo `local-cleanup\quarantine\*\logs\*`.

## Decision

Mantener `.metadata` como evidence/support. Leer bajo demanda por archivo, con objetivo, sin ejecucion y con filtro sensible antes de abrir.
