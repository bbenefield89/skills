[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidatePattern('^[^/]+/[^/]+$')]
    [string]$Repository,

    [string]$Owner,

    [ValidateRange(1, [int]::MaxValue)]
    [int]$ProjectNumber
)

$ErrorActionPreference = 'Stop'
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) { throw 'GitHub CLI (gh) is required.' }

$repositoryOwner, $repositoryName = $Repository.Split('/', 2)
if (-not $Owner) { $Owner = $repositoryOwner }
$warnings = [System.Collections.Generic.List[string]]::new()

function Get-LabelNames {
    param($Labels)
    @($Labels | ForEach-Object { if ($_ -is [string]) { $_ } else { $_.name } } | Where-Object { $_ })
}

function Get-ContractMapping {
    param([string]$Content, [string]$Concept)
    if (-not $Content) { return $null }
    $escaped = [regex]::Escape($Concept)
    $match = [regex]::Match($Content, "(?im)^\|\s*$escaped\s*\|\s*[^|]+\|\s*`?([^|`]+?)`?\s*\|$")
    if ($match.Success) { return $match.Groups[1].Value.Trim() }
    return $null
}

function Get-PointerCount {
    param([string]$RelativePath)
    $instructionFile = @('AGENTS.md', 'CLAUDE.md') | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1
    if (-not $instructionFile) { return 0 }
    return @((Get-Content -LiteralPath $instructionFile) | Select-String -SimpleMatch $RelativePath).Count
}

$repoJson = gh repo view $Repository --json nameWithOwner,url,visibility,hasIssuesEnabled,hasProjectsEnabled
$repo = $repoJson | ConvertFrom-Json
$labels = @(gh label list --repo $Repository --limit 200 --json name,description,color | ConvertFrom-Json)
$rawIssues = @(gh issue list --repo $Repository --state all --limit 1000 --json number,title,state,labels,url,parent,subIssuesSummary,projectItems,milestone | ConvertFrom-Json)
$milestones = @(gh api --paginate "repos/$Repository/milestones?state=all&per_page=100" | ConvertFrom-Json)

$bbContractPath = Join-Path (Get-Location) 'docs/agents/bb-skills.md'
$bbContent = if (Test-Path -LiteralPath $bbContractPath) { Get-Content -Raw -LiteralPath $bbContractPath } else { '' }
$mappings = [ordered]@{
    Ticket = Get-ContractMapping $bbContent 'Ticket'
    Task = Get-ContractMapping $bbContent 'Task'
    AgentExecutor = Get-ContractMapping $bbContent 'Agent executor'
    HumanExecutor = Get-ContractMapping $bbContent 'Human executor'
    NeedsDetails = Get-ContractMapping $bbContent 'Needs details'
}
$requiredLabels = @($mappings.Values | Where-Object { $_ -and $_ -ne 'Not used' } | Select-Object -Unique)
$bbCompatible = $mappings.Ticket -and $mappings.Task -and $mappings.AgentExecutor -and $mappings.HumanExecutor -and $mappings.NeedsDetails

$issues = @(
    foreach ($issue in $rawIssues) {
        [pscustomobject]@{
            Number = $issue.number
            Title = $issue.title
            State = $issue.state
            Url = $issue.url
            Labels = @(Get-LabelNames $issue.labels)
            Milestone = if ($issue.milestone) { [pscustomobject]@{ Title = $issue.milestone.title; Number = $issue.milestone.number } } else { $null }
            Parent = $issue.parent
            SubIssuesSummary = $issue.subIssuesSummary
            ProjectItems = $issue.projectItems
        }
    }
)

$projectsPayload = gh project list --owner $Owner --limit 100 --format json | ConvertFrom-Json
$projects = if ($projectsPayload.projects) { @($projectsPayload.projects) } else { @($projectsPayload) }
if (-not $ProjectNumber -and $projects.Count -eq 1) { $ProjectNumber = [int]$projects[0].number }

$projectState = [ordered]@{
    Exists = $false
    Title = $null
    Visibility = $null
    LinkageVerifiable = $false
    LinkedRepositories = @()
    ItemUrls = @()
    CustomFields = @()
    StatusOptions = @()
    Views = @()
    Workflows = [ordered]@{ Verifiable = $false }
}

