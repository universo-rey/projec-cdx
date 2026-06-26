param([switch] $Json, [switch] $Refresh)
& "$PSScriptRoot\ceo-dataverse-active-use.ps1" -Mode records -Json:$Json -Refresh:$Refresh
