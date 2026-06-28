# Acta Diagnostico Limpieza Pc 20260615

## Estado

- Fecha: 2026-06-15
- Alcance: diagnostico local para cierre de limpieza
- Resultado: `DIAGNOSTICO_REGISTRADO`
- Limpieza ejecutada: parcial
- Motivo: faltaba el gate explicito para tocar `Temp` o cerrar procesos

## Evidencia

- Ruta de evidencia: `C:/Users/enzo1/CodexLocal/OPTIMIZACION_PC/OPT_PC_SKILL_20260615_091635`
- Validador local: `PASS`
- Modo de corrida: `MatrixOnly`

## Foto Del Equipo

- Sistema: `Microsoft Windows 11 Home Insider Preview Single Language`
- Version: `10.0.26300`
- Build: `26300`
- Ultimo arranque: `2026-06-11T22:36:49.232275-03:00`
- RAM total visible: `7.35 GB`
- RAM libre visible: `0.45 GB`
- Disco `C:` libre: `92.4 GB`
- Temp medido por la corrida: `926.20 MB`

## Hallazgos

- Startup detectado: `10` elementos
- Procesos detectados: `533`
- Mayores consumidores visibles:
  - `Memory Compression` `803.43 MB`
  - `Codex` `586.96 MB`
  - `OmenCommandCenterBackground` `198.86 MB`
  - `MsMpEng` `192.74 MB`
  - `Codex` `124.62 MB`
  - `codex` `109.86 MB`

## Continuacion

- `Business3` no existe como cuenta activa en `HKCU:\Software\Microsoft\OneDrive\Accounts`; queda como residuo en `settings/Business3`.
- Cuentas activas de OneDrive:
  - `Business1` = `ESCRIBANIA BITSCH`
  - `Business2` = `Modo On`
- Criterio de carga: conservar `Business1` como base y tratar `Business2` como candidata a pausa si hace falta bajar consumo.
- Limpieza `Temp` parcial:
  - antes: `17.4 MB` de archivos viejos visibles en esta pasada
  - borrados: `24`
  - bloqueados: `15`
  - remanente viejo: `8.7 MB`
- Los bloqueos corresponden a temporales muy antiguos en `Temp`, con acceso denegado al intentar borrar.
- La causa mas precisa es doble: la sesion corre en `Medium Mandatory Level` sin elevacion efectiva, y los temporales estan asociados al ecosistema Adobe vivo (`AcroTray`, `AdobeCollabSync`, `AdobeUpdateService`, `AdobeARMservice`).

## Cierre

- `Temp` se limpio parcialmente con archivos viejos autorizados.
- No se cerraron procesos
- No se desactivaron arranques
- Quedan 15 temporales bloqueados por acceso denegado.
- La limpieza adicional queda pendiente de gate explicito si se quiere ejecutar
- Para borrar los remanentes hace falta elevacion real o cierre del carril Adobe que los retiene.
- Gate preparado: `C:/Users/enzo1/CodexLocal/OPTIMIZACION_PC/OPT_PC_SKILL_20260615_091635/GATE_LIMPIEZA_TEMP_ADOBE.md`
- Ejecucion intentada: carril Adobe de usuario cerrado, pero la sesion sigue sin elevacion y los 15 remanentes continúan bloqueados por `AccessDenied`.
