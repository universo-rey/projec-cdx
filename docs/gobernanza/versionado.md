---
artifact_id: docs/gobernanza/versionado.md
categoria: playbooks
tipo: plan
estado: en_revision
version: 0.1.0
fecha_evento: "2026-06-21"
autoridad:
  tipo: owner
  referencia: CEO
origen: GitHub
ubicacion_repo: docs/gobernanza/versionado.md
etiquetas:
  - docs
  - versionado
  - gobernanza
relacionados: []
descripcion: Politica de versionado, ramas y promocion documental.
---
# Versionado

## Ramas

- `feature/*`: nuevas capacidades o estructuras.
- `fix/*`: correcciones acotadas.
- `docs/*`: documentacion.
- `chore/*`: mantenimiento sin cambio funcional.
- `codex/*`: ramas operadas desde Codex cuando no haya convencion especifica.

## Versiones

Usar SemVer para releases publicables:

- `v0.x.y`: baseline inicial y estabilizacion.
- `v1.0.0`: primer canon estable.

## Merge

- Preferir PR con revision.
- Evitar mezclar refactor documental con cambios funcionales.
- Mantener commits atomicos por superficie.
