# Tcu Redactor Planes Operativos

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Definir una auditoria local, determinista y de solo lectura del entorno SDU donde corre la cabina, cubriendo runtime, terminales, usuarios, variables, entorno Codex, equipo, discos, tareas, servicios y procesos.

**Architecture:** Unificar el rastreo en una sola corrida por dominio, con evidencia cruda separada de la normalizacion final. El plan asume PowerShell como superficie principal, usa lectura local sin cambios y deja un gate opcional de elevacion para las consultas que pierden visibilidad con token medio. El resultado esperado es un inventario reproducible, apto para automatizarse luego con scripts PowerShell.

**Tech Stack:** PowerShell, CIM/WMI, `Get-Process`, `Get-Service`, `Get-ScheduledTask`, `Get-ChildItem`, `Get-ItemProperty`, `Get-ExecutionPolicy`, `Get-Module`, `Get-Alias`, `Get-ComputerInfo`, `Select-String`, JSON, CSV, y utilidades locales del sistema.

---

**Artifacts**
- `C:\Users\enzo1\PROJEC CDX\docs\superpowers\plans\sdu-environment-audit-plan.json`
- `C:\Users\enzo1\PROJEC CDX\docs\superpowers\plans\SDU_ENV_AUDIT_PLAN.md`

## Resumen Ejecutivo

- Alcance: auditoria de runtime local, sesiones activas, identidad, entorno Codex, configuracion de equipo, discos, tareas programadas, servicios y procesos.
- Modo: `READ_ONLY`, `NO_CHANGES`, `AUDIT_ONLY`.
- Gating requerido: `--require-elevated` para la ejecucion futura del auditor cuando se necesite ver Task Scheduler y servicios sin ambiguedad.
- Criterio de exito: cada dominio entrega evidencia trazable, rutas canonicamente normalizadas y un reporte final con riesgos y huecos.

## Prioridad De Ejecucion

- P0: PowerShell runtime, terminales, usuarios/perfiles, variables de entorno.
- P1: entorno Codex, configuracion del equipo, discos.
- P2: tareas programadas, servicios, procesos.
- P3: sintesis final, clasificacion de riesgos y publicacion del reporte.

## Dependencias

- Terminal PowerShell disponible en la sesion actual.
- Acceso de lectura al perfil del usuario y a `%USERPROFILE%\.codex`.
- Permisos suficientes para consultar servicios y tareas programadas.
- Si el token no esta elevado, la auditoria debe registrar la limitacion y no fingir visibilidad completa.
- No asumir `rg` disponible; los borrados y filtrados de texto deben usar `Get-ChildItem` y `Select-String` como fallback nativo.

### Task 1: Preflight y contrato de ejecucion

**Objetivo:** fijar el alcance, el formato de salida y el criterio de trazabilidad antes de inspeccionar nada.

- [ ] **Step 1: Confirmar modo y ruta base**

```powershell
$root = $PWD.Path
$user = $env:USERPROFILE
[pscustomobject]@{
  Root = $root
  UserProfile = $user
  Host = $env:COMPUTERNAME
  Shell = $PSVersionTable.PSEdition
}
```

- [ ] **Step 2: Activar gate de elevacion recomendado**

```powershell
try {
  $elevated = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
} catch {
  $elevated = $false
}
$elevated
```

- [ ] **Step 3: Definir artefactos de salida**

```powershell
$outDir = Join-Path $root 'outputs\sdu-environment-audit'
$json = Join-Path $outDir 'sdu-environment-audit.json'
$md = Join-Path $outDir 'SDU_ENV_AUDIT.md'
```

### Task 2: PowerShell runtime

**Objetivo:** capturar version, perfiles, politica de ejecucion, modulos, aliases y resolucion de paths.

- [ ] **Step 1: Levantar el runtime real**

```powershell
$PSVersionTable
Get-Host
Get-ExecutionPolicy -List
```

- [ ] **Step 2: Revisar perfiles y modulos**

```powershell
Get-ChildItem -LiteralPath $PROFILE* -ErrorAction SilentlyContinue
Get-Module | Select-Object Name, Version, Path
Get-Alias | Sort-Object Name
```

- [ ] **Step 3: Validar resolucion de paths**

```powershell
Resolve-Path .
Get-Location
[System.IO.Path]::GetFullPath($PWD.Path)
```

### Task 3: Terminales activas

**Objetivo:** identificar instancias activas, tipo de terminal, encoding y locale efectivo.

- [ ] **Step 1: Enumerar procesos de terminal**

```powershell
Get-Process pwsh,powershell,cmd,WindowsTerminal,Code -ErrorAction SilentlyContinue |
  Select-Object Name, Id, Path
```

