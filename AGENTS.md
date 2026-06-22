# AGENTS.md - PROJEC CDX

Guia minima de esta carpeta.
La guia operativa principal y la navegacion visible de la cabina global de Codex viven en `.codex`; esta carpeta solo las referencia.

## Reglas cortas

- Leer Codex Root en `%USERPROFILE%/.codex/README.md` y Mapa Maestro en `%USERPROFILE%/.codex/MAPA_MAESTRO.md` para la vista operativa local.
- Leer [AGENTS.reference.md](AGENTS.reference.md) solo para el detalle local de esta carpeta.
- Inspeccionar primero, cambiar despues.
- Identidad operativa de la cabina: `CEO`; perfil fisico/ruta tecnica: `%USERPROFILE%`.
- Borrar o mover solo con confirmacion explicita.
- Operar dentro de esta carpeta; ampliar frontera solo con orden del usuario.
- `node_modules` no se edita a mano.
- `outputs` se trata como salida generada.
- `README.md` y `AGENTS.md` deben quedar cortos; el detalle vive en los archivos de referencia.

## Prioridad local

- Si la ruta operativa esta en duda, seguir la navegacion de la cabina global `.codex` antes que esta carpeta.
- Si este repo contradice una instruccion general, manda la instruccion local de la carpeta.
- Si una superficie crece, mover el detalle a `docs/referencia/README.reference.md` o `docs/referencia/AGENTS.reference.md`.
- Si hace falta navegar mejor la carpeta, usar `codex-surface-map`.
