param(
  [string]$ActionId = "VALIDATE_ALL",
  [string]$ActionLabel = "Validar todo",
  [string]$Risk = "LOW",
  [string]$ExecutedBy = "OWNER_UI",
  [string]$DecisionSource = "MANUAL_CLICK",
  [string]$PreStateJson = "{}"
)

& "C:\CEO\project-cdx\noc\actions\invoke-noc-action.ps1" `
  -ActionId $ActionId `
  -ActionLabel $ActionLabel `
  -Risk $Risk `
  -ExecutedBy $ExecutedBy `
  -DecisionSource $DecisionSource `
  -PreStateJson $PreStateJson `
  -NocActionName "VALIDATE_ALL"
