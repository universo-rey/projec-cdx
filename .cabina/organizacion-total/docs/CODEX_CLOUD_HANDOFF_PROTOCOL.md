# Codex Cloud Handoff Protocol

## Objetivo

Permitir handoff local a Codex Cloud y retorno a local sin perder contrato, evidencia ni seguridad.

## Se Puede Enviar

- Baseline ids.
- Commit ids.
- Rutas no sensibles.
- Contratos.
- Manifiestos saneados.
- Readbacks.
- Skills y recipes.
- Planes de tareas.
- Resumenes de error.

## No Se Envia

- Secretos.
- Tokens.
- Credenciales.
- D3-D7 raw.
- Documentos notariales raw.
- Evidencia SGIN cruda.
- Datos personales no saneados.

## Recepcion

Cloud puede devolver plan, patch, readback o instrucciones de validacion. Local valida antes de aplicar:

1. Parse.
2. Secret scan.
3. `git diff --check`.
4. Revision de pathspec.
5. Owner gate si hay commit, remoto o live.

## Regla Funcional

Si Cloud no esta disponible, se empaqueta `CLOUD_READY_PACKAGE` y la operacion local continua.
