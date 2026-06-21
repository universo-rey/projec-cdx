---
id: docs-gobernanza-versionado
titulo: Versionado
fecha: 2026-06-21
estado: fase-1
origen: docs/gobernanza/versionado.md
etiquetas: [gobernanza, git, release]
responsable: PROJEC CDX
owner: CEO
version: 0.1.0-docs
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
