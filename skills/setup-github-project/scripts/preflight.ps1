[CmdletBinding()]
param(
    [ValidatePattern('^[^/]+/[^/]+$')]
    [string]$Repository
)

$ErrorActionPreference = 'Continue'
Import-Module (Join-Path $PSScriptRoot 'ProjectPolicy.psm1') -Force
$minimumGhVersion = [version]'2.94.0'
$checks = [ordered]@{}
$missing = [System.Collections.Generic.List[string]]::new()
$guidance = [System.Collections.Generic.List[string]]::new()

function Add-Missing {
    param([string]$Name, [string]$Action)
    if (-not $missing.Contains($Name)) { $missing.Add($Name) }
    if (-not $guidance.Contains($Action)) { $guidance.Add($Action) }
}

$gitCommand = Get-Command git -ErrorAction SilentlyContinue
$checks.GitInstalled = $null -ne $gitCommand
if (-not $checks.GitInstalled) {
    Add-Missing 'Git is not installed or not on PATH.' 'Install Git, reopen the terminal, and rerun preflight.'
}

$insideWorkTree = $false
$remoteUrl = $null
$localRepositoryName = Split-Path -Leaf (Get-Location)
if ($checks.GitInstalled) {
    $insideOutput = git rev-parse --is-inside-work-tree 2>$null
    $insideWorkTree = $LASTEXITCODE -eq 0 -and "$insideOutput".Trim() -eq 'true'
    if ($insideWorkTree) {
        $repositoryRoot = git rev-parse --show-toplevel 2>$null
        if ($LASTEXITCODE -eq 0 -and $repositoryRoot) {
            $localRepositoryName = Split-Path -Leaf "$repositoryRoot".Trim()
        }
        $remoteUrl = git config --get remote.origin.url 2>$null | Select-Object -First 1
        if (-not $remoteUrl) {
            $firstRemote = git remote 2>$null | Select-Object -First 1
            if ($firstRemote) { $remoteUrl = git remote get-url $firstRemote 2>$null | Select-Object -First 1 }
        }
    }
}
$checks.InsideGitRepository = $insideWorkTree
if (-not $insideWorkTree) {
    Add-Missing 'The current directory is not a Git worktree.' 'Open the target Git repository and rerun preflight.'
}

$resolvedRepository = $Repository
if (-not $resolvedRepository -and $remoteUrl) {
    $cleanRemote = "$remoteUrl".Trim() -replace '\.git$', ''
    if ($cleanRemote -match 'github\.com[/:]([^/]+)/([^/]+)$') {
        $resolvedRepository = "$($Matches[1])/$($Matches[2])"
    }
}

$ghCommand = Get-Command gh -ErrorAction SilentlyContinue
$checks.GitHubCliInstalled = $null -ne $ghCommand
$detectedGhVersion = $null
if (-not $checks.GitHubCliInstalled) {
    Add-Missing 'GitHub CLI is not installed or not on PATH.' 'Install GitHub CLI 2.94.0 or newer, reopen the terminal, and rerun preflight.'
} else {
    $versionOutput = gh --version 2>$null | Select-Object -First 1
    if ("$versionOutput" -match '(\d+\.\d+\.\d+)') { $detectedGhVersion = [version]$Matches[1] }
    $checks.GitHubCliVersionSupported = $null -ne $detectedGhVersion -and $detectedGhVersion -ge $minimumGhVersion
    if (-not $checks.GitHubCliVersionSupported) {
        Add-Missing "GitHub CLI $detectedGhVersion is older than $minimumGhVersion." 'Upgrade GitHub CLI to 2.94.0 or newer, then rerun preflight.'
    }
}

