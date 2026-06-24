param([switch] $Json, [int] $MaxDepth = 4)
& "$PSScriptRoot\ceo-execution-reconciliation-g1.ps1" -Mode sdk-agent-routes -Json:$Json -MaxDepth $MaxDepth
