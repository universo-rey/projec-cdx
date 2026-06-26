# Ancla Rehidratacion Dataverse

Ancla corta para recuperar contexto Dataverse cuando un hilo se alarga o se pierde continuidad.

Se abre solo desde [ANCLAS_ON_DEMAND.md](C:/Users/enzo1/PROJEC%20CDX/operativa/archive/legacy-root/undated/ANCLAS_ON_DEMAND.md) cuando el frente necesita volver a la base Dataverse sin reinventar contexto.

## Orden

1. Leer `hitos/20260615-sincronizacion-tiempo-real-v1/README.md`.
2. Leer `dataverse/GATE.md`.
3. Leer `dataverse/README.md`.
4. Leer `dataverse/MAPA.md`.
5. Leer `dataverse/MATRIZ_CADENA_OPERATIVA_DATAVERSE_20260615.md`.
6. Leer `dataverse/PLAN_SEGUNDA_PASADA.md`.
7. Leer `operativa/archive/legacy-root/undated/ANCLA_AGENTES_ATOMICOS_ALGORITMICOS.md` si la wave se va a repartir en agentes.
8. Si el delta toca archivo, leer `hitos/INDICE_MAESTRO.md` y `hitos/_archivo/README.md`.
9. Si el hilo sigue abierto, leer `operativa/TRACE.md` y `operativa/archive/legacy-root/undated/PROMPT_NUEVO_HILO.md`.

## Regla

- Rehidratar no es tocar live.
- Si falta ambiente, org o target exacto, quedarse en local evidence o metadata-only.
- Si aparece live, volver al gate con owner, rollback, postcheck y evidencia.

## Flujo

1. Recuperar el estado local confirmado.
2. Identificar la superficie exacta que sigue viva.
3. Clasificar el siguiente delta como local, metadata-only, preparado o live.
4. Reflejar solo la pieza tocada.
5. Validar con `tools/validate_proj_cdx_workbench.ps1`.

## Stop Condition

- Falta gate.
- Falta evidencia.
- Falta target.
- Se intenta inferir live sin orden explicita.
