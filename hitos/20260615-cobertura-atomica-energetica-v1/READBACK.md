# READBACK_COBERTURA_ATOMICA_ENERGETICA_20260615

## Estado

HECHO_VERIFICADO: se introdujo el elemento atomico energetico como contrato visible de cobertura.

## Sistemas Tocados

- `PROJEC CDX/operativa/archive/legacy-root/20260615/COBERTURA_ATOMICA_ENERGETICA_20260615.md`.
- `PROJEC CDX/operativa/archive/legacy-root/undated/ANCLA_ENERGIA_ATOMICA.md`.
- `PROJEC CDX/atomic/CODEX_ATOMIC_OPERATING_CONTRACT.md`.
- `PROJEC CDX/atomic/README.md`.
- `PROJEC CDX/atomic/MAPA.md`.
- `PROJEC CDX/README.md`.
- `PROJEC CDX/README_CORTO.md`.
- `PROJEC CDX/MAPA_CORTO.md`.
- `PROJEC CDX/operativa/README.md`.
- `PROJEC CDX/operativa/README_CORTO.md`.
- `PROJEC CDX/operativa/MAPA_CORTO.md`.
- `PROJEC CDX/operativa/CURRENT.md`.
- `PROJEC CDX/operativa/TRACE.md`.
- `PROJEC CDX/operativa/archive/legacy-root/20260615/NOMENCLATURA_CADENA_OPERATIVA_20260615.md`.
- `PROJEC CDX/operativa/archive/legacy-root/undated/ANCLAS_ON_DEMAND.md`.
- `PROJEC CDX/hitos/README.md`.
- `PROJEC CDX/hitos/MAPA.md`.
- `PROJEC CDX/hitos/INDICE_MAESTRO.md`.
- `PROJEC CDX/hitos/INDICE_MAESTRO.csv`.

## Sistemas No Tocados

- Secretos.
- `auth.json`.
- `cap_sid`.
- Global-state.
- SQLite.
- Dataverse live.
- Power Platform live.
- Git remoto.

## Cambios

- Se formalizo la cobertura atomica energetica en una matriz visible.
- Se abrio un ancla minima para introducir la energia en nuevas waves.
- Se endurecio el contrato atomico base para declarar fase e impulso.
- Se versiono la wave con hito propio.

## Validacion

- `tools/validate_proj_cdx_workbench.ps1`

## Riesgos

- Las superficies generadas pueden referenciar el contrato, no copiarlo entero.
- El elemento energetico no autoriza live writes por inferencia.

## Rollback

Retirar la matriz, el ancla, el hito y las referencias si el usuario decide no sostener esta cobertura.

## Proximos Carriles

- Extender la firma energetica a las plantillas nuevas.
- Mantener la energia en la primera lectura visible de cada wave.
