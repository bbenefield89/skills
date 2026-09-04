#requires -Version 7.0
<#
.SYNOPSIS
    Generates a throwaway Docker Compose override that runs an FSI stack on shifted
    ports, so it can run in parallel with the standard-port stack.

.DESCRIPTION
    Run from an FSI worktree root. Writes docker-compose.ports<Tag>.yml, adds it to
    the repo's untracked exclude file, probes the shifted host ports, and prints the
    port table plus the exact up/down commands.

    Slot N offsets every host port by N * 100. Slot 0 is the standard layout and is
    rejected.

.PARAMETER Slot
    Port slot, 1-9. Offset is Slot * 100.

.PARAMETER Tag
    Suffix for container names, image tag, log directory, and the override filename.
    Defaults to <branch-slug>-<interface port>, so FACS-824 at slot 3 gives
    facs-824-8376. Hyphens only — a colon is illegal in a container name, changes
    the meaning of an image reference, and is illegal in a Windows path.

.PARAMETER WorktreeRoot
    Worktree root. Defaults to the current directory.

.PARAMETER MainRepo
    Path to the main FSI checkout that holds the gitignored .env. Defaults to C:/repos/Fsi.

.PARAMETER Remove
    Deletes the override file and its line from the exclude file, then exits.

.EXAMPLE
    pwsh ./New-FsiStackOverride.ps1 -Slot 1

.EXAMPLE
    pwsh ./New-FsiStackOverride.ps1 -Slot 1 -Remove
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateRange(1, 9)]
    [int] $Slot,

    [ValidatePattern('^[A-Za-z0-9][A-Za-z0-9._-]*$')]
    [string] $Tag,

    [string] $WorktreeRoot = (Get-Location).Path,

    [string] $MainRepo = 'C:/repos/Fsi',

    [switch] $Remove
)

$ErrorActionPreference = 'Stop'

function Get-BranchSlug {
    param([string] $Root)

    $branch = & git -C $Root rev-parse --abbrev-ref HEAD 2>$null
    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($branch)) {
        throw "Cannot read the git branch in '$Root'. Pass -Tag explicitly."
    }

    # FACS-824 -> facs-824. Keep the prefix: two branches that share a trailing
    # number must not produce the same tag, because container names are global
    # to the Docker daemon and ignore the slot.
    return ($branch.Trim() -replace '[^A-Za-z0-9]', '-').Trim('-').ToLowerInvariant()
}

if (-not (Test-Path -LiteralPath $WorktreeRoot)) {
    throw "WorktreeRoot '$WorktreeRoot' does not exist."
}
$WorktreeRoot = (Resolve-Path -LiteralPath $WorktreeRoot).Path

$offset = $Slot * 100

# The FSI Interface front door. Standard 8076, so slot 3 gives 8376.
$interfacePort = 8076 + $offset

# Naming convention: <branch-slug>-<interface port>, e.g. facs-824-8376. A hyphen,
# never a colon — Docker container names allow only [a-zA-Z0-9][a-zA-Z0-9_.-]*, a
# colon in an image reference separates name from tag, and a colon is illegal in a
# Windows path. An explicit -Tag is used verbatim.
if (-not $Tag) { $Tag = "$(Get-BranchSlug -Root $WorktreeRoot)-$interfacePort" }

$overrideName = "docker-compose.ports-$Tag.yml"
$overridePath = Join-Path $WorktreeRoot $overrideName

# The real info/exclude lives in the main repo's git dir, not in the worktree's .git file.
$gitCommonDir = & git -C $WorktreeRoot rev-parse --git-common-dir 2>$null
if ($LASTEXITCODE -ne 0) { throw "'$WorktreeRoot' is not inside a git repository." }

# git returns this relative to the worktree root in some versions ('.git') and already
# rooted in others ('C:/repos/Fsi/.git', seen on 2.54.0.windows.1). Join only when it is
# relative — joining two rooted paths produces 'C:\wt\C:\repos\Fsi\.git', which cannot resolve.
$commonDir = if ([System.IO.Path]::IsPathRooted($gitCommonDir)) {
    $gitCommonDir
}
else {
    Join-Path $WorktreeRoot $gitCommonDir
}
$excludePath = Join-Path (Resolve-Path -LiteralPath $commonDir).Path 'info/exclude'

if ($Remove) {
    if (Test-Path -LiteralPath $overridePath) {
        Remove-Item -LiteralPath $overridePath -Force
        Write-Host "Removed $overridePath"
    }
    else {
        Write-Host "No override file at $overridePath"
    }

    if (Test-Path -LiteralPath $excludePath) {
        $kept = @(Get-Content -LiteralPath $excludePath | Where-Object { $_.Trim() -ne $overrideName })
        Set-Content -LiteralPath $excludePath -Value $kept
        Write-Host "Removed '$overrideName' from $excludePath"
    }

    Write-Host ''
    Write-Host 'Docker leftovers are not removed. Run these if you are finished with the stack:' -ForegroundColor Yellow
    $project = (Split-Path $WorktreeRoot -Leaf).ToLowerInvariant() -replace '[^a-z0-9]', ''
    Write-Host "  docker volume rm ${project}_azurite_data ${project}_redis_data ${project}_seq_data ${project}_openobserve_data"
    Write-Host "  docker image rm fsiapi-${Tag}:latest"
    return
}

