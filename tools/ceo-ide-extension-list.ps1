param(
    [switch] $Json
)

$Root = 'C:\CEO\project-cdx'
$ExtensionRoot = 'C:\Users\enzo1\.vscode-insiders\extensions'

function Read-PackageJson {
    param([string] $Directory)

    $packagePath = Join-Path $Directory 'package.json'
    if (-not (Test-Path -LiteralPath $packagePath)) {
        return $null
    }

    try {
        return Get-Content -LiteralPath $packagePath -Raw | ConvertFrom-Json
    }
    catch {
        return [PSCustomObject]@{
            parse_error = $_.Exception.Message
        }
    }
}

function Join-Text {
    param([object[]] $Values)

    (@($Values | Where-Object { $_ }) -join ' ').ToLowerInvariant()
}

function Get-PrimaryClass {
    param(
        [string] $Id,
        [string] $Text,
        [bool] $HasPackage
    )

    if (-not $HasPackage -or $Id.StartsWith('.')) {
        return 'NOISE'
    }

    if ($Id -match 'mcp') {
        return 'MCP'
    }

    if ($Text -match 'agent|copilot|chatgpt|codex|gemini|opencode|manulai|agentic|ai-|ai ') {
        return 'AGENT'
    }

    if ($Id -match 'github|gitlens|githistory|gitdoc|codeql' -or $Text -match '\bgit\b|github|pull request|codeql') {
        return 'GIT'
    }

    if ($Id -match 'ms-python|jupyter|pylance|debugpy' -or $Text -match 'python|jupyter|pylance|debugpy') {
        return 'PYTHON'
    }

    if ($Id -match 'powershell|powerplatform|m365-powershell' -or $Text -match 'powershell|power platform|power apps') {
        return 'POWERSHELL'
    }

    if ($Id -match 'markdown|marp|docsmsft|drawio|pdf|spell|yaml' -or $Text -match 'markdown|docs authoring|yaml|diagram|pdf|spell') {
        return 'MARKDOWN'
    }

    if ($Id -match 'editorconfig|eslint|prettier|office|rest-client|azure|remote-|containers|terraform|go$|golang|rust|csharp|cpp|kubernetes|sharepoint|teams|viva|bicep|npm') {
        return 'SUPPORT'
    }

    return 'UNKNOWN'
}

function Get-Impacts {
    param(
        [string] $Id,
        [string] $Text
    )

    $impacts = New-Object System.Collections.Generic.List[string]

    if ($Id -match 'terminal|powershell|remote-ssh|remote-containers|containers' -or $Text -match 'terminal|shell|powershell|remote') { $impacts.Add('terminal') }
    if ($Id -match 'github|gitlens|githistory|gitdoc|codeql' -or $Text -match '\bgit\b|github|pull request|codeql') { $impacts.Add('git') }
    if ($Id -match 'ms-python|jupyter|pylance|debugpy' -or $Text -match 'python|jupyter|pylance|debugpy') { $impacts.Add('python') }
    if ($Id -match 'node|npm|eslint|prettier|typescript|azure' -or $Text -match 'node|npm|javascript|typescript|eslint|prettier') { $impacts.Add('node') }
    if ($Id -match 'markdown|docsmsft|marp|drawio|pdf|yaml|spell' -or $Text -match 'markdown|yaml|pdf|diagram|spell') { $impacts.Add('markdown') }
    if ($Id -match 'agent|copilot|chatgpt|codex|gemini|opencode|manulai|agentic|ai' -or $Text -match 'agent|copilot|chatgpt|codex|gemini|opencode') { $impacts.Add('agents') }
    if ($Id -match 'mcp' -or $Text -match 'mcp|model context protocol') { $impacts.Add('mcp') }

    @($impacts | Select-Object -Unique)
}

function Get-Policy {
    param(
        [string] $Id,
        [string] $Class,
        [string[]] $Impacts
    )

    if ($Class -eq 'NOISE') {
        return 'NOISE'
    }

    if ($Id -in @(
            'openai.chatgpt',
            'cemkurtulus.agent-pipeline',
            'ms-vscode.powershell',
            'ms-python.python',
            'ms-python.vscode-pylance',
            'ms-python.debugpy',
            'ms-python.vscode-python-envs',
            'github.vscode-pull-request-github',
            'github.vscode-github-actions',
            'eamodio.gitlens',
            'davidanson.vscode-markdownlint',
            'redhat.vscode-yaml',
            'editorconfig.editorconfig',
            'esbenp.prettier-vscode',
            'dbaeumer.vscode-eslint',
            'microsoft-isvexptools.powerplatform-vscode'
        )) {
        return 'ALLOW'
    }

    if ($Class -eq 'AGENT' -or $Class -eq 'MCP') {
        return 'HOLD'
    }

    if ($Class -in @('PYTHON', 'POWERSHELL', 'GIT', 'MARKDOWN')) {
        return 'ALLOW'
    }

    if ($Class -eq 'SUPPORT') {
        return 'SUPPORT'
    }

    return 'REVIEW'
}

