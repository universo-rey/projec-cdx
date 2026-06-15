# CODEX Atomic Operating Package

Índice maestro del paquete operativo atómico de Codex.

La wave visible mas reciente queda absorbida en [20260615-pr-cierre-atomico-v1](C:/Users/enzo1/PROJEC%20CDX/hitos/20260615-pr-cierre-atomico-v1/README.md).

- [MAPA.md](C:/Users/enzo1/PROJEC%20CDX/atomic/MAPA.md)

## Orden Recomendado

1. [CODEX_ATOMIC_OPERATING_CONTRACT.md](C:/Users/enzo1/PROJEC%20CDX/atomic/CODEX_ATOMIC_OPERATING_CONTRACT.md)
2. [CODEX_ATOMIC_ACTION_MATRIX.csv](C:/Users/enzo1/PROJEC%20CDX/atomic/CODEX_ATOMIC_ACTION_MATRIX.csv)
3. [CODEX_TRANSACTION_LEDGER_SCHEMA.json](C:/Users/enzo1/PROJEC%20CDX/atomic/CODEX_TRANSACTION_LEDGER_SCHEMA.json)
4. [CODEX_IDEMPOTENCY_POLICY.md](C:/Users/enzo1/PROJEC%20CDX/atomic/CODEX_IDEMPOTENCY_POLICY.md)
5. [CODEX_PARTIAL_STATE_POLICY.md](C:/Users/enzo1/PROJEC%20CDX/atomic/CODEX_PARTIAL_STATE_POLICY.md)
6. [CODEX_ATOMIC_VALIDATION_REPORT.md](C:/Users/enzo1/PROJEC%20CDX/atomic/CODEX_ATOMIC_VALIDATION_REPORT.md)
7. [CODEX_ATOMIC_READBACK.md](C:/Users/enzo1/PROJEC%20CDX/atomic/CODEX_ATOMIC_READBACK.md)

## Propósito De Cada Pieza

- `CODEX_ATOMIC_OPERATING_CONTRACT.md`: define la identidad, el gate, el envelope y el cierre terminal.
- `CODEX_ATOMIC_ACTION_MATRIX.csv`: tabla rápida de tipos de acción y validación esperada.
- `CODEX_TRANSACTION_LEDGER_SCHEMA.json`: esquema serializable para registrar transacciones y acciones.
- `CODEX_IDEMPOTENCY_POLICY.md`: reglas para re-ejecución segura sin duplicación.
- `CODEX_PARTIAL_STATE_POLICY.md`: reglas para fallas, residuo parcial y escalamiento.
- `CODEX_ATOMIC_VALIDATION_REPORT.md`: plantilla para validar una ejecución concreta.
- `CODEX_ATOMIC_READBACK.md`: plantilla de readback final y cierre operativo.

## Criterio De Uso

- Usar el contrato antes de cualquier acción mutativa.
- Usar la matriz y el schema antes de registrar o automatizar.
- Usar las políticas cuando haya riesgo de re-ejecución o estado parcial.
- Usar validación y readback al cerrar cada transacción.
- Usar la cobertura atomica energetica cuando una superficie gobernada deba exponer fase e impulso.

## Estado

`CODEX_ATOMIC_OPERATING_MACHINE_READY`
