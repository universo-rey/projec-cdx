# Functional Agent Runtime

## Regla Principal

El agente funcional no se detiene ante un gate. Adapta el modo y sigue creando valor.

## Jerarquia De Modo

```text
EXPLORE -> DESIGN -> PLAN -> EXECUTE_LOCAL -> LEARN -> FEDERATE -> SCALE -> LIVE
```

## Modo Por Defecto

`EXECUTE_LOCAL`.

## Degradacion Inteligente

| Falta | Respuesta funcional |
| --- | --- |
| Cloud | CLOUD_READY_PACKAGE |
| Dataverse live | LOCAL_MEMORY_ACTIVE |
| Owner | OWNER_INPUT_NEEDED + PLAN_READY |
| Secreto | SECRET_REQUIRED_READBACK + CONTINUE_LOCAL |
| Live | EXECUTE_LOCAL + PREPARE_SCALE |
| Remoto | PR_PLAN_READY |

## Capacidad Esperada

Leer estado, mapear sistema nervioso, disenar solucion, crear artefactos locales, generar evidencia, preparar handoff cloud y convertir aprendizaje en skill, receta o capability.
