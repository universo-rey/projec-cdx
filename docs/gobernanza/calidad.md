---
id: docs-gobernanza-calidad
titulo: Calidad documental y seguridad
fecha: 2026-06-21
estado: fase-1
origen: docs/gobernanza/calidad.md
etiquetas: [gobernanza, calidad, seguridad]
responsable: PROJEC CDX
owner: CEO
version: 0.1.0-docs
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
