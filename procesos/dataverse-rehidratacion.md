# Dataverse Rehidratacion

## Entrada

Hilo largo, contexto perdido o carril Dataverse que necesita volver a una base verificable.

## Pasos

1. Leer `hitos/20260615-sincronizacion-tiempo-real-v1/README.md`.
2. Leer `dataverse/INDICE_DATAVERSE.md`.
3. Leer `dataverse/GATE.md`.
4. Leer `dataverse/README.md` y `dataverse/MAPA.md`.
5. Leer `dataverse/MATRIZ_CADENA_OPERATIVA_DATAVERSE_20260615.md`.
6. Leer `dataverse/PLAN_SEGUNDA_PASADA.md`.
7. Leer `operativa/ANCLA_AGENTES_ATOMICOS_ALGORITMICOS.md` si el trabajo se va a repartir en waves.
8. Si el delta toca archivo, leer `hitos/INDICE_MAESTRO.md` y `hitos/_archivo/README.md`.
9. Clasificar el delta en local, metadata-only, preparado o live.
10. Reflejar solo la pieza tocada.
11. Validar con `tools/validate_proj_cdx_workbench.ps1`.

## Salida

Carril rehidratado, breve y navegable.

El archivo historico de hitos queda separado del carril vivo y se reingresa solo por el indice maestro.

## Stop Condition

`no_gate`, `no_evidence`, `no_target`, `live_by_inference`
