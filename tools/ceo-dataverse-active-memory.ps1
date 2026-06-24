param([switch] $Json)
& "$PSScriptRoot\ceo-execution-reconciliation-g1.ps1" -Mode dataverse-active-memory -Json:$Json
