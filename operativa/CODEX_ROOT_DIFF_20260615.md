# Diff De `.codex`

Comparacion corta entre el filesystem vivo de `C:/Users/enzo1/.codex` y su layer visible.

## Estado

`GREEN_OPERABLE`

## Fuente

- Inventario vivo del root `.codex` obtenido por filesystem.
- `README.md` y `MAPA_MAESTRO.md` de `.codex`.
- `operativa/CONTROL_TOTAL_20260615.md` como semaforo visible del ecosistema.

## Resultado Vivo

- `45` carpetas directas.
- `34` archivos directos.
- `79` entradas directas.
- `.tmp` existe y esta documentada.

## Lo Que Coincide

- `README.md` y `MAPA_MAESTRO.md` siguen funcionando como capas cortas de entrada.
- `operativa/CONTROL.md`, `operativa/README.md`, `operativa/MAPA.md`, `hitos/README.md` y el bloque de superficies extra siguen alineados con el mapa maestro.
- `catalogo-local`, `generated_images`, `node_repl`, `packages`, `profiles`, `skills_archived` y `skills_backups` aparecen en `MAPA_MAESTRO.md`.

## Lo Que Queda Solo En El Root Vivo

Estas superficies existen en filesystem pero no se promueven como entradas visibles cortas:

- `.sandbox`, `.sandbox-bin`, `.sandbox-secrets`
- `ambient-suggestions`, `app-server-local`, `archived_sessions`, `attachments`, `automations`, `backups`, `browser`, `cache`
- `computer-use`, `computer-use-turn-ended`, `environment`, `log`, `memories`, `memories_extensions`
- `pets`, `plugins`, `private`, `process_manager`, `readbacks`, `rules`, `secrets`
- `sessions`, `sqlite`, `tmp`, `tmp-appserver-schema`, `vendor_imports`, `workpapers`, `worktree-archives`, `worktrees`, `worktrees-disabled`
- archivos de estado como `auth.json`, `cap_sid`, `config.toml`, `history.jsonl`, `version.json`, `goals_1.sqlite`, `logs_2.sqlite`, `memories_1.sqlite`, `state_5.sqlite`

## Lectura

- No hay un desvio visible entre el mapa corto y el root real.
- El root real contiene carriles de estado, cache, ejecucion y seguridad que conviene dejar fuera del indice corto.
- El estado ecosistemico visible ya es `GREEN_OPERABLE`; el diff solo confirma frontera, no bloqueo.
- Si se quiere reducir ruido, el siguiente candidato es afinar el layer visible, no tocar el contenido del root vivo.

## Cierre

- `codex-surface-map` sigue siendo la skill correcta para este carril.
- `C:/Users/enzo1/.codex/.tmp` queda documentada y no requiere accion adicional por ahora.
