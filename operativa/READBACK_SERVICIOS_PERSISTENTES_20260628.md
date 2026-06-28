---
artifact_id: operativa/READBACK_SERVICIOS_PERSISTENTES_20260628.md
categoria: operativa
tipo: readback
estado: live
version: 2026.06.28
autoridad:
  tipo: owner
  referencia: '@SeshatSgin'
origen: GitHub
ubicacion_repo: operativa/READBACK_SERVICIOS_PERSISTENTES_20260628.md
etiquetas:
- operativa
- servicios
- persistentes
- readback
- evidencia
relacionados:
- operativa/README.md
- operativa/READBACK_NOC_CONTENCION_20260628.md
- operativa/ACTA_DIAGNOSTICO_LIMPIEZA_PC_20260615.md
descripcion: Readback de inventario y contencion de servicios persistentes on-demand sin elevacion admin.
---

# READBACK_SERVICIOS_PERSISTENTES_20260628

## Estado
HECHO_VERIFICADO: se inventariaron servicios persistentes y se intento recorte conservador; la sesion actual no tiene permisos para detener o deshabilitar varios servicios protegidos.

## Sistemas tocados
- Lectura de `Get-Service`, `Get-Process`, `Get-WinEvent` y listados locales.
- Intentos de parada y deshabilitado de servicios on-demand.
- Escritura de este readback local.

## Sistemas no tocados
- Microsoft live.
- SharePoint live.
- Dataverse live.
- Git destructivo.
- Cambios de registro o seguridad.

## Hallazgos
- Hay `101` servicios en ejecucion.
- `MsMpEng.exe` sigue activo y con memoria alta; se observo actividad normal de Defender, incluyendo actualizacion de firmas.
- Servicios on-demand identificados como ruido si no se usan:
  - `sshd`
  - `SshdBroker`
  - `ssh-agent`
  - `DiagTrack`
  - `WSearch`
  - `SysMain`
  - `Wecsvc`
  - `WdiSystemHost`
  - `SSDPSRV`
  - `TrkWks`
  - `MSiSCSI`
  - `lfsvc`
  - `WebManagement`
  - `WSAIFabricSvc`
  - `McAfee WebAdvisor`
  - `HP Comm Recover`
  - `HPAppHelperCap`
  - `HPDiagsCap`
  - `HPNetworkCap`
  - `HPSysInfoCap`
  - `OneDrive Updater Service`

## Resultado de los intentos
- `ssh-agent` ya estaba parado.
- `OneDrive Updater Service` ya estaba parado.
- El resto de los servicios objetivo devolvio `Acceso denegado` al intentar `Stop-Service`, `Set-Service` y `sc.exe stop`.
- `sshd` y `SshdBroker` siguen vivos y quedan como candidatos de deshabilitado on-demand en una consola elevada.

## Validacion
- Inventario de procesos y servicios.
- Revision de eventos de Defender.
- Prueba de contencion sobre servicios on-demand.

## Riesgos
- Los servicios objetivo permanecen activos hasta ejecutar la misma operacion en PowerShell elevada.
- Defender puede seguir con memoria alta por actividad de plataforma o firmas.

## Rollback
- No aplica: no se hicieron mutaciones persistentes.

## Proximos carriles
- Repetir el lote de deshabilitado en una consola admin.
- Reducir `cache/codex-runtimes` y revisar `archived_sessions`.
- Mantener `sshd` y `SshdBroker` solo on-demand.

agente: Codex
orden: guardar evidencia de contencion de servicios persistentes
superficie: local / Windows / servicios
skill: rey-modo-evidence-risk-handoff
receta: inventario + intento conservador + readback
tool: PowerShell + event log + filesystem
estado: HECHO_VERIFICADO
evidencia: inventario de 101 servicios, intentos denegados, estado de Defender
validador: comprobacion directa de servicios, procesos y eventos
riesgo: medio
rollback: ninguno; no hubo mutacion
stop_condition: cambios de servicios requieren consola elevada
proximos_carriles: consola admin para on-demand, limpieza de .codex
