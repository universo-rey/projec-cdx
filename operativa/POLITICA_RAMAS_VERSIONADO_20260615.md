# Politica de Ramas y Versionado 20260615

## Estado

`CANON_OPERATIVO`

## Proposito

Definir una politica minima y estable para trabajar con ramas, worktrees y versionado durable sin mezclar carriles.

## Principios

- `main` es la linea canonica de integracion.
- Cada delta mutable trabaja en una sola rama y, si hace falta, en un solo worktree.
- La rama de trabajo debe quedar aislada del root canonico.
- Un delta durable no se da por cerrado solo con commit: debe dejar evidencia y, cuando corresponda, hito versionado.
- `hitos/` versiona el cierre durable; Git versiona el cambio tecnico; `operativa/` versiona la traza y el control.
- No se reescribe historia compartida.
- No se borra una rama historica sin orden explicita.
- No se mezclan cambios de dos lanes en una misma rama.

## Ciclo Operativo

1. Abrir una rama `codex/<tema>` o `codex/<tema>-<YYYYMMDD>` para el trabajo mutable.
2. Trabajar en un worktree aislado cuando el delta toque archivos sensibles o cambios amplios.
3. Mantener un solo lane activo por rama.
4. Registrar fuente, proceso, salida, evidencia y rollback en `operativa/TRACE.md`.
5. Validar antes de cerrar.
6. Si el resultado es durable, crear o actualizar el hito correspondiente en `hitos/`.
7. Integrar a `main` solo cuando no haya conflictos con cambios vivos que deban preservarse.
8. Archivar ramas historicas en `operativa/ACTA_ARCHIVO_RAMAS_HISTORICAS_20260615.md` o su matriz si dejan de ser activas.

## Reglas De Rama

- Rama nueva por lane nueva.
- Una rama no absorbe dos objetivos distintos.
- Una rama compartida se protege con evidencia y no con memoria.
- Si `main` tiene cambios vivos ajenos, se preservan primero y no se pisan.
- No usar `force push` ni `reset --hard` sobre ramas compartidas.
- No borrar ramas historicas sin archivo previo.

## Reglas De Versionado

- Lo vivo queda en la rama de trabajo.
- Lo durable queda en `hitos/`.
- Lo operativo queda en `operativa/`.
- Lo historico queda en el archivo o la matriz de ramas historicas.
- Un cambio queda realmente versionado cuando tiene referencia, evidencia y cierre reproducible.

## Stop Conditions

- `main` sucio y no preservado.
- Conflicto entre cambios del lane actual y cambios ajenos.
- Intento de mezclar dos deltas en una sola rama.
- Falta de evidencia, validacion o rollback.
- Intento de borrar o reescribir historia compartida sin orden explicita.

## Resultado

El trabajo queda aislado, versionado y retomable sin perder la separacion entre lane mutable, cierre durable e historico.