if ($ProjectNumber) {
    $projectPayload = gh project view $ProjectNumber --owner $Owner --format json | ConvertFrom-Json
    $itemsPayload = gh project item-list $ProjectNumber --owner $Owner --limit 1000 --format json | ConvertFrom-Json
    $fieldsPayload = gh project field-list $ProjectNumber --owner $Owner --limit 100 --format json | ConvertFrom-Json
    $projectState.Exists = $true
    $projectState.Title = $projectPayload.title
    $projectState.Visibility = if ($projectPayload.public -eq $true) { 'PUBLIC' } else { 'PRIVATE' }
    $projectState.ItemUrls = @(
        @($itemsPayload.items) | ForEach-Object {
            if ($_.content.url) { $_.content.url } elseif ($_.url) { $_.url }
        } | Where-Object { $_ } | Select-Object -Unique
    )
    $fields = if ($fieldsPayload.fields) { @($fieldsPayload.fields) } else { @($fieldsPayload) }
    $statusField = $fields | Where-Object { $_.name -eq 'Status' } | Select-Object -First 1
    $projectState.StatusOptions = @($statusField.options | ForEach-Object { $_.name })
    $builtIn = @('Title', 'Assignees', 'Status', 'Labels', 'Milestone', 'Repository', 'Tracked by', 'Tracks', 'Reviewers', 'Linked pull requests')
    $projectState.CustomFields = @($fields | Where-Object { $_.name -notin $builtIn } | ForEach-Object { $_.name })

    $ownerType = gh api "users/$Owner" --jq .type
    try {
        $query = if ("$ownerType".Trim() -eq 'Organization') {
            'query($login:String!,$number:Int!){organization(login:$login){projectV2(number:$number){repositories(first:100){nodes{nameWithOwner}}}}}'
        } else {
            'query($login:String!,$number:Int!){user(login:$login){projectV2(number:$number){repositories(first:100){nodes{nameWithOwner}}}}}'
        }
        $linkagePayload = gh api graphql -f query=$query -F login=$Owner -F number=$ProjectNumber | ConvertFrom-Json
        $nodes = if ("$ownerType".Trim() -eq 'Organization') {
            @($linkagePayload.data.organization.projectV2.repositories.nodes)
        } else {
            @($linkagePayload.data.user.projectV2.repositories.nodes)
        }
        $projectState.LinkedRepositories = @($nodes | ForEach-Object { $_.nameWithOwner })
        $projectState.LinkageVerifiable = $true
    } catch {
        $warnings.Add("Project repository linkage could not be verified through GraphQL: $($_.Exception.Message)")
    }

    try {
        $viewsEndpoint = if ("$ownerType".Trim() -eq 'Organization') {
            "orgs/$Owner/projectsV2/$ProjectNumber/views"
        } else {
            "users/$Owner/projectsV2/$ProjectNumber/views"
        }
        $viewsPayload = gh api -H 'X-GitHub-Api-Version: 2026-03-10' $viewsEndpoint | ConvertFrom-Json
        $rawViews = if ($viewsPayload.values) { @($viewsPayload.values) } elseif ($viewsPayload.value) { @($viewsPayload.value) } else { @($viewsPayload) }
        $projectState.Views = @(
            foreach ($view in $rawViews) {
                [pscustomobject]@{
                    Name = $view.name
                    Layout = "$($view.layout)".ToLowerInvariant()
                    Filter = $view.filter
                    PresentationVerifiable = [bool]($view.column_by_name -and $view.slice_by_name -and $view.visible_field_names)
                    ColumnBy = $view.column_by_name
                    SliceBy = $view.slice_by_name
                    Swimlanes = if ($view.vertical_group_by) { $view.vertical_group_by_name } else { 'none' }
                    SortBy = if ($view.sort_by) { 'configured' } else { 'manual' }
                    FieldSum = if ($view.sum) { $view.sum } else { 'count' }
                    VisibleFields = @($view.visible_field_names)
                }
            }
        )
    } catch {
        $warnings.Add("Project views could not be read through the public API: $($_.Exception.Message)")
    }

}

$githubContractPath = Join-Path (Get-Location) 'docs/agents/github-project.md'
[ordered]@{
    Repository = [ordered]@{
        Exists = $true
        NameWithOwner = $repo.nameWithOwner
        Url = $repo.url
        Visibility = "$($repo.visibility)".ToUpperInvariant()
    }
    BbContract = [ordered]@{
        Exists = Test-Path -LiteralPath $bbContractPath
        Compatible = [bool]$bbCompatible
        Mappings = $mappings
        RequiredLabels = $requiredLabels
        PointerCount = Get-PointerCount 'docs/agents/bb-skills.md'
    }
    GitHubProjectContract = [ordered]@{
        Exists = Test-Path -LiteralPath $githubContractPath
        PointerCount = Get-PointerCount 'docs/agents/github-project.md'
    }
    Labels = @($labels | ForEach-Object { [pscustomobject]@{ Name=$_.name; Description=$_.description; Color=$_.color } })
    Milestones = @($milestones | ForEach-Object { [pscustomobject]@{ Number=$_.number; Title=$_.title; State=$_.state; DueOn=$_.due_on } })
    Issues = $issues
    Projects = $projects
    Project = [pscustomobject]$projectState
    InspectionWarnings = @($warnings)
} | ConvertTo-Json -Depth 30
