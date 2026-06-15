# READBACK_GITHUB_REPOS_CANONICAL_20260615

## Estado

GREEN_LOCAL: raiz canonica local de repos confirmada.

## Fuente De Verdad

- Repos locales: `C:\Users\enzo1\Documents\GitHub`
- Workbench operativo: `C:\Users\enzo1\PROJEC CDX`
- Evidencia/espejo local: `C:\Users\enzo1\CodexLocal`

## Hallazgo

- `Documents\GitHub` contiene 13 repos Git limpios y 1 carpeta no Git.
- Todos los repos mencionados por la cadena operativa existen en `Documents\GitHub`.
- `CodexLocal` no debe ser usado como siguiente carril de promocion si el repo equivalente vive en GitHub local.

## Validacion

- Cobertura cadena -> GitHub: `PASS`.
- Faltantes en GitHub para cadena operativa: `0`.
- Repos extra GitHub detectados inicialmente: `cabina-universal-d`, `microsoft-agents-governed-lab`.
- Estado posterior: ambos fueron incorporados a cadena operativa local en `20260615-github-repos-chain-v1`.

## Stop Condition

Si una carpeta aparece en `CodexLocal` y tambien existe repo en `Documents\GitHub`, manda `Documents\GitHub` para operaciones de repo.

## Proximo Movimiento

Hecho en `20260615-github-repos-chain-v1`. Proximo movimiento: revisar si `Auditar` debe seguir como carpeta agregadora no Git o recibir indice propio.
