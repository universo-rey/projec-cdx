# READBACK_INVESTIGACION_PERFILES_VARIABLES_ENTORNOS_REPOS_20260619

## Estado
OBSERVED_PREPLAN

## Dictamen
El orden correcto es:

1. Congelar y validar perfiles/variables.
2. Definir matriz de repos y aislamiento.
3. Migrar o reclonar repos hacia `C:\CEO\repos` solo por delta gobernado.
4. Crear worktrees en `C:\CEO\worktrees` solo para ramas activas.
5. Recien despues configurar entornos aislados por repo.

## Evidencia local

| Superficie | Estado observado |
| --- | --- |
| `C:\CEO` | Existe, 32 items. |
| `C:\CEO\repos` | Existe, vacio. |
| `C:\CEO\worktrees` | Existe, vacio. |
| `C:\Users\enzo1\PROJEC CDX` | Existe, es repo Git y tiene `pyproject.toml`, `.env.local`, `.venv`. |
| Variables `CEO_*` | Process y User alineadas a `C:\CEO`. |
| Variables `CODEX_*` | Process y User alineadas a `C:\CEO` / `C:\CEO\project-cdx` / `C:\CEO\repos` / `C:\CEO\worktrees`. |
| Repos reales | Siguen principalmente en `C:\Users\enzo1\Documents\GitHub`. |

## Evidencia externa investigada

| Fuente | Criterio aplicable |
| --- | --- |
| https://docs.github.com/en/codespaces/setting-up-your-project-for-codespaces/adding-a-dev-container-configuration/introduction-to-dev-containers | `.devcontainer/devcontainer.json` define herramientas, frameworks, extensiones y puertos; debe contener customizacion compartida, no preferencias personales. |
| https://containers.dev/implementors/spec/ | Dev containers separan `containerEnv` y `remoteEnv`; `workspaceFolder` debe apuntar al repo para que Git funcione bien. |
| https://docs.github.com/en/codespaces/developing-in-a-codespace/persisting-environment-variables-and-temporary-files | `remoteEnv` sirve para valores no sensibles; secretos van como development environment secrets. |
| https://docs.github.com/en/codespaces/managing-your-codespaces/managing-your-account-specific-secrets-for-github-codespaces | Secrets pueden limitarse por repositorio y quedan disponibles como variables en Codespaces. |
| https://git-scm.com/docs/git-worktree | `git worktree` permite multiples working trees por repo para ramas paralelas sin pisar el checkout principal. |
| https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_environment_variables | En Windows hay scopes `Process`, `User` y `Machine`; cambios con `$Env:` solo afectan la sesion actual, User/Machine persisten. |
| https://docs.python.org/3/tutorial/venv.html | `.venv` es ubicacion comun para aislar dependencias Python por proyecto. |

## Repos observados y aislamiento preliminar

| Repo o superficie | Marcadores | Aislamiento recomendado |
| --- | --- | --- |
| `C:\Users\enzo1\PROJEC CDX` | `pyproject.toml`, `.venv`, `.env.local` | `.venv` local obligatoria; opcional devcontainer despues. |
| `cdf-soluciones` | `.devcontainer` | Mantener devcontainer; modo repo-only/no-live. |
| `torre-gemela-escribania` | `.devcontainer` | Mantener devcontainer; gates Microsoft/produccion. |
| `seshat-bootstrap-sdu-cn` | `.devcontainer` | Mantener devcontainer documental. |
| `organizacion` | `pyproject.toml`, `.devcontainer` | `.venv` local + devcontainer opcional. |
| `microsoft-agents-governed-lab` | `package.json`, `package-lock.json` | Aislamiento Node por lockfile; devcontainer recomendado si corre agentes/M365. |
| `tcu-agentic-runtime-control` | `requirements.txt` intencionalmente vacio | Sin deps externas; `.venv` opcional para higiene. |
| `tge-agentic-runtime-control-escribania` | `requirements.txt` intencionalmente vacio | Sin deps externas; `.venv` opcional para higiene. |
| Repos documentales (`Sgin`, `sdu-canon`, `sgin-cumplimiento`, etc.) | Sin marcadores runtime | No requieren aislamiento pesado; validacion Git/Markdown. |

## Semaforo

- Verde: inventariar, clasificar, documentar, generar matriz, crear plan.
- Amarillo: crear `.venv`, instalar deps, crear worktrees, reclonar repos en `C:\CEO\repos`.
- Rojo: mover repos originales, borrar carpetas, escribir secretos, activar live Microsoft/Dataverse/SharePoint/Git remoto, tocar variables Machine.

## Stop condition
No mover repos ni crear entornos si falta owner, tipo de aislamiento, fuente canonica, rollback y postcheck por repo.

## Proximo delta
Ejecutar el plan `docs\superpowers\plans\2026-06-19-perfiles-variables-entornos-aislados-repos.md`.
