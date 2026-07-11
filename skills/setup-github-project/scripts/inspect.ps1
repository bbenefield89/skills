[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidatePattern('^[^/]+/[^/]+$')]
    [string]$Repository
)

$ErrorActionPreference = 'Stop'

if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    throw 'GitHub CLI (gh) is required.'
}

$owner, $name = $Repository.Split('/', 2)
$requiredLabels = @('phase', 'epic', 'spec', 'ready-for-agent', 'ready-for-human')
$labels = @(gh label list --repo $Repository --limit 200 --json name,description | ConvertFrom-Json)
$issues = @(gh issue list --repo $Repository --state all --limit 1000 --json number,title,state,labels,url,parent,subIssuesSummary,projectItems | ConvertFrom-Json)

function Get-HasLabel {
    param(
        [Parameter(Mandatory = $true)]
        $Issue,

        [Parameter(Mandatory = $true)]
        [string]$LabelName
    )

    return @($Issue.labels | Where-Object { $_.name -eq $LabelName }).Count -gt 0
}

[ordered]@{
    Auth = (gh auth status 2>&1 | Out-String).Trim()
    Repository = (gh repo view $Repository --json nameWithOwner,url,visibility,defaultBranchRef | ConvertFrom-Json)
    RequiredLabels = $requiredLabels
    MissingLabels = @($requiredLabels | Where-Object { $_ -notin $labels.name })
    Labels = $labels
    Issues = $issues
    PhaseIssues = @($issues | Where-Object { Get-HasLabel -Issue $_ -LabelName 'phase' })
    EpicIssues = @($issues | Where-Object { Get-HasLabel -Issue $_ -LabelName 'epic' })
    SpecificationIssues = @($issues | Where-Object { Get-HasLabel -Issue $_ -LabelName 'spec' })
    ImplementationTickets = @(
        $issues | Where-Object {
            (Get-HasLabel -Issue $_ -LabelName 'ready-for-agent') -or
            (Get-HasLabel -Issue $_ -LabelName 'ready-for-human')
        }
    )
    EpicsWithoutParent = @(
        $issues | Where-Object {
            (Get-HasLabel -Issue $_ -LabelName 'epic') -and (-not $_.parent)
        }
    )
    TicketsWithoutParent = @(
        $issues | Where-Object {
            ((Get-HasLabel -Issue $_ -LabelName 'ready-for-agent') -or
            (Get-HasLabel -Issue $_ -LabelName 'ready-for-human')) -and (-not $_.parent)
        }
    )
    SpecificationsWithParent = @(
        $issues | Where-Object {
            (Get-HasLabel -Issue $_ -LabelName 'spec') -and $_.parent
        }
    )
    SpecificationsWithProjectMembership = @(
        $issues | Where-Object {
            (Get-HasLabel -Issue $_ -LabelName 'spec') -and @($_.projectItems).Count -gt 0
        }
    )
    Projects = @(gh project list --owner $owner --limit 100 --format json | ConvertFrom-Json)
} | ConvertTo-Json -Depth 12
