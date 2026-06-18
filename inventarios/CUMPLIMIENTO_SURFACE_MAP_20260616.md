# Cumplimiento Surface Map 20260616

## Objetivo

Clasificar la superficie `C:\Users\enzo1\Documents\Cumplimiento` sin mover nada, separando capas de codigo, evidencia y ruido operativo.

## Estado Confirmado

- Ruta raiz: `C:\Users\enzo1\Documents\Cumplimiento`
- Tamano total: `19.53 GB`
- Git root: si
- Estado Git: sucio, con `AUDITORIA_CODEX_LOCAL/`, `.vscode/`, `finalize_codex_local_audit.ps1` y `run_codex_local_audit.ps1` sin rastrear

## Top-Level

| tipo | nombre | gb | clasificacion |
| --- | --- | ---: | --- |
| dir | `AUDITORIA_CODEX_LOCAL` | 16.76 | codigo / payload principal |
| dir | `.git` | 2.77 | metadata Git canonica |
| dir | `.vscode` | 0.00 | configuracion local |
| file | `finalize_codex_local_audit.ps1` | 0.00 | script operativo |
| file | `run_codex_local_audit.ps1` | 0.00 | script operativo |

## Lectura

- `AUDITORIA_CODEX_LOCAL` concentra la masa principal.
- `.git` debe preservarse intacto.
- `.vscode` y los `.ps1` son soporte local, no canon por defecto.

## Capa 1 Interna

| nombre | gb | clasificacion |
| --- | ---: | --- |
| `07_SHAREPOINT_POWER_PLATFORM_SGIN` | 9.80 | superficie viva / mayor masa operativa |
| `02_CHATS_PROMPTS_INSTRUCCIONES` | 1.92 | conocimiento y prompts |
| `04_CONFIGURACIONES` | 1.87 | configuracion local |
| `01_PROYECTOS_CODEX` | 1.26 | proyectos y workspaces |
| `09_EVIDENCIA_NO_CLASIFICADA` | 0.76 | evidencia pendiente de clasificar |
| `05_MEMORIA_Y_CONTEXTO` | 0.45 | memoria / contexto |
| `03_AGENTES_Y_HABILIDADES` | 0.38 | agentes y habilidades |
| `06_REPOSITORIOS_Y_WORKSPACES` | 0.14 | repos y workspaces |
| `00_SENSIBLE_REQUIERE_REVISION_MANUAL` | 0.09 | sensible, requiere gate manual |
| `08_DOCUMENTACION_CANONICA` | 0.06 | documentacion canonica |
| `00_MANIFIESTOS` | 0.04 | manifiestos |
| `00_LOGS` | 0.00 | logs |
| `99_REPORTE_FINAL` | 0.00 | cierre / reporte |

## Regla

- No mover sin definir destino, rollback y postcheck.
- No promocionar una carpeta a canon solo por tamaño.
- El siguiente paso es bajar un nivel dentro de `AUDITORIA_CODEX_LOCAL`.
