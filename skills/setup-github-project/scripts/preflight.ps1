[CmdletBinding()]
param(
    [ValidatePattern('^[^/]+/[^/]+$')]
    [string]$Repository
)

$ErrorActionPreference = 'Continue'
$minimumGhVersion = [version]'2.94.0'
$checks = [ordered]@{}
$missing = [System.Collections.Generic.List[string]]::new()
$guidance = [System.Collections.Generic.List[string]]::new()

function Add-Missing {
    param(
        [Parameter(Mandatory = $true)][string]$Name,
        [Parameter(Mandatory = $true)][string]$Action
    )

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
if ($checks.GitInstalled) {
    $insideOutput = git rev-parse --is-inside-work-tree 2>$null
    $insideWorkTree = ($LASTEXITCODE -eq 0 -and "$insideOutput".Trim() -eq 'true')
    if ($insideWorkTree) {
        $remoteUrl = (git config --get remote.origin.url 2>$null | Select-Object -First 1)
        if (-not $remoteUrl) {
            $firstRemote = (git remote 2>$null | Select-Object -First 1)
            if ($firstRemote) {
                $remoteUrl = (git remote get-url $firstRemote 2>$null | Select-Object -First 1)
            }
        }
    }
}
$checks.InsideGitRepository = $insideWorkTree
if (-not $insideWorkTree) {
    Add-Missing 'The current directory is not a Git worktree.' 'Open the target repository directory or initialize Git, then rerun preflight.'
}

$resolvedRepository = $Repository
if (-not $resolvedRepository -and $remoteUrl) {
    $cleanRemote = "$remoteUrl".Trim() -replace '\.git$', ''
    if ($cleanRemote -match 'github\.com[/:]([^/]+)/([^/]+)$') {
        $resolvedRepository = "$($Matches[1])/$($Matches[2])"
    }
}
$checks.GitHubRemote = [bool]$resolvedRepository
if (-not $resolvedRepository) {
    Add-Missing 'No GitHub OWNER/REPO could be resolved.' 'Add a GitHub remote or rerun preflight with -Repository OWNER/REPO.'
}

$ghCommand = Get-Command gh -ErrorAction SilentlyContinue
$checks.GitHubCliInstalled = $null -ne $ghCommand
$detectedGhVersion = $null
if (-not $checks.GitHubCliInstalled) {
    Add-Missing 'GitHub CLI is not installed or not on PATH.' 'On Windows run: winget install --id GitHub.cli --exact; then reopen the terminal.'
} else {
    $versionOutput = gh --version 2>$null | Select-Object -First 1
    if ("$versionOutput" -match '(\d+\.\d+\.\d+)') {
        $detectedGhVersion = [version]$Matches[1]
    }
    $checks.GitHubCliVersionSupported = ($null -ne $detectedGhVersion -and $detectedGhVersion -ge $minimumGhVersion)
    if (-not $checks.GitHubCliVersionSupported) {
        Add-Missing "GitHub CLI $detectedGhVersion is older than $minimumGhVersion." 'On Windows run: winget upgrade --id GitHub.cli --exact; then reopen the terminal.'
    }
}

$authenticated = $false
if ($checks.GitHubCliInstalled) {
    $null = gh auth status 2>$null
    $authenticated = $LASTEXITCODE -eq 0
}
$checks.GitHubAuthenticated = $authenticated
if ($checks.GitHubCliInstalled -and -not $authenticated) {
    Add-Missing 'GitHub CLI is not authenticated.' 'Run: gh auth login --scopes "repo,project"'
}

$repoData = $null
if ($authenticated -and $resolvedRepository) {
    $repoJson = gh repo view $resolvedRepository --json nameWithOwner,url,hasIssuesEnabled,hasProjectsEnabled 2>$null
    if ($LASTEXITCODE -eq 0 -and $repoJson) {
        $repoData = $repoJson | ConvertFrom-Json
    }
}
$checks.RepositoryAccessible = $null -ne $repoData
if ($authenticated -and $resolvedRepository -and -not $checks.RepositoryAccessible) {
    Add-Missing "The authenticated account cannot access $resolvedRepository." 'Confirm OWNER/REPO and authenticate an account with repository access.'
}

if ($repoData) {
    $checks.IssuesEnabled = [bool]$repoData.hasIssuesEnabled
    $checks.ProjectsEnabled = [bool]$repoData.hasProjectsEnabled
    if (-not $checks.IssuesEnabled) {
        Add-Missing 'GitHub Issues is disabled for the repository.' 'Ask the repository administrator to enable Issues before continuing.'
    }
    if (-not $checks.ProjectsEnabled) {
        Add-Missing 'GitHub Projects is disabled for the repository.' 'Ask the repository administrator to enable Projects before continuing.'
    }
} else {
    $checks.IssuesEnabled = $false
    $checks.ProjectsEnabled = $false
}

$projectApiAccessible = $false
if ($authenticated -and $resolvedRepository) {
    $repositoryOwner = $resolvedRepository.Split('/', 2)[0]
    $null = gh project list --owner $repositoryOwner --limit 1 --format json 2>$null
    $projectApiAccessible = $LASTEXITCODE -eq 0
}
$checks.ProjectApiAccessible = $projectApiAccessible
if ($authenticated -and $resolvedRepository -and -not $projectApiAccessible) {
    Add-Missing 'The current GitHub token cannot access Projects for the repository owner.' 'Run: gh auth refresh -s project; then rerun preflight.'
}

[ordered]@{
    Ready = $missing.Count -eq 0
    Repository = $resolvedRepository
    RemoteUrl = $remoteUrl
    GitHubCliVersion = if ($detectedGhVersion) { $detectedGhVersion.ToString() } else { $null }
    MinimumGitHubCliVersion = $minimumGhVersion.ToString()
    Checks = $checks
    Missing = @($missing)
    Guidance = @($guidance)
} | ConvertTo-Json -Depth 8

exit 0
