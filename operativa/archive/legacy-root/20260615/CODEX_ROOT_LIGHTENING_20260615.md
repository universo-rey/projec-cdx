# Recorte De Raiz `.codex`

Objetivo: dejar la raiz de `.codex` liviana, operable y atomica sin romper enlaces ni tocar secretos, sqlite o state live.

## Criterio

- En la raiz visible quedan solo las entradas de orientacion y governance.
- Lo operativo de alta rotacion baja a submapas por dominio.
- Lo sensible y de estado queda en su carril tecnico, no en el indice corto.

## Mantener En La Raiz Visible

- `README.md`
- `MAPA_MAESTRO.md`
- `AGENTS.md`
- `CAPACIDADES.md`
- `README.reference.md`
- `CAPACIDADES.reference.md`
- `CODEX_ATOMIC_RUNTIME_MACHINE_V2_1.md`

## Bajar De La Raiz Visible A Submapas

Estas superficies siguen existiendo, pero no necesitan estar en el frente del root:

- `browser/`
- `cache/`
- `log/`
- `readbacks/`
- `rules/`
- `sessions/`
- `matrices/`
- `plugins/`
- `workpapers/`

## Dejar Solo En Mapa Maestro O Referencia

Estas superficies son utiles, pero conviene que vivan como referencia o mapa de segundo nivel:

- `environment/`
- `skills/`
- `worktrees/`
- `packages/`
- `generated_images/`
- `archived_sessions/`

## No Tocar

Estas piezas no se deben mover por este recorte:

- `auth.json`
- `cap_sid`
- `config.toml`
- `tge.config.toml`
- `models_cache.json`
- `history.jsonl`
- `version.json`
- `.sandbox/`
- `.sandbox-bin/`
- `.sandbox-secrets/`
- `.tmp/`
- `secrets/`
- `private/`
- `sqlite/`
- `state_5.sqlite*`
- `goals_1.sqlite*`
- `logs_2.sqlite*`
- `memories_1.sqlite*`

## Lectura Operativa

- La raiz visible ya tiene una base buena, pero puede bajar ruido si se recortan los accesos de baja frecuencia.
- `tge.config.toml` queda como perfil local de procedencia y layout TGE; no se promueve a raiz visible ni se interpreta como habilitacion live.
- La cartografia completa sigue viva en [CARTOGRAFIA_COMPLETA.md](C:/Users/enzo1/.codex/CARTOGRAFIA_COMPLETA.md).
- El siguiente paso natural es separar este recorte en un submapa por grupo, no ejecutar una limpieza ciega.
