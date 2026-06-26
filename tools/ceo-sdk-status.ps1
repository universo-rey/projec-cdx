param([switch] $Json, [int] $MaxDepth = 4)
& "$PSScriptRoot\ceo-execution-reconciliation-g1.ps1" -Mode sdk-status -Json:$Json -MaxDepth $MaxDepth
