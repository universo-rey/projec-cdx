param(
  [int]$Port = 8081,
  [string]$ActivationOrigin = "pause_system",
  [string]$ExecutedBy = "SDU_ROOT_AUTHORITY"
)

$ErrorActionPreference = "Stop"

$statePath = "C:\CEO\watchdog\state\sdu-system-state.json"
$changesLog = "C:\CEO\watchdog\logs\changes.jsonl"
$eventBus = "C:\CEO\watchdog\bus\sdu-event-bus.jsonl"
$serveScript = "C:\CEO\watchdog\noc-web\serve.ps1"

function Get-SduLifecycleListeners {
  param([int]$Port)
  $connections = @(Get-NetTCPConnection -State Listen -ErrorAction SilentlyContinue | Where-Object { $_.LocalPort -eq $Port })
  foreach ($connection in $connections) {
    $process = Get-Process -Id $connection.OwningProcess -ErrorAction SilentlyContinue
    $cim = Get-CimInstance Win32_Process -Filter "ProcessId=$($connection.OwningProcess)" -ErrorAction SilentlyContinue
    [ordered]@{
      address = $connection.LocalAddress
      port = $connection.LocalPort
      pid = $connection.OwningProcess
      process = if ($process) { $process.ProcessName } else { $null }
      path = if ($process) { $process.Path } else { $null }
      commandLine = if ($cim) { $cim.CommandLine } else { $null }
    }
  }
}

function Update-SduLifecycleState {
  param([object[]]$RemainingListeners)
  $state = Get-Content -LiteralPath $statePath -Raw | ConvertFrom-Json
  $now = (Get-Date).ToString("o")
  if (-not $state.runtime) {
    $state | Add-Member -NotePropertyName runtime -NotePropertyValue ([pscustomobject]@{}) -Force
  }
  $state.runtime | Add-Member -NotePropertyName lifecycle -NotePropertyValue ([ordered]@{
    mode = "READY_PASSIVE"
    last_transition = $now
    activation_origin = $ActivationOrigin
    configured_port = $Port
    noc_url = "http://127.0.0.1:$Port/noc-web/"
    listener_count = @($RemainingListeners).Count
    listeners = @($RemainingListeners)
    server_script = $serveScript
    activate_command = "C:\CEO\project-cdx\noc\actions\g12-activate-system.ps1"
    pause_command = "C:\CEO\project-cdx\noc\actions\g12-pause-system.ps1"
    last_refresh_real = $now
    sync_sources = @($statePath, $eventBus)
  }) -Force
  $state | ConvertTo-Json -Depth 100 | Set-Content -LiteralPath $statePath -Encoding UTF8
}

$listeners = @(Get-SduLifecycleListeners -Port $Port)
$stopped = @()
$currentProcess = Get-CimInstance Win32_Process -Filter "ProcessId=$PID" -ErrorAction SilentlyContinue
$parentProcessId = if ($currentProcess) { [int]$currentProcess.ParentProcessId } else { -1 }
foreach ($listener in $listeners) {
  $commandLine = [string]$listener.commandLine
  $safeToStop = $commandLine -match "owner_actions_server\.py" -or $commandLine -match [regex]::Escape("C:\CEO\watchdog\noc-web")
  if ($safeToStop) {
    if ([int]$listener.pid -eq $parentProcessId) {
      $pwsh = (Get-Command pwsh -ErrorAction SilentlyContinue).Source
      if (-not $pwsh) { $pwsh = (Get-Command powershell -ErrorAction Stop).Source }
      Start-Process -FilePath $pwsh -ArgumentList @(
        "-NoProfile",
        "-ExecutionPolicy",
        "Bypass",
        "-Command",
        "Start-Sleep -Seconds 3; Stop-Process -Id $($listener.pid) -Force -ErrorAction SilentlyContinue"
      ) -WindowStyle Hidden | Out-Null
    } else {
      Stop-Process -Id $listener.pid -Force -ErrorAction Stop
    }
    $stopped += $listener
  }
}

Start-Sleep -Seconds 1
$remaining = @(Get-SduLifecycleListeners -Port $Port)
Update-SduLifecycleState -RemainingListeners $remaining

$entry = [ordered]@{
  timestamp = (Get-Date).ToString("o")
  action = "SDU_RUNTIME_ACTIVATION_AND_LIVE_MODE_G12"
  intent = "pause_system"
  mode = "READY_PASSIVE"
  port = $Port
  stopped = @($stopped).Count
  remaining_listeners = @($remaining).Count
  executedBy = $ExecutedBy
  no_destructive_actions = $true
}
$entry | ConvertTo-Json -Compress -Depth 20 | Add-Content -LiteralPath $changesLog -Encoding UTF8
$busEntry = [ordered]@{
  timestamp = $entry.timestamp
  type = "runtime.lifecycle.transition"
  source = "g12-pause-system"
  payload = $entry
}
$busEntry | ConvertTo-Json -Compress -Depth 20 | Add-Content -LiteralPath $eventBus -Encoding UTF8

[ordered]@{
  actionId = "G12_PAUSE_SYSTEM"
  intent = "pause_system"
  result = if ($remaining.Count -eq 0) { "SUCCESS" } else { "WARN" }
  lifecycle_mode = "READY_PASSIVE"
  stopped = @($stopped)
  remaining_listeners = @($remaining)
  runtimeMutation = $true
  externalWrites = $false
  timestamp = (Get-Date).ToString("o")
} | ConvertTo-Json -Depth 20
