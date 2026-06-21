---
artifact_id: docs/gobernanza/calidad.md
categoria: playbooks
tipo: plan
estado: en_revision
version: 0.1.0
fecha_evento: "2026-06-21"
autoridad:
  tipo: owner
  referencia: CEO
origen: GitHub
ubicacion_repo: docs/gobernanza/calidad.md
etiquetas:
  - docs
  - calidad
  - gobernanza
relacionados: []
descripcion: Politica de calidad, revision y seguridad documental.
---
# Calidad

## Reglas

- No incluir secretos ni tokens en documentos.
- No duplicar binarios ni matrices pesadas en `docs/`.
- Preferir enlaces a artefactos versionados.
- Mantener front matter minimo en documentos canonicos.
- Ejecutar validaciones de metadata cuando existan.

## Checks esperados

- Links internos existentes.
- Front matter completo.
- Rutas absolutas solo cuando sean evidencia local deliberada.
- Indices actualizados despues de mover documentos.

## Front matter canonico

Usar solo claves aceptadas por `schema.json`:

```yaml
---
artifact_id: docs/ruta/archivo.md
categoria: playbooks
tipo: indice
estado: en_revision
version: 0.1.0
fecha_evento: "2026-06-21"
autoridad:
  tipo: owner
  referencia: CEO
origen: GitHub
ubicacion_repo: docs/ruta/archivo.md
etiquetas:
  - docs
  - ejemplo
relacionados: []
descripcion: Descripcion breve del artefacto documental.
---
```

## Claves permitidas

| Clave | Tipo esperado | Nota |
|---|---|---|
| `artifact_id` | string | Ruta Markdown con extension `.md`. |
| `categoria` | enum | `operativa`, `dataverse`, `procesos`, `playbooks`, `recipes`, `tests`, `packages`. |
| `tipo` | enum | `mapa`, `indice`, `matriz`, `plan`, `acta`, `orden`, `readback`, `prompt`, `reporte`. |
| `estado` | enum | `borrador`, `en_revision`, `aprobado`, `live`. |
| `version` | string | Version del artefacto. |
| `fecha_evento` | string date | Fecha ISO entre comillas. |
| `autoridad.tipo` | enum | `owner`, `equipo`, `sistema`, `externo`. |
| `autoridad.referencia` | string | Responsable o fuente de autoridad. |
| `origen` | enum | `GitHub`, `SharePoint`, `Dataverse`, `Mixto`. |
| `ubicacion_repo` | string | Ruta relativa en el repo. |
| `etiquetas[]` | array[string] | Lista de etiquetas en kebab-case o minusculas. |
| `relacionados[]` | array[string] | Rutas o artefactos relacionados. |
| `descripcion` | string | Maximo 280 caracteres. |
