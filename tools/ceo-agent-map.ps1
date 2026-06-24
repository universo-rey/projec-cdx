param(
    [switch] $Json
)

$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$contractPath = Join-Path $Root '.cabina\SDU_RUNTIME_ROOT\05_CONFIG\cabina-contract.v1.json'

$agents = @()
$carriles = @()
if (Test-Path -LiteralPath $contractPath) {
    $contract = Get-Content -LiteralPath $contractPath -Raw | ConvertFrom-Json
    $agents = @($contract.agents | ForEach-Object {
        [PSCustomObject]@{
            agent_id = $_.agent_id
            role = $_.role
            responsibilities = $_.responsibilities
            status = 'configured'
            source = '.cabina/SDU_RUNTIME_ROOT/05_CONFIG/cabina-contract.v1.json'
        }
    })
    $carriles = @($contract.required_carriles)
}

$payload = [PSCustomObject]@{
    command = 'ceo-agent-map'
    root = $Root
    generated_at = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
    agent_count = @($agents).Count
    agents = @($agents)
    carriles = @($carriles)
    frontera = @{
        declarative_only = $true
        no_live = $true
        no_write = $true
    }
}

if ($Json -or $true) {
    $payload | ConvertTo-Json -Depth 8
}

