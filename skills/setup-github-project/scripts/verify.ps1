[CmdletBinding()]
param(
    [ValidatePattern('^[^/]+/[^/]+$')]
    [string]$Repository,

    [string]$Owner,

    [ValidateRange(1, [int]::MaxValue)]
    [int]$ProjectNumber,

    [string]$StatePath,

    [switch]$NoExit
)

$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot 'ProjectPolicy.psm1') -Force

if ($StatePath) {
    $state = Get-Content -Raw -LiteralPath $StatePath | ConvertFrom-Json -Depth 50
    if (-not $Repository) { $Repository = $state.Repository.NameWithOwner }
} else {
    if (-not $Repository -or -not $Owner -or -not $ProjectNumber) {
        throw 'Live verification requires -Repository, -Owner, and -ProjectNumber.'
    }
    $inspectScript = Join-Path $PSScriptRoot 'inspect.ps1'
    $state = & $inspectScript -Repository $Repository -Owner $Owner -ProjectNumber $ProjectNumber | ConvertFrom-Json -Depth 50
}

$result = Get-GitHubProjectAssessment -State $state -Repository $Repository
$result | ConvertTo-Json -Depth 20

if (-not $NoExit -and -not $result.Conforms) { exit 1 }
