# Contributing

## Flujo de Trabajo

1. Crear una rama acotada por tema.
2. Mantener commits atomicos.
3. Abrir PR con resumen, validacion y riesgos.
4. No mezclar cambios documentales, tooling y runtime en el mismo recorte salvo justificacion.

## Convenciones de Rama

- `feature/*`: nuevas capacidades.
- `fix/*`: correcciones.
- `docs/*`: documentacion.
- `chore/*`: mantenimiento.
- `codex/*`: ramas operativas creadas por Codex cuando no exista convencion especifica.

## Validacion

Antes de pedir revision, ejecutar los validadores disponibles para el alcance del cambio.

## Seguridad

- No incluir secretos.
- No leer ni versionar `.env.local`.
- No publicar tokens, credenciales ni dumps sensibles.
- Los writes externos requieren owner, rollback, postcheck y evidencia.
