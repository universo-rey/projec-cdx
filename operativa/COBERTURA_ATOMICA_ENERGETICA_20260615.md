# Cobertura Atomica Energetica

Contrato corto para introducir el elemento atomico energetico en `PROJEC CDX`.

## Regla Base

- Las superficies gobernadas deben declarar una energia atomica visible.
- Las superficies de referencia pueden enlazar la energia en vez de duplicarla.
- Las superficies generadas o residuales no fuerzan el mismo encabezado, pero no deben contradecir la regla.

## Elementos Minimos

- `atomic_energy_phase`
- `atomic_next_impulse`
- `atomic_terminal_state`
- `atomic_idempotency_key` cuando la superficie ejecute o registre una transaccion

## Cobertura

| superficie | condicion | elemento minimo | nota |
| --- | --- | --- | --- |
| `README.md`, `README_CORTO.md`, `MAPA_CORTO.md`, `MAPA_MAESTRO.md`, `MAPA_CAPAS.md` | entrada visible | referencia al contrato energetico | la raiz debe decir donde vive la energia |
| `operativa/*.md` | gobierno local | declaracion de fase y proximo impulso | `CURRENT`, `TRACE`, `ANCLAS_ON_DEMAND` y compania |
| `hitos/*` | version durable | readback con energia visible | el hito debe absorber la wave y su fase |
| `recipes/*.md` | reutilizable | fase, impulso y stop condition | la receta debe poder repetirse sin adivinar |
| `procesos/*.md` | ejecutable | entrada, pasos, salida y energia | el proceso debe tener cierre verificable |
| `atomic/*` | contrato base | contrato energetico completo | es la fuente mas explicita del elemento |
| `tools/*.ps1`, `tools/*.mjs`, `scripts/*` | accion automatizable | comentario o README de energia | el script no queda mudo sobre su energia |
| `skills/*`, `agents/*`, `plugins/*` | capacidad invocable | foco, impulso y stop condition | la invocacion debe decir para que empuja |
| `outputs/*`, `inventarios/*` | evidencia o soporte | referencia al contrato | no se fuerza duplicacion en artefactos generados |

## Uso

1. Identificar la superficie.
2. Decidir si es gobernada, de referencia o generada.
3. Declarar la energia minima que le corresponde.
4. Apuntar al contrato energetico en la primera entrada visible.
5. Validar con el validador local.

## Stop Condition

- Falta contrato energetico.
- Falta fase atomica.
- Falta proximo impulso.
- Se intenta tratar una superficie gobernada como si fuera residual.
