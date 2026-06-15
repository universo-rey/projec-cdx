# Control Total .codex 20260615

## Estado

`GREEN_OPERABLE`

## Resumen Vivo

- Carpetas directas en `.codex`: `45`
- Archivos directos en `.codex`: `34`
- Entradas directas en `.codex`: `79`
- Carpetas versionadas en `.codex`: `25`
- Versionadas por superficie: `catalogo-local=6; hitos=19`
- Carpetas recursivas en `.codex`: `10,752`
- Archivos recursivos en `.codex`: `59,526`
- Entradas recursivas en `.codex`: `70,278`

## Lectura

- `catalogo-local` y `hitos` son las superficies versionadas vivas que concentran versiones.
- El resto de `.codex` mezcla superficie viva, cache, estado, evidencia y soporte.
- Este control solo cuenta nombres y estructura; no lee contenidos sensibles.
- Guardrail externo vigente: no compactar, mover ni borrar `.codex` sin orden atomica; el semaforo ecosistemico ya queda operable por esta frontera.

## Comando

```powershell
pwsh -NoProfile -File "C:\Users\enzo1\PROJEC CDX\tools\codex-control-total.ps1" -ScanCodexRoot
```

## Generador

- [tools/build_codex_root_inventory.py](C:/Users/enzo1/PROJEC%20CDX/tools/build_codex_root_inventory.py)

## Siguiente Paso

- Regenerar este reporte si cambia la estructura de `.codex`.
