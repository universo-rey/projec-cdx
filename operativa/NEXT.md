# Next

Siguiente movimiento unico para `PROJEC CDX`.

## Paso Siguiente

No hay movimiento obligatorio adicional en esta ronda.

Si aparece un nuevo hijo de `Auditar` o un nuevo delta documental, todo trabajo debe entrar por `operativa/NEXT.md`, registrar fuente -> proceso -> salida -> hito -> cierre y validar con:

```powershell
pwsh -NoProfile -File "C:\Users\enzo1\PROJEC CDX\tools\validate_proj_cdx_workbench.ps1"
```

## Resultado Esperado

Una nueva entrada versionada solo si aparece una superficie nueva.

## Criterio De Cierre

- `TRACE.md` registra fuente, proceso, salida, hito y cierre.
- `BLOCKERS.md` queda sin bloqueo activo o con bloqueo real nombrado.
- `validate_proj_cdx_workbench.ps1` devuelve `PASS`.
