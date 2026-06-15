# Codex Recursive Delta

Delta operativo para compactar la raiz `.codex` sin perder control.

## Regla

- Lo que gobierna y versiona queda al frente.
- Lo que solo sostiene estado o cache se mueve fuera de la vista principal.
- Lo sensible no se toca.

## Delta final

### Dejar al frente

- `workpapers`
- `matrices`
- `skills`
- `hitos`
- `catalogo-local`
- `packages`
- `operativa`
- `environment`
- `profiles`
- `generated_images`

### Compactar o relegar a soporte

- `plugins`
- `vendor_imports`
- `attachments`
- `backups`
- `memories`
- `browser`
- `log`

### Sacar de la raiz visible

- `cache`
- `worktrees`
- `.tmp`
- `sessions`
- `archived_sessions`
- `computer-use-turn-ended`
- `tmp-appserver-schema`
- `tmp`
- `worktree-archives`
- `worktrees-disabled`

### No tocar

- `secrets`
- `private`
- `.sandbox*`
- `sqlite`
- `auth.json`
- `cap_sid`

## Lectura

El delta no es borrar por volumen, sino reducir ambiguedad: la raiz visible queda atomica, el soporte queda inventariado y el estado temporal queda fuera del frente.
