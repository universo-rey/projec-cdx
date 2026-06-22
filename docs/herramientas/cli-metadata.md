---
artifact_id: docs/herramientas/cli-metadata.md
categoria: playbooks
tipo: reporte
estado: en_revision
version: 0.1.0
fecha_evento: "2026-06-21"
autoridad:
  tipo: owner
  referencia: CEO
origen: GitHub
ubicacion_repo: docs/herramientas/cli-metadata.md
etiquetas:
  - docs
  - metadata
  - cli
relacionados: []
descripcion: Guia de uso de la CLI de metadata y comandos relacionados.
---
# Metadata CLI

Entrada para documentar comandos de validacion, indexacion y grafo de metadata.

## Cadena Canonica

```text
Markdown/YAML front matter -> Python metadata CLI -> JSON index/report -> Markdown/PDF/workbook
```

La fuente humana vive en Markdown con front matter YAML. La fuente maquina vive
en JSON. Python ejecuta la validacion, indexacion, grafo, promocion y reporte.

## Comandos Canonicos

```powershell
python -m tools.validate
python -m tools.build_index
cdx graph --output metadata-graph.json --format json
cdx doc-report --json-output outputs/documental/doc-report.json --md-output outputs/documental/doc-report.md
```

## Salidas Documentales

- `index.json`: indice raiz de artefactos con metadata valida.
- `operativa/index.json`: subindice operativo.
- `metadata-graph.json`: grafo de relaciones entre `artifact_id`.
- `outputs/documental/doc-report.json`: resumen documental para herramientas visuales.
- `outputs/documental/doc-report.md`: lectura Markdown del reporte.

## Capa Visual

`matplotlib` y `reportlab` pertenecen a la capa de presentacion. Deben consumir
JSON validado o indices generados, no inferir canon desde archivos sueltos.

## Workflows Versionados

- Workflows versionados: [`meta-validate`](../../.github/workflows/meta-validate.yml), [`build-graph`](../../.github/workflows/build-graph.yml) y [`promote`](../../.github/workflows/promote.yml).
