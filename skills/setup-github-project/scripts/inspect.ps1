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

[ordered]@{
    Auth = (gh auth status 2>&1 | Out-String).Trim()
    Repository = (gh repo view $Repository --json nameWithOwner,url,visibility,defaultBranchRef | ConvertFrom-Json)
    Labels = @(gh label list --repo $Repository --limit 200 --json name,description | ConvertFrom-Json)
    Issues = @(gh issue list --repo $Repository --state all --limit 200 --json number,title,state,labels,url | ConvertFrom-Json)
    Projects = @(gh project list --owner $owner --limit 100 --format json | ConvertFrom-Json)
} | ConvertTo-Json -Depth 12
