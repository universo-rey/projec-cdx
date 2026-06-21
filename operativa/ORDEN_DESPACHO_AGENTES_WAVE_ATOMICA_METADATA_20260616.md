---
artifact_id: operativa/ORDEN_DESPACHO_AGENTES_WAVE_ATOMICA_METADATA_20260616.md
categoria: operativa
tipo: orden
estado: en_revision
version: 2026.06.21
autoridad:
  tipo: owner
  referencia: '@SeshatSgin'
origen: GitHub
ubicacion_repo: operativa/ORDEN_DESPACHO_AGENTES_WAVE_ATOMICA_METADATA_20260616.md
etiquetas:
- operativa
- orden
- metadata
relacionados:
- operativa/MAPA.md
descripcion: Orden de despacho de agentes para wave atomica metadata con trazabilidad
  parcial.
---

# Orden Despacho Agentes Wave Atomica Metadata 20260616

Estado: `DISPATCH_PREPARED`.
Frontera: `TENANT_ONLY`.
Tenant: `Escribania Bitsch`.
Tenant ID: `858a0852-44a1-413e-a0fe-f053949797d6`.
Modo: `metadata_only`.
Live write: `NO`.
Documentos/payloads/secretos: `NO`.

## Huella Atomica

Cada carril debe dejar una huella:

- Atomica: una unidad clara, no una nube.
- Idempotente: se puede releer o reejecutar sin duplicar estado.
- Encadenada: apunta al carril anterior y al siguiente.
- Trazable: declara fuente, proceso, salida, evidencia y stop condition.
- Versionable: genera artefacto o propuesta de artefacto con ruta.
- Energetica: despierta identidad operativa desde la primera linea.
- Canonica: elimina redundancia semantica no alineada.

## Carriles

| agente | carril | lock_key | read_scope | write_scope | evidencia | validador | stop_condition |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Seshat | Canon semantico | `canon_semantico_wave` | `operativa/`, `dataverse/`, `recipes/`, `procesos/`, `patrones/` | propuesta/readback, sin editar canon directamente | lista de reemplazos y estado canonico | `tools/validate_proj_cdx_workbench.ps1` | `semantic_change_requires_owner` |
| Thot | Mapas e indices | `map_index_sync_wave` | mapas, indices, hito metadata wave, skill nueva | propuesta de indices faltantes, sin tocar live | matriz de rutas y gaps | `tools/validate_sdu_dataverse_metadata_wave.ps1` | `index_points_to_missing_file` |
| Anubis | Idempotencia y gates | `idempotent_gate_wave` | hito, matrix, stop conditions, GATE Dataverse | propuesta de gate/checklist, sin apply | tabla idempotency/gate | `tools/validate_sdu_dataverse_metadata_wave.ps1` | `candidate_count_not_one` |
| Maat | Cumplimiento y saneamiento | `compliance_sanitization_wave` | inventarios y readbacks de Microsoft/Dataverse/SGIN | propuesta de saneamiento, sin borrar evidencia | hallazgos sensibles y remedio | `tools/validate_sdu_dataverse_metadata_wave.ps1` | `secret_or_payload_detected` |
| Horus | Riesgo e inferencias | `risk_inference_wave` | crosswalks, candidate counts, SPGovernance, SDU runtime | propuesta de reclasificacion | riesgos por inferencia | `tools/validate_proj_cdx_workbench.ps1` | `metadata_treated_as_execution` |
| Narrador | Identidad energetica | `identity_readback_wave` | readbacks y mapa consolidado | borrador de apertura/cierre, sin tocar archivos | texto breve listo para acta | `tools/validate_proj_cdx_workbench.ps1` | `flat_or_external_voice` |

## Retorno Esperado

Cada agente debe devolver:

```text
agente:
carril:
estado:
huella_atomica:
idempotencia:
cadena:
evidencia:
redundancia_detectada:
canon_propuesto:
riesgo:
rollback:
postcheck:
stop_condition:
proximo_carril:
```

## Fan-In

El owner de integracion es Codex local en `PROJEC CDX`.
No hay self-approval para live writes.
Los resultados vuelven a `operativa/READBACK_FAN_IN_AGENTES_WAVE_ATOMICA_METADATA_20260616.md`.
