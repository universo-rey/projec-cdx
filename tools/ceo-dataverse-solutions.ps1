param([switch] $Json, [switch] $Refresh)
& "$PSScriptRoot\ceo-dataverse-active-use.ps1" -Mode solutions -Json:$Json -Refresh:$Refresh
