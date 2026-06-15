# Playbook 06 - Dataverse Gobernado

## Objetivo

Trabajar Dataverse sin confundir evidencia local, metadata-only, preparado y live.

## Pasos

1. Leer `dataverse/GATE.md`.
2. Clasificar el pedido: local evidence, metadata-only, prepared, live read o live write.
3. Si es live, confirmar ambiente, org, target, owner, rollback, postcheck y evidencia.
4. Si falta alguno, detener con stop condition.
5. Registrar salida en `operativa/TRACE.md`.
6. Si la salida nace de una frontera del workbook, derivar a `playbooks/07-dataverse-fronteras.md`.

## Cierre

El delta Dataverse esta cerrado cuando declara estado y evidencia sin inferencia.
