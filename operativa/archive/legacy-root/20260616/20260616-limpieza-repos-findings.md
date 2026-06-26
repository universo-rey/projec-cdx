# Findings

## Baseline

- `.codex` tiene varios contenedores grandes, pero el peso fuerte se concentra en runtime, sesiones, archivados y SQLite.
- `cache/codex-runtimes` contiene un runtime base, no un cache suelto.
- `__pycache__` dentro del runtime Python era reconstruible y se limpió de forma segura.

## Skills y recetas creadas

- `codex-root-surface-cleanup`
- `codex-session-worktree-surface-cleanup`
- `codex-archived-runtime-surface-cleanup`
- `codex-sqlite-log-surface-cleanup`
- `codex-runtime-cache-surface-cleanup`

## Deltas ya observados

- Se redujo peso de `.codex` con limpieza de restos temporales y caches reconstruibles.
- Se eliminaron `420` carpetas `__pycache__` del runtime Python.
- `cache/codex-runtimes` bajó tras esa limpieza, pero sigue siendo una base viva.
- `archived_sessions` se compactó fuera de `.codex` para `172` archivos viejos y la raíz bajó a `9,95 GB` en esa wave.
- `logs_2.sqlite` se compactó en sitio, pasó de ~`1,93 GB` a ~`382 MB`, y el WAL desapareció.
- `state_5.sqlite` también se compactó y quedó en ~`10 MB`.
- `cabina-universal-d-lanes` se archivó fuera de `.codex` en `C:\\Users\\enzo1\\Documents\\CodexArchives\\cabina-universal-d-lanes_20260616.zip` y la raíz bajó a `7,8 GB`.
- Cinco worktrees chicos viejos se archivaron fuera de `.codex`: `2aa1`, `b09d`, `e67c`, `7937`, `9a94`; la raíz bajó a `7,69 GB`.
- Tres worktrees viejos más se archivaron fuera de `.codex`: `cabina-universal-d-sdu-agents-runtime-connections-teams-codex-cloud-dev-20260603`, `cabina-universal-d-canon-active-governed-execution-by-default-20260603`, `process-rescue-cabina-20260605`; la raíz bajó a `7,38 GB`.
- La revisión final dejó sólo worktrees recientes o activos en `.codex` y no conviene seguir podando sin un gate explícito.

## Barrido de repos hermanos

- Se revisaron los repos sucios detectados en `Documents\GitHub`.
- No aparecieron archivos basura nuevos en los roots; los deltas restantes son notas canónicas de `README.md` o contexto vivo en `CURRENT_STATE.md`.
- `Sgin` conserva `torres/` como superficie viva; no se retiró porque ya fue marcado como intencional.
- Se limpiaron caches reconstruibles reales en `organizacion`, `tcu-agentic-runtime-control` y `torre-gemela-escribania` (`.pytest_cache` y `__pycache__`).
- Tras esa limpieza, esos repos quedaron solo con `README.md` modificado.
