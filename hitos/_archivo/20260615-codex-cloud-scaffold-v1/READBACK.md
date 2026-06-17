# READBACK_PROJEC_CDX_CODEX_CLOUD_SCAFFOLD_20260615

## Estado

HECHO_VERIFICADO: el scaffold de Codex Cloud quedo versionado como hito local.

## Delta Aplicado

- Se declaro el entorno seleccionable en `.codex/environments/environment.toml`.
- Se espejaron los scripts de setup y cleanup para el carril local.
- Se agrego el runner Python con `pyproject.toml`, `main.py` y el paquete `src/projec_cdx_cloud`.
- Se documento el contrato local, la apertura de UI y la receta reusable.

## Validacion

- ```powershell
  @'
  from pathlib import Path
  import tomllib

  base = Path(r"C:\Users\enzo1\PROJEC CDX")
  for rel in ["pyproject.toml", ".codex/environments/environment.toml"]:
      with (base / rel).open("rb") as f:
          tomllib.load(f)
  print("toml_ok")
  '@ | python -
  ```
- `python main.py --smoke --json`
- `git diff --check`

## Siguiente Accion

Seguir solo si aparece un delta real nuevo sobre runner, Dataverse o politica de versionado.
