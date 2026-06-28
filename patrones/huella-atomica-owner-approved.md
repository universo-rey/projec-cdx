# Huella Atomica Owner Approved

## Patron

Una orden viva del owner puede promover una huella atomica a canon tenant y a
Dataverse cuando existe tenant, entorno, owner, target, rollback, postcheck y
evidencia.

## Regla

- Bloqueo real: solo por autoridad humana.
- Condicion tecnica: delta gobernado, revision o proximo paso.
- Dataverse: memoria estructural de largo plazo.
- Codex/agentes: consumidores de huella, no fuente de autoridad.

## Stop Condition Como Delta

| condicion tecnica | delta |
| --- | --- |
| `candidate_count_not_one` | desambiguar target |
| `target_identity_ambiguous` | ejecutar candidate count estructurado |
| `rollback_missing` | agregar rollback antes de write |
| `postcheck_missing` | agregar postcheck antes de cierre |
| `secret_detected` | sanear o excluir payload |
| `live_write_missing_order` | pasar a `live_requires_gate` |

## Evidencia

`operativa/READBACK_PROMOCION_HUELLA_ATOMICA_TENANT_DATAVERSE_20260616.md`