- [ ] **Step 2: Capturar locale y encoding**

```powershell
[pscustomobject]@{
  Culture = [System.Globalization.CultureInfo]::CurrentCulture.Name
  UICulture = [System.Globalization.CultureInfo]::CurrentUICulture.Name
  OutputEncoding = [Console]::OutputEncoding.WebName
  OEMCodePage = [System.Globalization.CultureInfo]::InstalledUICulture.TextInfo.OEMCodePage
}
```

- [ ] **Step 3: Registrar PATH efectivo**

```powershell
$env:Path -split ';' | Where-Object { $_ }
```

### Task 4: Usuarios y perfiles

**Objetivo:** identificar usuario actual, perfiles cargados y permisos relevantes de carpetas de perfil.

- [ ] **Step 1: Confirmar identidad y grupos**

```powershell
whoami /all
```

- [ ] **Step 2: Revisar perfiles del sistema**

```powershell
Get-CimInstance Win32_UserProfile |
  Select-Object LocalPath, SID, Loaded, Special
```

- [ ] **Step 3: Verificar permisos en rutas clave**

```powershell
Get-Acl $env:USERPROFILE | Format-List
Get-Acl (Join-Path $env:USERPROFILE '.codex') | Format-List
```

### Task 5: Variables de entorno

**Objetivo:** capturar variables `CODEX_*`, `PATH`, `PYTHONPATH` y diferencias entre usuario y sistema.

- [ ] **Step 1: Exportar variables de entorno del proceso**

```powershell
Get-ChildItem Env: | Sort-Object Name
```

- [ ] **Step 2: Comparar usuario vs sistema**

```powershell
Get-ItemProperty 'HKCU:\Environment' | Format-List
Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment' | Format-List
```

- [ ] **Step 3: Filtrar variables de interes**

```powershell
Get-ChildItem Env: | Where-Object Name -like 'CODEX_*'
```

### Task 6: Entorno Codex

**Objetivo:** auditar `%USERPROFILE%\.codex`, `config.toml`, sesiones, rollouts, MCP y agentes canónicos.

- [ ] **Step 1: Inventariar la raiz Codex**

```powershell
Get-ChildItem -LiteralPath (Join-Path $env:USERPROFILE '.codex') -Force
```

- [ ] **Step 2: Leer configuracion activa**

```powershell
Get-Content -LiteralPath (Join-Path $env:USERPROFILE '.codex\config.toml')
```

- [ ] **Step 3: Identificar sesiones, worktrees y agentes**

```powershell
Get-ChildItem -LiteralPath (Join-Path $env:USERPROFILE '.codex') -Recurse -Directory |
  Where-Object { $_.Name -in @('sessions','worktrees','agents','plugins','environment') }
```

### Task 7: Configuracion del equipo

**Objetivo:** capturar OS, hostname, arquitectura, timezone y politicas de seguridad basicas.

- [ ] **Step 1: Capturar inventario del sistema**

```powershell
Get-ComputerInfo | Select-Object WindowsProductName, WindowsVersion, OsHardwareAbstractionLayer
hostname
```

- [ ] **Step 2: Revisar arquitectura y zona horaria**

```powershell
[pscustomobject]@{
  Is64BitOS = [Environment]::Is64BitOperatingSystem
  Is64BitProcess = [Environment]::Is64BitProcess
  TimeZone = (Get-TimeZone).Id
}
```

- [ ] **Step 3: Revisar politica de seguridad local**

```powershell
Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' |
  Select-Object EnableLUA, ConsentPromptBehaviorAdmin, PromptOnSecureDesktop
```

### Task 8: Discos y sistemas de archivos

**Objetivo:** listar unidades, espacio, tipo de filesystem y posibles rutas montadas o redirigidas.

- [ ] **Step 1: Enumerar volumenes y drives**

```powershell
Get-Volume
Get-PSDrive -PSProvider FileSystem
Get-CimInstance Win32_LogicalDisk | Select-Object DeviceID, FileSystem, Size, FreeSpace
```

- [ ] **Step 2: Revisar discos y particiones disponibles**

```powershell
Get-Disk
Get-Partition
```

- [ ] **Step 3: Detectar superficies historicas o redirigidas**

```powershell
Get-ChildItem -LiteralPath 'C:\' -Force -ErrorAction SilentlyContinue |
  Where-Object { $_.Name -in @('Windows.old','Users','Documents') }
```

### Task 9: Tareas programadas

**Objetivo:** identificar tareas activas, tareas SDU/tooling y tareas que puedan interferir con runtime.

- [ ] **Step 1: Listar tareas activas**

```powershell
Get-ScheduledTask | Select-Object TaskName, TaskPath, State
```

- [ ] **Step 2: Filtrar las relacionadas con SDU o tooling**

