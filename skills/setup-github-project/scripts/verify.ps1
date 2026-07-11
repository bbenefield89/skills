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
$items = @(gh project item-list $ProjectNumber --owner $Owner --limit 1000 --format json | ConvertFrom-Json)
$labels = @(gh label list --repo $Repository --limit 200 --json name,description | ConvertFrom-Json)
$issues = @(gh issue list --repo $Repository --state all --limit 1000 --json number,title,state,labels,url,parent,subIssuesSummary,projectItems | ConvertFrom-Json)

$itemPayload = if ($items.items) { @($items.items) } else { @($items) }
$requiredLabels = @('phase', 'epic', 'spec', 'ready-for-agent', 'ready-for-human')
$missingLabels = @($requiredLabels | Where-Object { $_ -notin $labels.name })

function Get-HasLabel {
    param(
        [Parameter(Mandatory = $true)]
        $Issue,

        [Parameter(Mandatory = $true)]
        [string]$LabelName
    )

    return @($Issue.labels | Where-Object { $_.name -eq $LabelName }).Count -gt 0
}

$phaseIssues = @($issues | Where-Object { Get-HasLabel -Issue $_ -LabelName 'phase' })
$epicIssues = @($issues | Where-Object { Get-HasLabel -Issue $_ -LabelName 'epic' })
$specificationIssues = @($issues | Where-Object { Get-HasLabel -Issue $_ -LabelName 'spec' })
$implementationTickets = @(
    $issues | Where-Object {
        (Get-HasLabel -Issue $_ -LabelName 'ready-for-agent') -or
        (Get-HasLabel -Issue $_ -LabelName 'ready-for-human')
    }
)
$projectIssueUrls = @(
    $itemPayload | ForEach-Object {
        if ($_.content -and $_.content.url) { $_.content.url }
        elseif ($_.url) { $_.url }
    } | Where-Object { $_ } | Select-Object -Unique
)

function Get-ReadinessLabelCount {
    param([Parameter(Mandatory = $true)]$Issue)

    return @(
        if (Get-HasLabel -Issue $Issue -LabelName 'ready-for-agent') { 'ready-for-agent' }
        if (Get-HasLabel -Issue $Issue -LabelName 'ready-for-human') { 'ready-for-human' }
    ).Count
}

function Test-ParentHasLabel {
    param(
        [Parameter(Mandatory = $true)]$Issue,
        [Parameter(Mandatory = $true)][string]$LabelName
    )

    if (-not $Issue.parent) { return $false }
    return @($Issue.parent.labels | Where-Object { $_.name -eq $LabelName }).Count -gt 0
}

$epicsWithInvalidParent = @(
    $epicIssues | Where-Object { -not (Test-ParentHasLabel -Issue $_ -LabelName 'phase') }
)
$ticketsWithInvalidParent = @(
    $implementationTickets | Where-Object { -not (Test-ParentHasLabel -Issue $_ -LabelName 'epic') }
)
$ticketsWithInvalidReadiness = @(
    $implementationTickets | Where-Object { (Get-ReadinessLabelCount -Issue $_) -ne 1 }
)
$specificationsWithReadiness = @(
    $specificationIssues | Where-Object { (Get-ReadinessLabelCount -Issue $_) -gt 0 }
)
$specificationsWithParent = @($specificationIssues | Where-Object { $_.parent })
$specificationsWithChildren = @(
    $specificationIssues | Where-Object { $_.subIssuesSummary.total -gt 0 }
)
$specificationsInProject = @(
    $specificationIssues | Where-Object { $_.url -in $projectIssueUrls }
)
$projectArtifactsMissingFromProject = @(
    @($phaseIssues + $epicIssues + $implementationTickets) |
        Where-Object { $_.url -notin $projectIssueUrls }
)
$issuesWithMixedHierarchyLabels = @(
    $issues | Where-Object {
        $labelsOnIssue = @(
            if (Get-HasLabel -Issue $_ -LabelName 'phase') { 'phase' }
            if (Get-HasLabel -Issue $_ -LabelName 'epic') { 'epic' }
            if (Get-HasLabel -Issue $_ -LabelName 'spec') { 'spec' }
            if (Get-HasLabel -Issue $_ -LabelName 'ready-for-agent') { 'ready-for-agent' }
            if (Get-HasLabel -Issue $_ -LabelName 'ready-for-human') { 'ready-for-human' }
        )
        $labelsOnIssue.Count -gt 1
    }
)

[ordered]@{
    Repository = $Repository
    Project = $project
    RequiredLabels = $requiredLabels
    MissingLabels = $missingLabels
    LabelCountByName = @($labels | Group-Object name | Select-Object Name, Count)
    ItemCount = $itemPayload.Count
    Items = $itemPayload
    PhaseIssueCount = $phaseIssues.Count
    EpicIssueCount = $epicIssues.Count
    SpecificationIssueCount = $specificationIssues.Count
    ImplementationTicketCount = $implementationTickets.Count
    IssuesWithMixedHierarchyLabels = $issuesWithMixedHierarchyLabels
    EpicsWithInvalidParent = $epicsWithInvalidParent
    TicketsWithInvalidParent = $ticketsWithInvalidParent
    TicketsWithInvalidReadiness = $ticketsWithInvalidReadiness
    SpecificationsWithReadiness = $specificationsWithReadiness
    SpecificationsWithParent = $specificationsWithParent
    SpecificationsWithChildren = $specificationsWithChildren
    SpecificationsInProject = $specificationsInProject
    ProjectArtifactsMissingFromProject = $projectArtifactsMissingFromProject
    ManualUiChecks = @(
        'Current Work is a Status board with Todo, In Progress, and Done',
        'Current Work is filtered to label:"ready-for-agent","ready-for-human"',
        'Current Work has no swimlanes or grouping by Epic or Parent issue',
        'Current Work contains zero Phase or Epic cards',
        'Every Current Work ticket shows Parent issue and one readiness label',
        'Epic Roadmap is a table filtered to label:"epic" and grouped by Parent issue',
        'Epic Roadmap does not include phase in the filter and therefore does not show duplicate Phase rows or a No Parent issue bucket from Phase issues',
        'Specifications use spec, have no readiness label or native hierarchy, and are excluded from this Project',
        'Auto-add includes phase, epic, ready-for-agent, and ready-for-human',
        'Auto-add sub-issues to project is enabled',
        'Auto-add, added, closed, and reopened workflows match the operating contract',
        'docs/agents/github-project.md exists and root AGENTS.md points to it exactly once'
    )
} | ConvertTo-Json -Depth 20