if (-not (Test-Path -LiteralPath $ExtensionRoot)) {
    $payload = [PSCustomObject]@{
        command = 'ceo-ide-extension-list'
        status = 'IDE_EXTENSION_LIST_NO_ROOT'
        extension_root = $ExtensionRoot
        extensions = @()
        frontera = @{
            no_uninstall = $true
            no_secret_read = $true
            no_live = $true
        }
    }

    if ($Json) { $payload | ConvertTo-Json -Depth 10 } else { $payload }
    exit 0
}

$extensions = @(Get-ChildItem -LiteralPath $ExtensionRoot -Directory -ErrorAction SilentlyContinue | Sort-Object Name | ForEach-Object {
        $folder = $_
        $package = Read-PackageJson -Directory $folder.FullName
        $hasPackage = $null -ne $package -and -not $package.parse_error
        $publisher = if ($hasPackage) { $package.publisher } else { $null }
        $name = if ($hasPackage) { $package.name } else { $folder.Name }
        $version = if ($hasPackage) { $package.version } else { $null }
        $id = if ($publisher -and $name) { "$publisher.$name" } else { $folder.Name }
        $textParts = New-Object System.Collections.Generic.List[object]
        $textParts.Add($id)
        $textParts.Add($folder.Name)
        if ($hasPackage) {
            $textParts.Add($package.displayName)
            $textParts.Add($package.description)
            foreach ($category in @($package.categories)) { $textParts.Add($category) }
            foreach ($keyword in @($package.keywords)) { $textParts.Add($keyword) }
        }
        $text = Join-Text -Values @($textParts.ToArray())
        $primaryClass = Get-PrimaryClass -Id $id -Text $text -HasPackage $hasPackage
        $impacts = @(Get-Impacts -Id $id -Text $text)
        $policy = Get-Policy -Id $id -Class $primaryClass -Impacts $impacts

        [PSCustomObject]@{
            id = $id
            folder = $folder.Name
            version = $version
            display_name = if ($hasPackage) { $package.displayName } else { $null }
            classification = $primaryClass
            policy = $policy
            impacts = $impacts
            has_package = $hasPackage
            parse_error = if ($package -and $package.parse_error) { $package.parse_error } else { $null }
            path = $folder.FullName
            last_write_time = $folder.LastWriteTime.ToString('yyyy-MM-ddTHH:mm:sszzz')
        }
    })

$duplicateGroups = @($extensions | Where-Object { $_.has_package } | Group-Object id | Where-Object { $_.Count -gt 1 } | ForEach-Object {
        [PSCustomObject]@{
            id = $_.Name
            count = $_.Count
            versions = @($_.Group | ForEach-Object { $_.version })
            folders = @($_.Group | ForEach-Object { $_.folder })
        }
    })

$byClass = @($extensions | Group-Object classification | Sort-Object Name | ForEach-Object {
        [PSCustomObject]@{
            classification = $_.Name
            count = $_.Count
        }
    })

$byPolicy = @($extensions | Group-Object policy | Sort-Object Name | ForEach-Object {
        [PSCustomObject]@{
            policy = $_.Name
            count = $_.Count
        }
    })

$payload = [PSCustomObject]@{
    command = 'ceo-ide-extension-list'
    status = 'IDE_EXTENSION_LIST_READY'
    generated_at = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
    extension_root = $ExtensionRoot
    extension_count = $extensions.Count
    by_class = $byClass
    by_policy = $byPolicy
    duplicate_count = $duplicateGroups.Count
    duplicates = $duplicateGroups
    extensions = $extensions
    frontera = @{
        no_uninstall = $true
        no_secret_read = $true
        no_live = $true
        no_profile_mutation = $true
    }
}

if ($Json) {
    $payload | ConvertTo-Json -Depth 12
}
else {
    $payload
}
