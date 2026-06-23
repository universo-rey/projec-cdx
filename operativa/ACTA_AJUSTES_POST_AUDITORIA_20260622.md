---
artifact_id: operativa/ACTA_AJUSTES_POST_AUDITORIA_20260622.md
categoria: operativa
tipo: acta
estado: aprobado
version: v0.6.0-rc1
fecha_evento: '2026-06-22'
autoridad:
  tipo: sistema
  referencia: CABINA_GOBIERNO_TOTAL
origen: Mixto
ubicacion_repo: operativa/ACTA_AJUSTES_POST_AUDITORIA_20260622.md
etiquetas:
  - auditoria
  - ajustes
  - gates
  - versionado
relacionados:
  - operativa/ACTA_AUDITORIA_INTEGRAL_CORTE_20260622.md
  - operativa/MATRIZ_AJUSTES_POST_AUDITORIA_20260622.csv
  - operativa/GATE_REGISTRY_G1_G31_20260622.csv
  - VERSION_POLICY.md
  - .github/workflows/promote.yml
descripcion: Acta de cierre de ajustes estructurados posteriores a la auditoria integral de corte.
---

# ACTA AJUSTES POST AUDITORIA

## Estado

`AJUSTES_IMPLEMENTADOS`

## Hallazgos originales

1. `promote.yml` tenia permiso de escritura manual sin campo explicito de owner gate.
2. `pyproject.toml` conservaba version `0.1.0` mientras el release institucional vigente es `v0.6.0-rc1`.
3. La auditoria no encontro una tabla unica G1-G31.

## Ajustes aplicados

| Ajuste | Resultado |
| --- | --- |
| `APA-001` | `promote.yml` exige `owner_gate_id` y confirmacion booleana de owner gate antes de promover. |
| `APA-002` | `pyproject.toml` queda en `0.6.0rc1` y `VERSION_POLICY.md` documenta el mapeo PEP 440. |
| `APA-003` | Se crea `operativa/GATE_REGISTRY_G1_G31_20260622.csv` con G1-G6 cerrados y G7-G31 reservados/no asignados. |

## Historytelling

La Corte detecto riesgo controlado, no bloqueo. El ajuste posterior no cambio la frontera live: tomo los hallazgos como deuda accionable, redujo ambiguedad de promocion, alinio version institucional con paquete Python y materializo el registry G1-G31 para que ningun gate futuro opere por inferencia.

## Frontera

- No live.
- No push.
- No PR.
- No workflow dispatch.
- No secretos.

## Resultado

`POST_AUDIT_ADJUSTMENTS_READY_FOR_VALIDATION`
