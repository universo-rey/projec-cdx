# SDU MAX BASELINE LIVE SECRET POLICY 20260622

Estado: `LOCKED_BY_DEFAULT`

## Reglas

1. No imprimir secretos.
2. No persistir secretos.
3. No copiar secretos a readbacks.
4. No leer `.env.local` salvo orden explicita.
5. No aceptar placeholders ejecutables.
6. No usar tokens por defecto.
7. No deducir permisos por presencia de CLI.
8. No ejecutar login interactivo en esta orden.
9. No guardar dumps de tenant.
10. No mezclar tenant real con entorno sintetico.

## Estados permitidos

- `SECRET_PRESENT_REDACTED`
- `SECRET_ABSENT_OPTIONAL`
- `SECRET_REQUIRED_FOR_FUTURE_GATE`
- `SECRET_BLOCKED_PLACEHOLDER`
- `SECRET_NOT_READ_BY_POLICY`

## Aplicacion por superficie

| Superficie | Politica |
|---|---|
| GitHub | `GITHUB_TOKEN` y `GH_TOKEN` se registran solo por presencia. |
| OpenAI | `OPENAI_API_KEY` se registra solo por presencia. No hay llamada live sin gate. |
| Microsoft / Graph | secretos de app y tenant se registran solo por presencia. |
| Dataverse / Power Platform | perfiles y auth se registran solo por presencia. No se ejecuta PAC auth/login. |
| SharePoint / M365 | tenant/site se registran solo por presencia. No login interactivo. |
| Local bridge / MCP | cualquier token dev requiere valor real gobernado o falla cerrado. |
| `.env.local` | presencia registrada; contenido no leido por politica. |

## Placeholder policy

Se buscaron patrones:

- `DEV_AUTH_PLACEHOLDER_ONLY`
- `PLACEHOLDER`
- `CHANGEME`
- `TODO_SECRET`
- `dummy-token`
- `fake-token`
- `example-token`

Resultado del pase local: no se detectaron placeholders ejecutables en archivos versionados.

Si aparece un placeholder en documentacion de ejemplo:

- clasificar como `EXAMPLE_ONLY`.

Si aparece como valor por defecto ejecutable:

- clasificar como `SECRET_BLOCKED_PLACEHOLDER`.
- detener apertura live.
- exigir patch local minimo o decision humana.

## Decision final

`NO_SECRET_VALUES_IN_BASELINE_LIVE_PACKET`
