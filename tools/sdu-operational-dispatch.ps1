param(
  [Parameter(Mandatory=$true)]
  [string]$Intent,

  [string]$TipoOperacion = "chat_order",
  [string]$Resultado = "RECORDED",
  [string]$Impacto = "trace_recorded",
  [string]$Origen = "codex-chat",
  [switch]$Confirmed
)

$ErrorActionPreference = "Stop"
$root = "C:\CEO\project-cdx"
$script = Join-Path $root "tools\sdu_operational_mode.py"
$argsList = @(
  $script,
  "trace",
  "--intent",
  $Intent,
  "--tipo-operacion",
  $TipoOperacion,
  "--resultado",
  $Resultado,
  "--impacto",
  $Impacto,
  "--origin",
  $Origen
)
if ($Confirmed) {
  $argsList += "--confirmed"
}

python @argsList
