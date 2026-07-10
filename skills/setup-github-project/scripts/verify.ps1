[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidatePattern('^[^/]+/[^/]+$')]
    [string]$Repository,

    [Parameter(Mandatory = $true)]
    [string]$Owner,

    [Parameter(Mandatory = $true)]
    [ValidateRange(1, [int]::MaxValue)]
    [int]$ProjectNumber
)

$ErrorActionPreference = 'Stop'

if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    throw 'GitHub CLI (gh) is required.'
}

$project = gh project view $ProjectNumber --owner $Owner --format json | ConvertFrom-Json
$fields = @(gh project field-list $ProjectNumber --owner $Owner --limit 100 --format json | ConvertFrom-Json)
$items = @(gh project item-list $ProjectNumber --owner $Owner --limit 1000 --format json | ConvertFrom-Json)

$fieldPayload = if ($fields.fields) { @($fields.fields) } else { @($fields) }
$itemPayload = if ($items.items) { @($items.items) } else { @($items) }
$requiredFields = @('Status', 'Phase', 'Work Type')
$missingFields = @($requiredFields | Where-Object { $_ -notin $fieldPayload.name })

[ordered]@{
    Repository = $Repository
    Project = $project
    RequiredFields = $requiredFields
    MissingFields = $missingFields
    FieldCountByName = @($fieldPayload | Group-Object name | Select-Object Name, Count)
    ItemCount = $itemPayload.Count
    Items = $itemPayload
    ManualUiChecks = @(
        'Current Work is a flat Status board with Todo, In Progress, and Done',
        'Current Work has no swimlanes or grouping and contains zero Epic cards',
        'Every Current Work ticket shows Parent issue and one readiness label',
        'Epic Overview is an epic-only table grouped by Phase',
        'Specifications are excluded',
        'Auto-add, added, closed, and reopened workflows match the operating contract'
    )
} | ConvertTo-Json -Depth 20

