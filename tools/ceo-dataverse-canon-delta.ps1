param([switch] $Json, [switch] $Refresh)
& "$PSScriptRoot\ceo-dataverse-active-use.ps1" -Mode canon-delta -Json:$Json -Refresh:$Refresh
