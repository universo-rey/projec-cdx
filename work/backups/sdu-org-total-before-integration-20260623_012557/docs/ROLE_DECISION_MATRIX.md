# Matriz de decisión de agentes

| Rol | Agente ideal | Obligatorio | Fallback | Bloquea ejecución si falta |
|---|---|---:|---|---:|
| Router/Orquestador | SESHAT | Sí | agente con funciones de clasificación, canon, memoria o router | Sí, salvo stub declarativo |
| Arquitectura técnica | THOT | Sí | agente con funciones de arquitectura, configuración o esquemas | No, si SESHAT + ANUBIS están presentes |
| Guard/Gate | ANUBIS | Sí | agente con funciones de seguridad, rollback o permisos | Sí |
| Evidencia/Auditoría | MAAT | Recomendado | auditor, cumplimiento, evidencia | No |
| Observabilidad/Drift | HORUS | Recomendado | sentinel, riesgo, observabilidad | No |

## Regla de mínimo

La ejecución requiere al menos tres roles cubiertos:

1. Router/Orquestador.
2. Clasificación/Arquitectura.
3. Guard/Gate.

## Regla de ideal

La ejecución ideal cubre cinco agentes: SESHAT, THOT, ANUBIS, MAAT y HORUS.
