param(
  [int]$Port = 8081,
  [string]$ActivationOrigin = "activate_system",
  [string]$ExecutedBy = "SDU_ROOT_AUTHORITY"
)

$ErrorActionPreference = "Stop"

$statePath = "C:\CEO\watchdog\state\sdu-system-state.json"
$busPath = "C:\CEO\watchdog\bus\sdu-event-bus.jsonl"
$nocWeb = "C:\CEO\watchdog\noc-web"
$serveScript = Join-Path $nocWeb "serve.ps1"
$changesLog = "C:\CEO\watchdog\logs\changes.jsonl"
$eventBus = "C:\CEO\watchdog\bus\sdu-event-bus.jsonl"
$mirrorDirs = @(
  (Join-Path $nocWeb "data"),
  (Join-Path $nocWeb "public\data")
)

function Get-SduLifecycleListeners {
  param([int]$Port)
  $connections = @(Get-NetTCPConnection -State Listen -ErrorAction SilentlyContinue | Where-Object { $_.LocalPort -eq $Port })
  foreach ($connection in $connections) {
    $process = Get-Process -Id $connection.OwningProcess -ErrorAction SilentlyContinue
    [ordered]@{
      address = $connection.LocalAddress
      port = $connection.LocalPort
      pid = $connection.OwningProcess
      process = if ($process) { $process.ProcessName } else { $null }
      path = if ($process) { $process.Path } else { $null }
    }
  }
}

function Update-SduLifecycleState {
  param(
    [string]$Mode,
    [object[]]$Listeners
  )
  $state = Get-Content -LiteralPath $statePath -Raw | ConvertFrom-Json
  $now = (Get-Date).ToString("o")
  if (-not $state.runtime) {
    $state | Add-Member -NotePropertyName runtime -NotePropertyValue ([pscustomobject]@{}) -Force
  }
  $state.runtime | Add-Member -NotePropertyName lifecycle -NotePropertyValue ([ordered]@{
    mode = $Mode
    last_transition = $now
    activation_origin = $ActivationOrigin
    configured_port = $Port
    noc_url = "http://127.0.0.1:$Port/noc-web/"
    listener_count = @($Listeners).Count
    listeners = @($Listeners)
    server_script = $serveScript
    activate_command = "C:\CEO\project-cdx\noc\actions\g12-activate-system.ps1"
    pause_command = "C:\CEO\project-cdx\noc\actions\g12-pause-system.ps1"
    last_refresh_real = $now
    sync_sources = @($statePath, $busPath)
  }) -Force

  $state | ConvertTo-Json -Depth 100 | Set-Content -LiteralPath $statePath -Encoding UTF8
}

function Sync-SduNocMirrors {
  foreach ($dir in $mirrorDirs) {
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
    Copy-Item -LiteralPath $statePath -Destination (Join-Path $dir "sdu-system-state.json") -Force
    if (Test-Path -LiteralPath $busPath) {
      Copy-Item -LiteralPath $busPath -Destination (Join-Path $dir "sdu-event-bus.jsonl") -Force
    }
  }
}

if (-not (Test-Path -LiteralPath $serveScript)) {
  throw "NOC serve script not found: $serveScript"
}

$listeners = @(Get-SduLifecycleListeners -Port $Port)
if ($listeners.Count -eq 0) {
  $pwsh = (Get-Command pwsh -ErrorAction SilentlyContinue).Source
  if (-not $pwsh) { $pwsh = (Get-Command powershell -ErrorAction Stop).Source }
  Start-Process -FilePath $pwsh -ArgumentList @("-NoProfile", "-ExecutionPolicy", "Bypass", "-File", $serveScript) -WindowStyle Hidden | Out-Null
  Start-Sleep -Seconds 3
  $listeners = @(Get-SduLifecycleListeners -Port $Port)
}

Sync-SduNocMirrors
$mode = if ($listeners.Count -gt 0) { "SERVING_ACTIVE" } else { "READY_PASSIVE" }
Update-SduLifecycleState -Mode $mode -Listeners $listeners

$entry = [ordered]@{
  timestamp = (Get-Date).ToString("o")
  action = "SDU_RUNTIME_ACTIVATION_AND_LIVE_MODE_G12"
  intent = "activate_system"
  mode = $mode
  port = $Port
  listeners = @($listeners).Count
  executedBy = $ExecutedBy
  no_destructive_actions = $true
}
$entry | ConvertTo-Json -Compress -Depth 20 | Add-Content -LiteralPath $changesLog -Encoding UTF8
$busEntry = [ordered]@{
  timestamp = $entry.timestamp
  type = "runtime.lifecycle.transition"
  source = "g12-activate-system"
  payload = $entry
}
$busEntry | ConvertTo-Json -Compress -Depth 20 | Add-Content -LiteralPath $eventBus -Encoding UTF8

[ordered]@{
  actionId = "G12_ACTIVATE_SYSTEM"
  intent = "activate_system"
  result = if ($mode -eq "SERVING_ACTIVE") { "SUCCESS" } else { "WARN" }
  lifecycle_mode = $mode
  listeners = @($listeners)
  noc_url = "http://127.0.0.1:$Port/noc-web/"
  runtimeMutation = $true
  externalWrites = $false
  timestamp = (Get-Date).ToString("o")
} | ConvertTo-Json -Depth 20
