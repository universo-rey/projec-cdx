# Raiz Disco 20260615

## Objetivo

Reducir `C:\` a carpetas de sistema, la carpeta de trabajo principal y la carpeta `Documents`, manteniendo trazabilidad y sin tocar rutas sensibles.

## Estado Observado

La raiz de `C:\` quedo reducida a carpetas de sistema y a la superficie base de usuario.

## Movido

- `Archivos Recuperados`
- `cdf_gate68_solution_clone`
- `hp`
- `Reorganizacion`
- `Riot Games`
- `sdu9`
- `sdups`
- `sduwt`
- `tcu03s`
- `tcu03t`
- `tcu03u`
- `tcu03v`
- `tcu05ao`
- `tcu05m`
- `tcu05n`
- `tcu05q`

## Mantener En Raiz

- `$Recycle.Bin`
- `Archivos de programa`
- `Config.Msi`
- `Documents and Settings`
- `inetpub`
- `OneDriveTemp`
- `PerfLogs`
- `Program Files`
- `Program Files (x86)`
- `ProgramData`
- `Recovery`
- `System Volume Information`
- `System.Sav`
- `Users`
- `Windows`

## Relacion De Destinos

- Carpetas de trabajo o recuperacion: `C:\Users\enzo1\Documents\Maquina de Trabajo`
- Carpetas tipo repositorio: `C:\Users\enzo1\Documents\GitHub`
- Carpetas de soporte Codex: `C:\Users\enzo1\Documents\Codex`

## Cierre

La limpieza de `C:\` quedo completada sin tocar carpetas de sistema ni superficies de `C:\Users\enzo1\.codex`.

## Regla

- No mover carpetas del sistema.
- No mover nada de `.codex`.
- Cualquier movimiento debe dejar evidencia en inventarios y en `hitos/` si el cambio es durable.
