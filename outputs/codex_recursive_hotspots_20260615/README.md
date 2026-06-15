# Codex Recursive Hotspots

Reporte local de la superficie recursiva de `.codex` para distinguir frente, soporte y ruido operativo.

## Origen

- Raiz analizada: `C:\Users\enzo1\.codex`
- Metodo: conteo recursivo por carpeta de primer nivel
- Estado visible: `GREEN_OPERABLE`

## Lo que pesa mas

- `cache` - 26725 archivos, 2289 carpetas
- `worktrees` - 16329 archivos, 3088 carpetas
- `.tmp` - 10132 archivos, 3289 carpetas
- `plugins` - 2070 archivos, 1103 carpetas
- `vendor_imports` - 902 archivos, 243 carpetas
- `archived_sessions` - 568 archivos
- `sessions` - 491 archivos, 65 carpetas

## Lo que conviene traer al frente

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

## Lo que conviene tratar como soporte o ruido

- Soporte: `plugins`, `vendor_imports`, `attachments`, `backups`, `memories`, `browser`, `log`
- Ruido o estado: `cache`, `worktrees`, `.tmp`, `sessions`, `archived_sessions`, `computer-use-turn-ended`, `tmp-appserver-schema`, `tmp`, `worktree-archives`, `worktrees-disabled`
- Sensible: `secrets`, `private`, `.sandbox*`, `sqlite`, `auth.json`, `cap_sid`

## Cierre

El hallazgo utilizable no es solo el conteo: es la separacion entre superficies que gobiernan conocimiento operativo y superficies que solo sostienen estado temporal.
