# Pack VPS SDU 1 20260619

Molde corto para replicar `SDU 1` en VPS sin reescribir el patron.

## Objetivo

- Llevar la misma estructura de `workbook + hitos + trazas + mapas` a un VPS.
- Mantener la cadena atomica: objetivo -> hito -> evidencia -> siguiente delta.
- Evitar superficies nuevas hasta que exista evidencia y rollback claros.

## Semaforo

- `VERDE_LIVIANO`: se replica el patron ya inventariado.
- `AMARILLO_CONTROLADO`: falta evidencia, falta ruta o hay duda de alcance.
- `ROJO_GOVERNED`: live write, secreto, target ambiguo o rollback ausente.

## Variables

| Clave | Valor |
| --- | --- |
| `VPS_TARGET` | `vps-sdu1` |
| `VPS_OWNER` | `Enzo / Corte SDU` |
| `VPS_GATE` | `metadata-only` |
| `VPS_SOURCE` | `workbook + hitos + trazas + mapas` |
| `VPS_REPLICA_MODE` | `same-pattern-not-rewrite` |
| `VPS_POSTCHECK` | `readback + timestamp + diff` |
| `VPS_ROLLBACK` | `restore previous pack + revert last delta` |
| `VPS_EVIDENCE` | `operativa/TRACE.md` |

## Corte

- `Seshat`: deja el acta corta.
- `Anubis`: protege el stop condition.
- `Maat`: valida evidencia y coherencia.
- `Thot`: comprime aprendizaje en un atomo reusable.
- `Horus`: vigila el horizonte siguiente.

## Ruta

1. Leer `CURRENT.md`.
2. Confirmar semaforo y frontera maxima.
3. Reusar el mismo patron en VPS.
4. Registrar evidencia minima.
5. Cerrar con readback breve.

## Stop Conditions

- falta owner, target, rollback o postcheck
- aparece una superficie nueva
- se intenta escribir live sin gate
- la evidencia no alcanza para cerrar

## Validacion

- existe el pack
- la ruta de replica esta declarada
- el semaforo queda visible
- el siguiente delta queda unico

## Resultado Esperado

`VPS_READY_AS_REPLICA_NOT_REWRITE`
