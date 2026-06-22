---
artifact_id: operativa/W6_OPENAI_SECURITY_BOUNDARY_20260622.md
categoria: operativa
tipo: reporte
estado: en_revision
version: 2026.06.22
autoridad:
  tipo: owner
  referencia: '@SeshatSgin'
origen: Mixto
ubicacion_repo: operativa/W6_OPENAI_SECURITY_BOUNDARY_20260622.md
etiquetas:
- cabina
- openai
- security
- w6
relacionados:
- operativa/W6_OPENAI_DEVELOPERS_LANE_MATRIX_20260622.csv
- operativa/W6_EVAL_HARNESS_GATE_MATRIX_20260622.csv
descripcion: Frontera de seguridad W6 para OpenAI Developers, API key y eval harness.
fecha_evento: '2026-06-22'
---

# W6 OPENAI SECURITY BOUNDARY

## Regla

OpenAI puede ser capacidad auxiliar gobernada, no autoridad ni memoria canonica.

## Bloqueado por defecto

- Imprimir claves o .env.local.
- Crear clave nueva sin gate.
- Llamada API sin objetivo, payload, sensibilidad, costo y rollback.
- Vector store, file search o upload externo sin manifest.
- Datos regulados o raw export.

## Permitido sin live

- Consultar docs y skills.
- Preparar matrices, prompts, schemas y evals sinteticos.
- Registrar gates y stop conditions.

## Stop condition

Cualquier secreto, costo, live call, upload o dato sensible sin gate detiene la lane.
