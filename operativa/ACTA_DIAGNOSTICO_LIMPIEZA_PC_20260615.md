# Acta Diagnostico Limpieza Pc 20260615

## Estado

- Fecha: 2026-06-15
- Alcance: diagnostico local para cierre de limpieza
- Resultado: `DIAGNOSTICO_REGISTRADO`
- Limpieza ejecutada: no
- Motivo: faltaba el gate explicito para tocar `Temp` o cerrar procesos

## Evidencia

- Ruta de evidencia: `C:\Users\enzo1\CodexLocal\OPTIMIZACION_PC\OPT_PC_SKILL_20260615_091635`
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

## Cierre

- No se toco `Temp`
- No se cerraron procesos
- No se desactivaron arranques
- La limpieza queda pendiente de gate explicito si se quiere ejecutar
