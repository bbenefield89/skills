[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidatePattern('^[^/]+/[^/]+$')]
    [string]$Repository,

    [string]$FixturePath,

    [string]$FailValidationAt
)

$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot 'ProjectPolicy.psm1') -Force

if ($FixturePath) {
    $fixture = Get-Content -Raw -LiteralPath $FixturePath | ConvertFrom-Json -Depth 20
    $existing = @($fixture.Milestones)
    $create = {
        param($Title, $Sequence)
        [pscustomobject]@{ Title=$Title; State='open'; Number=$Sequence }
    }
    $read = {
        param($Title, $Sequence, $Milestones)
        if ($FailValidationAt -ceq $Title) { return $null }
        $Milestones | Where-Object {
            $candidate = if ($_.PSObject.Properties['Title']) { $_.Title } else { $_.title }
            $candidate -ceq $Title
        } | Select-Object -First 1
    }
} else {
    if (-not (Get-Command gh -ErrorAction SilentlyContinue)) { throw 'GitHub CLI (gh) is required.' }
    $existing = @(gh api --paginate "repos/$Repository/milestones?state=all&per_page=100" | ConvertFrom-Json)
    $create = {
        param($Title, $Sequence)
        $payload = gh api --method POST "repos/$Repository/milestones" -f title=$Title
        if ($LASTEXITCODE -ne 0 -or -not $payload) { throw "Failed to create milestone '$Title'." }
        return $payload | ConvertFrom-Json
    }
    $read = {
        param($Title, $Sequence, $Milestones)
        $current = @(gh api --paginate "repos/$Repository/milestones?state=all&per_page=100" | ConvertFrom-Json)
        if ($LASTEXITCODE -ne 0) { throw "Failed to read back milestone '$Title'." }
        $current | Where-Object { $_.title -ceq $Title } | Select-Object -First 1
    }
}

$ambiguousMilestones = @(Get-AmbiguousMilestoneTitles -ExistingMilestones $existing)
$duplicateMilestones = @(Get-DuplicateCanonicalMilestoneTitles -ExistingMilestones $existing)
if ($ambiguousMilestones.Count -gt 0 -or $duplicateMilestones.Count -gt 0) {
    $conflicts = @($ambiguousMilestones + $duplicateMilestones | Select-Object -Unique)
    [ordered]@{
        Repository = $Repository
        Completed = $false
        Error = "Ambiguous or duplicate milestones require approval before canonical creation: $($conflicts -join ', ')"
        Operations = @()
    } | ConvertTo-Json -Depth 10
    exit 1
}

try {
    $result = Invoke-MilestoneReconciliation -ExistingMilestones $existing -CreateMilestone $create -ReadMilestone $read
    [ordered]@{
        Repository = $Repository
        Completed = $true
        Operations = @($result.Operations)
    } | ConvertTo-Json -Depth 10
} catch {
    [ordered]@{
        Repository = $Repository
        Completed = $false
        Error = $_.Exception.Message
        Operations = @($_.Exception.Data['Operations'])
    } | ConvertTo-Json -Depth 10
    exit 1
}
