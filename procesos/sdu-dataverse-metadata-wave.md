# Proceso SDU Dataverse Metadata Wave

## Entrada

- Readbacks `OBSERVED_READ_ONLY`.
- Inventarios vivos sanitizados.
- Frontera de tenant y ambiente.
- Pedido de mejorar mapas, recetas, skills, procesos y metadata Dataverse.

## Pasos

1. Confirmar tenant y ambiente.
2. Clasificar cada superficie como `confirmada`, `observada`, `inferida` o `fuera_de_alcance_actual`.
3. Preparar metadata en filas atómicas.
4. Declarar rollback y postcheck incluso si no hay write.
5. Promover el aprendizaje a skill, receta, proceso, patron o tool.
6. Registrar fan-in de agentes.
7. Correr validadores.

## Salida

- Matriz metadata-only.
- Hito versionado.
- Skill reutilizable.
- Proximo delta unico.

## Cierre

El proceso cierra como `METADATA_ONLY_PREPARED` si no hubo writes y el validador pasa.
