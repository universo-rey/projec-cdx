param([switch] $Json, [switch] $Refresh)
& "$PSScriptRoot\ceo-dataverse-active-use.ps1" -Mode schema -Json:$Json -Refresh:$Refresh
