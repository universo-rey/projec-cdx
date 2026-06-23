# TOP001 Monitoring Runbook

## Objetivo

Dar observabilidad operativa a sesiones Codex, agentes y herramientas sin versionar traces crudos ni exponer secretos.

## Check Diario Manual

1. Revisar `git status --short`.
2. Confirmar staging vacio antes de cualquier nuevo carril.
3. Revisar readbacks recientes en `.cabina/organizacion-total/out`.
4. Confirmar si hay acciones reales, remotas o live propuestas.
5. Confirmar secret scan antes de cierre.
6. Registrar drift como riesgo u oportunidad.

## Politicas

- Traces crudos quedan locales y no versionables.
- Logs no se suben.
- Readbacks saneados pueden proponerse como versionables.
- Si aparece secreto material, detener y reportar sin mostrarlo.
- Si una accion pasa de declarativa a real, requiere gate.

## Senales A Vigilar

- Compaction cercana sin handoff.
- Staging no vacio fuera de carril de commit.
- Nuevos conectores con secretos.
- Automatizaciones sin cola humana.
- Evidencia cruda mezclada con documentos versionables.

## Resultado Esperado

Cada operacion deja una memoria breve: que se hizo, que no se hizo, que queda pendiente, que gate falta y cual es la siguiente accion reversible.
