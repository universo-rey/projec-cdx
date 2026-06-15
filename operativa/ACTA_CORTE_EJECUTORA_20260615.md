# Acta De Corte Ejecutora

Fecha: 2026-06-15

## Tipo De Acta

Declaracion local de mesa activa. No implica write live, ni activacion de entorno, ni cambio fuera del workbench.

## Roster Canonico

- `seshat-normativa` - frente, canon y conduccion del acta
- `thot-tecnico` - contrato, esquema, evidencia tecnica
- `anubis-gate` - gate, freno y cierre formal
- `maat-cumplimiento` - cumplimiento y trazabilidad
- `horus-riesgo` - riesgo, rollback y postcheck
- `narrador-normativo` - readback, continuidad y registro

## Marco Operativo

- Frente activo: `CORTE_EJECUTORA_GOVERNED`
- Estado: declarativo, gobernado, sin live por inferencia
- Regla: un solo frente, una sola decision formal, una sola salida
- Cierre valido solo con target exacto, owner, rollback, postcheck, evidencia y stop condition

## Lectura

- La mesa queda activada como carril de gobierno, no como ejecucion ciega.
- Si aparece un target live unico, se arma un packet minimo y se resuelve bajo gate.
- Si el target no es unico, el estado correcto sigue siendo `PENDING_TARGET_ONLY`.
- Esta corte tambien registra su propia obra: cada tramo que se activa aqui debe quedar asentado en acta, trace y cierre.

## Cierre

- Esta acta fija la mesa para continuar sin reiniciar contexto.
- La referencia de continuidad sigue en `operativa/TRACE.md`.