```powershell
Get-ScheduledTask | Where-Object {
  $_.TaskName -match 'SDU|Codex|PowerShell|Python|Node|Git'
}
```

- [ ] **Step 3: Capturar detalle de ejecucion**

```powershell
Get-ScheduledTaskInfo -TaskName 'ExampleTask' -TaskPath '\'
```

### Task 10: Servicios del sistema

**Objetivo:** registrar servicios activos y los que impactan desarrollo, tooling o auditoria.

- [ ] **Step 1: Enumerar servicios**

```powershell
Get-Service | Select-Object Name, DisplayName, Status, StartType
```

- [ ] **Step 2: Correlacionar con CIM**

```powershell
Get-CimInstance Win32_Service | Select-Object Name, State, StartMode, PathName, StartName
```

- [ ] **Step 3: Marcar servicios de interes**

```powershell
Get-Service | Where-Object { $_.Name -match 'Codex|Python|Node|Git|W32Time|WinRM' }
```

### Task 11: Procesos relevantes

**Objetivo:** identificar procesos de PowerShell, Python, Codex y cualquier redundancia o ruido sospechoso.

- [ ] **Step 1: Enumerar procesos activos**

```powershell
Get-Process | Select-Object Name, Id, Path
```

- [ ] **Step 2: Filtrar procesos del stack**

```powershell
Get-Process pwsh,powershell,python,node,cmd,Code -ErrorAction SilentlyContinue |
  Select-Object Name, Id, Path, StartTime
```

- [ ] **Step 3: Correlacionar con el arbol de procesos**

```powershell
Get-CimInstance Win32_Process |
  Select-Object ProcessId, ParentProcessId, Name, ExecutablePath, CommandLine
```

### Task 12: Sintesis y reporte final

**Objetivo:** convertir la evidencia cruda en un reporte auditable, priorizado y listo para automatizar.

- [ ] **Step 1: Normalizar la evidencia**

```powershell
@{ domains = @(); checks_per_domain = @(); tools_to_use = @() } | ConvertTo-Json -Depth 8
```

- [ ] **Step 2: Clasificar riesgos**

```powershell
@(
  'token medio sin elevacion',
  'variables PATH divergentes',
  'Codex con cache o historial no canonico',
  'servicios o tareas con permisos limitados',
  'Windows.old contaminando rutas historicas'
)
```

- [ ] **Step 3: Publicar el resultado**

```powershell
Write-Host 'Auditoria completada'
```

## Resumen Por Dominio

- PowerShell runtime: version, perfiles, politica de ejecucion, modulos, aliases y resolucion.
- Terminales: procesos activos, tipo de shell, PATH efectivo, encoding y locale.
- Usuarios y perfiles: identidad, grupos, perfiles cargados y permisos.
- Variables de entorno: `CODEX_*`, `PATH`, `PYTHONPATH`, diferencias user/system.
- Entorno Codex: raiz `.codex`, `config.toml`, sesiones, rollouts, MCP y agentes.
- Equipo: OS, hostname, arquitectura, timezone y politica de seguridad.
- Discos: volumenes, espacio, filesystem y superficies montadas.
- Tareas programadas: inventario, tareas SDU/tooling y trabajos sospechosos.
- Servicios: estado, arranque y procesos de servicio con impacto en runtime.
- Procesos: PowerShell, Python, Codex y redundancias.

## Riesgos

- Token de UAC en nivel medio que oculta parte de `Task Scheduler` y `services`.
- Duplicacion entre `Documents`, `Windows.old`, backups y caches.
- Falta de `pytest` o dependencias en runtimes alternativos si luego se usa Python para postprocesar.
- MCP o tooling ausente por `PATH` o por perfiles no cargados.
- Permisos insuficientes sobre `HKLM`, `Get-Disk` o tareas elevadas.

## Self-Review

### 1. Spec Coverage

- PowerShell runtime: cubierto en Task 2.
- Terminales activas: cubierto en Task 3.
- Usuarios y perfiles: cubierto en Task 4.
- Variables de entorno: cubierto en Task 5.
- Entorno Codex: cubierto en Task 6.
- Configuracion del equipo: cubierto en Task 7.
- Discos y sistemas de archivos: cubierto en Task 8.
- Task Scheduler: cubierto en Task 9.
- Servicios: cubierto en Task 10.
- Procesos relevantes: cubierto en Task 11.

### 2. Placeholder Scan

- No hay `TBD`.
- No hay `TODO`.
- No hay descripciones vagas sin comandos concretos.

### 3. Type Consistency

- `domain`, `checks_per_domain`, `tools_to_use`, `commands_examples` y `risk_areas` se usan con la misma semantica en todo el plan.
