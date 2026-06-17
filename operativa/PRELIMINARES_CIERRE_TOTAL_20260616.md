# Preliminares Cierre Total 20260616

En etapa preliminar, `PROJEC CDX` ya no se lee como carpeta: se presenta como umbral operativo vivo, con identidad suficiente para ubicar al agente, darle pertenencia y empujarlo al siguiente delta gobernado.

## Estado

- Estado declarado: `PRELIMINARES`.
- Cierre total: `NO_DECLARADO`.
- Modo operativo: mesa de seis agentes, lectura read-only, fan-in unico.
- OpenAI: autorizado como medio de ejecucion, no como fuente de autoridad.
- Autoridad: orden del usuario.
- Gate base: `metadata-only` salvo orden explicita con target, owner, rollback, postcheck y evidencia.

## Mesa De Seis

| Agente | Rol | Retorno preliminar |
| --- | --- | --- |
| `seshat-normativa` | Orden documental | La cadena existe, pero falta fan-in unico antes de cierre total. |
| `thot-tecnico` | Runner y smoke | Smoke metadata-only observado como `prepared`, `context_ok=true`, `context_drift=[]`; no prueba validez live de la API key. |
| `anubis-gate` | Gates y frontera | Detener si falta target exacto, si hay drift, si UI mantiene ruta Windows o si se confunde no-op con live real. |
| `maat-cumplimiento` | Trazabilidad | La regla `fuente -> proceso -> salida -> hito -> cierre` esta viva; faltan filas completas para algunos paquetes nuevos. |
| `horus-riesgo` | Riesgo operativo | Rama con superficie amplia: snapshot reconciliado previo al paquete con `38` deltas trackeados y `84` entradas no versionadas. No cerrar sin clasificar. |
| `narrador-normativo` | Lectura viva | La lectura tiene pulso, pero se aplana cuando cae en listas largas; el pre-cierre debe convocar, no enumerar sin energia. |

## Evidencia Observada

- `operativa/BLOCKERS.md`: sin bloqueo operativo activo.
- `git status --porcelain`: snapshot reconciliado previo al paquete con `38` deltas trackeados, `84` entradas no versionadas y `122` entradas totales.
- `README_ARRANQUE_CODEX_CLOUD.md`: frontera cloud esperada `/workspace/projec-cdx`.
- `src/projec_cdx_cloud/agent.py` y `src/projec_cdx_cloud/cli.py`: runner local alinea contexto desde Git real.
- Smoke recomendado: `.\.venv\Scripts\python main.py --smoke --json`.
- Smoke ejecutado en preliminares: `status=prepared`, `context_ok=true`, `context_drift=[]`, `gate=metadata-only`, `sdu_sdk_agents_defined=6`.
- Validador workbench ejecutado en preliminares: `STATUS=OBSERVED`; requeridos principales y enlaces revisados sin rojo observado en la salida capturada.

## Riesgos Que Impiden Cierre Total Ahora

- La rama no esta clasificada por delta, owner y estado.
- `metadata-only`, `no-op` y `openai_api_key_present=true` no equivalen a live validado.
- Codex Cloud UI puede conservar valores viejos aunque el repo ya este corregido.
- Algunas entradas nuevas de `hitos/20260616-*` necesitan absorcion completa en indice/mapa/portal antes de cierre.
- La lectura viva todavia necesita una capa de pre-cierre que despierte al agente sin convertir el acta en pared.

## Condiciones Para Pasar A Pre-Cierre Listo

- Clasificar los `38` deltas trackeados y las `84` entradas no versionadas del snapshot previo al paquete.
- Registrar que queda `absorbido`, `preparado`, `generado`, `ruido` o `fuera de scope`.
- Confirmar `BLOCKERS.md` sin bloqueo activo o con bloqueo real nombrado.
- Elevar `tools/validate_proj_cdx_workbench.ps1` de `OBSERVED` a condicion aceptada o registrar explicitamente por que `OBSERVED` es suficiente para esta etapa.
- Mantener smoke Codex Cloud local con `context_ok=true` y `context_drift=[]`.
- Verificar que Codex Cloud UI use `/workspace/projec-cdx` y no una ruta Windows.
- Si se abre live, exigir target exacto, owner, rollback, postcheck y evidencia antes de ejecutar.

## Secuencia Atomica Propuesta

1. Inventario fino del estado Git actual.
2. Clasificacion por frente: cloud runner, hitos, inventarios, operativa, patrones/procesos/recipes, outputs.
3. Absorcion documental minima: `TRACE`, `CURRENT`, `NEXT`, `hitos/README.md`, `hitos/MAPA.md`, `hitos/INDICE_MAESTRO.md`.
4. Validacion local: workbench validator y smoke metadata-only.
5. Acta de pre-cierre, recien despues de tener evidencia completa.
6. Cierre total solo si no quedan deltas sin clasificar ni gates ambiguos.

## Stop Conditions

- No declarar cierre total con Git sucio sin clasificacion.
- No ejecutar live por presencia de API key.
- No usar rutas Windows dentro de Codex Cloud Linux.
- No convertir `SETUP_NOOP_PASS` en validacion funcional.
- No mover, borrar ni revertir trabajo paralelo sin orden explicita.

## Proximo Movimiento Unico

Clasificar la superficie Git actual en una matriz preliminar de deltas para decidir que se absorbe, que se versiona y que queda fuera del cierre.