# --- Sanity checks -----------------------------------------------------------

$gitDirFile = Join-Path $WorktreeRoot '.git'
if (Test-Path -LiteralPath $gitDirFile -PathType Container) {
    Write-Warning "'$WorktreeRoot' looks like the MAIN checkout, not a worktree. Do not shift the main checkout off the standard ports unless you mean to."
}

if (-not (Test-Path -LiteralPath (Join-Path $WorktreeRoot 'docker-compose.yml'))) {
    throw "No docker-compose.yml in '$WorktreeRoot'. Run this from the FSI worktree root."
}

$envFile = "$MainRepo/.env"
if (-not (Test-Path -LiteralPath $envFile)) {
    Write-Warning "No .env at '$envFile'. Without it, FSI cannot read the FHIR signing key and every FHIR call fails with 'DefaultAzureCredential failed to retrieve a token'."
}

# Compose 2.24+ is required for the '!override' YAML tag.
$composeVersion = (& docker compose version --short 2>$null)
if ($LASTEXITCODE -eq 0 -and $composeVersion) {
    Write-Host "Docker Compose $composeVersion detected. The '!override' tag needs 2.24+." -ForegroundColor DarkGray
}
else {
    Write-Warning "Could not read the Docker Compose version. The '!override' tag needs 2.24+."
}

$funcReleases = Join-Path $env:LOCALAPPDATA 'AzureFunctionsTools/Releases'
if (Test-Path -LiteralPath $funcReleases) {
    Write-Host "Azure Functions Tools releases present: $((Get-ChildItem -LiteralPath $funcReleases -Directory).Name -join ', ')" -ForegroundColor DarkGray
    Write-Host "docker-compose.headless.yml mounts one pinned version. If it is missing here, the Functions hosts will not start." -ForegroundColor DarkGray
}

# --- Port map ----------------------------------------------------------------

# name, container port, standard host port
$portMap = @(
    @{ Service = 'fsi.api';           Target = 80;    Standard = 8000  }
    @{ Service = 'fsi.orchestration'; Target = 7071;  Standard = 7071  }
    @{ Service = 'fsi.interface';     Target = 7071;  Standard = 8076  }
    @{ Service = 'seq';               Target = 80;    Standard = 5341  }
    @{ Service = 'azurite';           Target = 10000; Standard = 40000 }
    @{ Service = 'azurite';           Target = 10001; Standard = 40001 }
    @{ Service = 'azurite';           Target = 10002; Standard = 40002 }
    @{ Service = 'redis';             Target = 6379;  Standard = 6379  }
    @{ Service = 'wiremock';          Target = 8080;  Standard = 9090  }
    @{ Service = 'otel-collector';    Target = 4317;  Standard = 4317  }
    @{ Service = 'otel-collector';    Target = 4318;  Standard = 4318  }
    @{ Service = 'aspire-dashboard';  Target = 18888; Standard = 18888 }
    @{ Service = 'aspire-dashboard';  Target = 18889; Standard = 18889 }
    @{ Service = 'openobserve';       Target = 5080;  Standard = 5080  }
)

foreach ($p in $portMap) { $p['Shifted'] = $p['Standard'] + $offset }

function Get-Shifted {
    param([string] $Service, [int] $Target)
    ($portMap | Where-Object { $_['Service'] -eq $Service -and $_['Target'] -eq $Target })['Shifted']
}

# The default tag embeds the interface port, computed before this table exists.
# Fail loudly if the two ever disagree rather than shipping a misleading name.
if ((Get-Shifted 'fsi.interface' 7071) -ne $interfacePort) {
    throw "Interface port mismatch: the tag says $interfacePort, the port table says $(Get-Shifted 'fsi.interface' 7071)."
}

# --- Port collision probe ----------------------------------------------------

$listening = @{}
try {
    Get-NetTCPConnection -State Listen -ErrorAction Stop |
        ForEach-Object { $listening[[int]$_.LocalPort] = $true }
}
catch {
    Write-Warning "Could not enumerate listening ports. Skipping the collision probe."
}

$collisions = @($portMap | Where-Object { $listening.ContainsKey([int]$_['Shifted']) })
if ($collisions.Count -gt 0) {
    Write-Warning "Slot $Slot has $($collisions.Count) port(s) already in use. Pick another slot:"
    foreach ($c in $collisions) {
        Write-Warning "  $($c['Service']) -> $($c['Shifted']) is already listening."
    }
}

# --- Write the override ------------------------------------------------------