$authenticatedAccounts = @()
if ($checks.GitHubCliInstalled) {
    $authJson = gh auth status --json hosts 2>$null
    if ($LASTEXITCODE -eq 0 -and $authJson) {
        try {
            $auth = $authJson | ConvertFrom-Json
            $authenticatedAccounts = @(
                $auth.hosts.'github.com' |
                    Where-Object { $_.state -eq 'success' -or $_.active -eq $true } |
                    ForEach-Object { $_.login } |
                    Where-Object { $_ } |
                    Select-Object -Unique
            )
        } catch { $authenticatedAccounts = @() }
    }
    if ($authenticatedAccounts.Count -eq 0) {
        $login = gh api user --jq .login 2>$null
        if ($LASTEXITCODE -eq 0 -and $login) { $authenticatedAccounts = @("$login".Trim()) }
    }
}
$checks.GitHubAuthenticated = $authenticatedAccounts.Count -gt 0
if (-not $checks.GitHubAuthenticated -and $checks.GitHubCliInstalled) {
    Add-Missing 'GitHub CLI is not authenticated.' 'Run: gh auth login --scopes "repo,project"'
}

$bootstrapDecision = Get-RepositoryBootstrapDecision -ResolvedRepository $resolvedRepository -LocalRepositoryName $localRepositoryName -AuthenticatedAccounts $authenticatedAccounts
$selectedOwner = $bootstrapDecision.SelectedOwner
$accountSelectionRequired = $bootstrapDecision.AccountSelectionRequired
if ($accountSelectionRequired) {
    Add-Missing 'Multiple authenticated GitHub accounts are available and no repository owner is selected.' 'Choose the owner and rerun preflight with -Repository OWNER/REPO.'
}
$resolvedRepository = $bootstrapDecision.Repository

$repoData = $null
if ($checks.GitHubAuthenticated -and $resolvedRepository) {
    $repoJson = gh repo view $resolvedRepository --json nameWithOwner,url,visibility,hasIssuesEnabled,hasProjectsEnabled 2>$null
    if ($LASTEXITCODE -eq 0 -and $repoJson) { $repoData = $repoJson | ConvertFrom-Json }
}
$repositoryExists = $null -ne $repoData
$repositoryBootstrapRequired = $checks.GitHubAuthenticated -and $insideWorkTree -and $resolvedRepository -and -not $repositoryExists
$checks.RepositoryExists = $repositoryExists
$checks.RepositoryBootstrapRequired = $repositoryBootstrapRequired
$checks.IssuesEnabled = if ($repoData) { [bool]$repoData.hasIssuesEnabled } else { $true }
$checks.ProjectsEnabled = if ($repoData) { [bool]$repoData.hasProjectsEnabled } else { $true }
if ($repoData -and -not $checks.IssuesEnabled) {
    Add-Missing 'GitHub Issues is disabled for the repository.' 'Ask the repository administrator to enable Issues before continuing.'
}
if ($repoData -and -not $checks.ProjectsEnabled) {
    Add-Missing 'GitHub Projects is disabled for the repository.' 'Ask the repository administrator to enable Projects before continuing.'
}

$projectApiAccessible = $false
if ($checks.GitHubAuthenticated -and $selectedOwner) {
    $null = gh project list --owner $selectedOwner --limit 1 --format json 2>$null
    $projectApiAccessible = $LASTEXITCODE -eq 0
}
$checks.ProjectApiAccessible = $projectApiAccessible
if ($checks.GitHubAuthenticated -and $selectedOwner -and -not $projectApiAccessible) {
    Add-Missing 'The active GitHub account cannot access Projects for the proposed owner.' 'Run: gh auth refresh -s project; then rerun preflight.'
}

[ordered]@{
    Ready = $missing.Count -eq 0
    Repository = $resolvedRepository
    RepositoryExists = $repositoryExists
    RepositoryBootstrapRequired = $repositoryBootstrapRequired
    ProposedPrivateRepository = if ($repositoryBootstrapRequired) { $resolvedRepository } else { $null }
    SelectedOwner = $selectedOwner
    AuthenticatedAccounts = @($authenticatedAccounts)
    AccountSelectionRequired = $accountSelectionRequired
    LocalRepositoryName = $localRepositoryName
    RemoteUrl = $remoteUrl
    GitHubCliVersion = if ($detectedGhVersion) { $detectedGhVersion.ToString() } else { $null }
    MinimumGitHubCliVersion = $minimumGhVersion.ToString()
    Checks = $checks
    Missing = @($missing)
    Guidance = @($guidance)
} | ConvertTo-Json -Depth 8

exit 0
