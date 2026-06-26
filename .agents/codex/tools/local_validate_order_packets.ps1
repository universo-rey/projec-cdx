param(
  [string]$Root = ".agents\codex"
)

$ErrorActionPreference = "Stop"

function Read-CsvSafe {
  param([string]$Path)
  if (-not (Test-Path -LiteralPath $Path)) {
    throw "Missing CSV: $Path"
  }
  @(Import-Csv -LiteralPath $Path)
}

function Require-Columns {
  param(
    [string]$Path,
    [string[]]$Columns,
    [System.Collections.Generic.List[string]]$Errors
  )
  $rows = Read-CsvSafe -Path $Path
  $actual = @()
  if ($rows.Count -gt 0) {
    $actual = @($rows[0].PSObject.Properties.Name)
  } else {
    $header = Get-Content -LiteralPath $Path -TotalCount 1
    if ($header) { $actual = @($header -split ",") }
  }
  foreach ($column in $Columns) {
    if ($column -notin $actual) {
      $Errors.Add("Missing column '$column' in $Path")
    }
  }
}

function Resolve-CabinaPath {
  param([string]$Path)
  if ([string]::IsNullOrWhiteSpace($Path)) { return $Path }
  $resolvedRoot = (Resolve-Path -LiteralPath $Root).Path
  $repoRoot = Split-Path -Parent (Split-Path -Parent $resolvedRoot)
  $normalized = $Path -replace "/", "\"
  if ($normalized.StartsWith(".agents\codex", [System.StringComparison]::OrdinalIgnoreCase)) {
    return Join-Path $Root ($normalized.Substring(".agents\codex".Length).TrimStart("\"))
  }
  if ($normalized.StartsWith("C:\Users\enzo1\Documents\GitHub\cabina-universal-d", [System.StringComparison]::OrdinalIgnoreCase)) {
    return Join-Path $repoRoot ($normalized.Substring("C:\Users\enzo1\Documents\GitHub\cabina-universal-d".Length).TrimStart("\"))
  }
  return $Path
}

function Check-ValidatorRef {
  param(
    [string]$Value,
    [string[]]$ToolIds,
    [System.Collections.Generic.List[string]]$Errors,
    [string]$Context
  )
  if ([string]::IsNullOrWhiteSpace($Value)) {
    $Errors.Add("$Context missing validator")
    return
  }
  if ($Value -like "tool.*") {
    if ($Value -notin $ToolIds) {
      $Errors.Add("$Context references unknown validator tool: $Value")
    }
    return
  }
  if ($Value -match '^[A-Za-z]:[\\/]') {
    $resolved = Resolve-CabinaPath -Path $Value
    if (-not (Test-Path -LiteralPath $resolved)) {
      $Errors.Add("$Context validator path missing: $Value")
    }
  }
}

function Check-StopCondition {
  param(
    [string]$Value,
    [string[]]$KnownStops,
    [System.Collections.Generic.List[string]]$Errors,
    [string]$Context
  )
  foreach ($token in @($Value -split "\|" | ForEach-Object { $_.Trim() } | Where-Object { $_ })) {
    if ($token -notin $KnownStops) {
      $Errors.Add("$Context references unknown stop_condition: $token")
    }
  }
}

$orderPath = Join-Path $Root "matrices\ORDER_PREPARATION_ASSIGNMENT_MATRIX.csv"
$orderClassPath = Join-Path $Root "matrices\ORDER_CLASS_CAPABILITY_MATRIX.csv"
$toolIndexPath = Join-Path $Root "tools\TOOL_INDEX.csv"
$stopPath = Join-Path $Root "matrices\STOP_CONDITION_GLOSSARY.csv"
$ordersDir = Join-Path $Root "orders"

$errors = New-Object System.Collections.Generic.List[string]
$warnings = New-Object System.Collections.Generic.List[string]

Require-Columns -Path $orderPath -Columns @("order_class","preparer_agent","reviewer_agent","approver_role","canon_as_of","source_authority","required_fields","allowed_actions","blocked_actions","recipe","tool","evidence","validator","expiration_rule","stop_condition") -Errors $errors
Require-Columns -Path $orderClassPath -Columns @("order_class","required_agents","required_skills","required_recipes","required_tools","required_fields","validator","stop_condition") -Errors $errors

$toolIds = @((Read-CsvSafe -Path $toolIndexPath) | ForEach-Object { $_.tool_id })
$knownStops = @((Read-CsvSafe -Path $stopPath) | ForEach-Object { $_.stop_condition })
$commonRequired = @("surface","owner","identity","data_boundary","allowed_actions","blocked_actions","rollback","postcheck","evidence","validator","stop_condition")

foreach ($row in Read-CsvSafe -Path $orderPath) {
  foreach ($field in @("order_class","preparer_agent","reviewer_agent","approver_role","canon_as_of","source_authority","required_fields","allowed_actions","blocked_actions","recipe","tool","evidence","validator","expiration_rule","stop_condition")) {
    if ([string]::IsNullOrWhiteSpace($row.$field)) {
      $errors.Add("Order class '$($row.order_class)' missing $field")
    }
  }
  if ($row.preparer_agent -eq $row.reviewer_agent) {
    $errors.Add("Order class '$($row.order_class)' preparer_agent and reviewer_agent must differ")
  }
  $fields = @($row.required_fields -split "\|" | ForEach-Object { $_.Trim() } | Where-Object { $_ })
  foreach ($required in $commonRequired) {
    if ($required -notin $fields) {
      $errors.Add("Order class '$($row.order_class)' required_fields missing $required")
    }
  }
  Check-ValidatorRef -Value $row.validator -ToolIds $toolIds -Errors $errors -Context "Order class '$($row.order_class)'"
  Check-StopCondition -Value $row.stop_condition -KnownStops $knownStops -Errors $errors -Context "Order class '$($row.order_class)'"
}

foreach ($row in Read-CsvSafe -Path $orderClassPath) {
  foreach ($tool in @($row.required_tools -split "\|" | ForEach-Object { $_.Trim() } | Where-Object { $_ })) {
    if ($tool -notin $toolIds) {
      $errors.Add("Order class capability '$($row.order_class)' references unknown tool: $tool")
    }
  }
  Check-ValidatorRef -Value $row.validator -ToolIds $toolIds -Errors $errors -Context "Order class capability '$($row.order_class)'"
  Check-StopCondition -Value $row.stop_condition -KnownStops $knownStops -Errors $errors -Context "Order class capability '$($row.order_class)'"
}

if (Test-Path -LiteralPath $ordersDir) {
  $orderFiles = @(Get-ChildItem -LiteralPath $ordersDir -File -Filter "*.md")
  foreach ($file in $orderFiles) {
    $text = Get-Content -Raw -LiteralPath $file.FullName
    $mentionsOldNoRepoRule = ($text -match 'sin convertir\s+`?D:\\`?\s+en repo Git directo') -or ($text -match 'no inicializar\s+`?D:\\`?')
    if ($mentionsOldNoRepoRule -and $text -notmatch "SUPERSEDED_NON_EXECUTABLE") {
      $errors.Add("Order contradicts current root AGENTS.md and is not marked superseded: $($file.Name)")
    }
    $isPacketLike = ($text -match "Governed Order Preparation Packet") -or ($text -match "(?m)^- order_class:")
    if ($isPacketLike) {
      foreach ($field in $commonRequired + @("order_class","preparer_agent","reviewer_agent","approver_role","canon_as_of","source_authority","expiration_rule")) {
        $label = "- {0}:" -f $field
        if ($text -notmatch [regex]::Escape($label)) {
          $errors.Add("Order packet '$($file.Name)' missing field label: $field")
        }
      }
    }
  }
} else {
  $warnings.Add("Orders folder not present: $ordersDir")
}

$status = if ($errors.Count -eq 0) { "PASS" } else { "FAIL" }
[pscustomobject]@{
  status = $status
  root = $Root
  order_class_count = (Read-CsvSafe -Path $orderPath).Count
  order_capability_count = (Read-CsvSafe -Path $orderClassPath).Count
  order_file_count = if (Test-Path -LiteralPath $ordersDir) { @(Get-ChildItem -LiteralPath $ordersDir -File -Filter "*.md").Count } else { 0 }
  warning_count = $warnings.Count
  warnings = $warnings
  error_count = $errors.Count
  errors = $errors
} | ConvertTo-Json -Depth 6

if ($status -ne "PASS") {
  exit 1
}
