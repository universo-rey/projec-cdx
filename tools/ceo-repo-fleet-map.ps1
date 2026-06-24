param([switch] $Json, [int] $MaxDepth = 4)
& "$PSScriptRoot\ceo-execution-reconciliation-g1.ps1" -Mode repo-fleet-map -Json:$Json -MaxDepth $MaxDepth
