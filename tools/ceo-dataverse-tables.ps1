param([switch] $Json, [switch] $Refresh)
& "$PSScriptRoot\ceo-dataverse-active-use.ps1" -Mode tables -Json:$Json -Refresh:$Refresh