# 'ports: !override' is mandatory. Compose APPENDS ports lists across -f files, so
# without it the stack tries to bind both the standard and the shifted port.
$yaml = @"
# GENERATED by the fsi-parallel-stack skill. Throwaway. Never commit this file.
# Slot $Slot (offset +$offset). Tag '$Tag'.
#
# Start:
#   docker compose --env-file $MainRepo/.env -f docker-compose.yml -f docker-compose.override.yml -f docker-compose.headless.yml -f $overrideName up -d
services:
  fsi.api:
    image: fsiapi-$Tag
    ports: !override ["$(Get-Shifted 'fsi.api' 80):80"]
    volumes: !override
      - `${APPDATA}/Microsoft/UserSecrets:/home/app/.microsoft/usersecrets:ro
      - C:/logs/$Tag`:/app/logs
  fsi.orchestration:
    ports: !override ["$(Get-Shifted 'fsi.orchestration' 7071):7071"]
  fsi.interface:
    ports: !override ["$(Get-Shifted 'fsi.interface' 7071):7071"]
  seq:
    ports: !override ["$(Get-Shifted 'seq' 80):80"]
  azurite:
    container_name: azurite-$Tag
    ports: !override ["$(Get-Shifted 'azurite' 10000):10000", "$(Get-Shifted 'azurite' 10001):10001", "$(Get-Shifted 'azurite' 10002):10002"]
  azurite-init:
    container_name: azurite-init-$Tag
  redis:
    container_name: redis-$Tag
    ports: !override ["$(Get-Shifted 'redis' 6379):6379"]
  wiremock:
    container_name: wiremock-local-$Tag
    ports: !override ["$(Get-Shifted 'wiremock' 8080):8080"]
  otel-collector:
    container_name: otel-collector-$Tag
    ports: !override ["$(Get-Shifted 'otel-collector' 4317):4317", "$(Get-Shifted 'otel-collector' 4318):4318"]
  aspire-dashboard:
    container_name: aspire-dashboard-$Tag
    ports: !override ["$(Get-Shifted 'aspire-dashboard' 18888):18888", "$(Get-Shifted 'aspire-dashboard' 18889):18889"]
  openobserve:
    container_name: openobserve-$Tag
    ports: !override ["$(Get-Shifted 'openobserve' 5080):5080"]
"@

if (Test-Path -LiteralPath $overridePath) {
    Write-Warning "Overwriting the existing $overrideName."
}
Set-Content -LiteralPath $overridePath -Value $yaml -Encoding utf8NoBOM
Write-Host "Wrote $overridePath" -ForegroundColor Green

# --- Exclude from git (never edit the tracked .gitignore) --------------------

$excludeDir = Split-Path $excludePath -Parent
if (-not (Test-Path -LiteralPath $excludeDir)) {
    New-Item -ItemType Directory -Path $excludeDir -Force | Out-Null
}

$already = (Test-Path -LiteralPath $excludePath) -and
           (Get-Content -LiteralPath $excludePath | Where-Object { $_.Trim() -eq $overrideName })

if ($already) {
    Write-Host "'$overrideName' is already excluded in $excludePath" -ForegroundColor DarkGray
}
else {
    Add-Content -LiteralPath $excludePath -Value $overrideName
    Write-Host "Excluded '$overrideName' via $excludePath" -ForegroundColor Green
}

$status = & git -C $WorktreeRoot status --porcelain
if ($status) {
    Write-Warning "The worktree is not clean. Confirm the override file is not listed:"
    $status | ForEach-Object { Write-Warning "  $_" }
}

# --- Report ------------------------------------------------------------------

$composeFiles = '-f docker-compose.yml -f docker-compose.override.yml -f docker-compose.headless.yml -f ' + $overrideName
$prefix       = "docker compose --env-file $MainRepo/.env $composeFiles"

Write-Host ''
Write-Host "Port table (slot $Slot, offset +$offset)" -ForegroundColor Cyan
$portMap |
    ForEach-Object { [pscustomobject]@{ Service = $_['Service']; Target = $_['Target']; Standard = $_['Standard']; Shifted = $_['Shifted'] } } |
    Format-Table -AutoSize |
    Out-String |
    Write-Host

Write-Host 'Verify the merge BEFORE starting. Every service must show exactly one published port per target:' -ForegroundColor Cyan
Write-Host "  $prefix config --format json"
Write-Host ''
Write-Host 'Start:' -ForegroundColor Cyan
Write-Host "  $prefix up -d"
Write-Host ''
Write-Host 'Stop:' -ForegroundColor Cyan
Write-Host "  $prefix down --remove-orphans"
Write-Host ''
Write-Host 'FSI Interface front door:' -ForegroundColor Cyan
Write-Host "  http://localhost:$(Get-Shifted 'fsi.interface' 7071)/api/v1/patients   (header X-MS-CLIENT-PRINCIPAL-ID: local-dev)"
Write-Host ''
Write-Host 'Do not tear down a Compose project you did not start. Check `docker compose ls` first.' -ForegroundColor Yellow
