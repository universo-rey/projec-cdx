# SDU_ENV_DIFF

## Baseline correcto
- Baseline recomendado: `C:\Users\enzo1\PROJEC CDX\outputs\sdu-environment-audit\sdu-environment-audit.json`
- Motivo: expone metadata de host completa, `PATH` mas amplio, `PSReadLine`, mas tareas visibles y `system.volumes`.

## Desviaciones
- `CODEX_*`: 22 variables solo en user y 2 solo en elevated.
- `PATH`: 1 entradas solo en user y 12 solo en elevated; elevated agrega toolchains y duplica `rg`.
- `PSModulePath`: sin drift neto tras normalizar; el segmento vacio del user no cambia el set efectivo.
- `tasks.all`: elevated muestra 89 tareas adicionales, todas esperables por visibilidad ampliada.
- `processes.all`: mismo universo de nombres casi completo; cambian PIDs y visibilidad de `Path`, lo que es volatilidad de runtime.

## Riesgos
- `computer.hostname` es `null` en la sesion user.
- Faltan 22 variables de sistema estandar en la sesion user.
- Servicio `gpsvc` cambia de `Stopped -> Running`.
- Servicio `wuauserv` cambia de `Stopped -> Running`.
- `system.drives.FreeSpace` cambio por 9302016 bytes entre capturas.

## Recomendaciones
1. Usar la sesion elevada como baseline para identidad del host y variables de sistema.
2. Normalizar `PATH` y `PSModulePath` antes de comparar o persistir estado.
3. No usar PIDs como criterio de drift estructural.
4. Revisar por que `hostname` y variables de sistema faltan en la captura user.
5. Investigar si `gpsvc` y `wuauserv` reflejan un cambio real o solo timing entre capturas.
