<#
.SYNOPSIS
    Agent-run smoke test for FSI Interface. Sources its request set from the local
    WireMock stubs (MockData/Stubs), submits each to the NON-MOCK /v1/patients
    endpoint, polls /v1/orchestration/{jobId} concurrently until each finishes, then
    reports which requests completed with real (non-empty) data and no errors.

.DESCRIPTION
    Answers one question: is the running stack retrieving patient data end to end?

    Hard-won facts baked in (see SKILL.md for the story):
      * Endpoint  : POST {BaseUrl}/v1/patients          (NON-mock — real EMR)
                    GET  {BaseUrl}/v1/orchestration/{jobId}
      * Auth      : header X-MS-CLIENT-PRINCIPAL-ID = "local-dev"
                    The container runs ASPNETCORE_ENVIRONMENT=Development, so the
                    consumer registry loads from consumer-client-mappings.Development.json,
                    whose only consumer OID is the literal string "local-dev"
                    (authorized for emrId 0 orgs 0-4 and emrId 2 orgs 0-1).
      * Scope     : Epic Sandbox (emrId 0, org 0) + Oracle/Cerner Sandbox (emrId 2, org 0).
      * Source    : request identifiers (MRN, CSN, DateOfService) are read from the
                    stub files' metadata.fsiiInput block — NOT hand-maintained here.

    Polling is CONCURRENT: all requests are submitted first, then every outstanding
    job is polled round-robin against a single wall-clock budget (PollTimeoutSeconds).
    Full-chart orchestrations routinely take minutes and can exceed 12 minutes, so a
    serial "drain one job before starting the next" loop would let one slow job stall
    the rest and freeze false "timeout" verdicts. After the poll loop a final re-check
    catches any job that finished right at the deadline. A job still running at the
    budget is reported as `slow` (soft) — not a hard failure.

    A request "passes" only when: orchestration Status == Completed AND data is
    non-empty AND the result message contains no failure text. Failures are classified
    (stale-data / auth-401 / slow / orchestration-error / empty-data / submit-fail) so
    the agent can report WHY, not just THAT.

    Machine-readable results are written to a JSON file (default: OS temp dir) for the
    agent to read. The terminal shows only a clean table — never the raw JSON.

.PARAMETER BaseUrl
    FSI Interface API base. Default http://localhost:8076/api

.PARAMETER Oid
    X-MS-CLIENT-PRINCIPAL-ID header value. Default "local-dev".

.PARAMETER StubsPath
    Path to MockData/Stubs in the local FSI checkout. Default C:\repos\Fsi\MockData\Stubs.

.PARAMETER Set
    Which sandbox(es) to test: Epic, Oracle, or Both (default).

.PARAMETER Sample
    How many encounters per EMR to test by default. Default 3. Ignored when -All is set.

.PARAMETER All
    Test every stub-sourced encounter for the selected set instead of a sample.

.PARAMETER ResultJsonPath
    Where to write the machine-readable results. Default {temp}\fsi-smoke-test-result.json.

.PARAMETER PollIntervalSeconds
    Seconds between poll passes over all outstanding jobs. Default 3.

.PARAMETER PollTimeoutSeconds
    Overall wall-clock budget for the whole poll phase (not per-job). Default 600.
    Full-chart jobs can exceed 12 minutes; raise this if you see `slow` results.

.PARAMETER PassThru
    Also return the result rows as objects (default: print table + write JSON only).

.EXAMPLE
    ./Invoke-FsiSmokeTest.ps1
.EXAMPLE
    ./Invoke-FsiSmokeTest.ps1 -Set Epic
.EXAMPLE
    ./Invoke-FsiSmokeTest.ps1 -All
#>
[CmdletBinding()]
param(
    [string] $BaseUrl             = "http://localhost:8076/api",
    [string] $Oid                 = "local-dev",
    [string] $StubsPath           = "C:\repos\Fsi\MockData\Stubs",
    [ValidateSet("Epic", "Oracle", "Both")]
    [string] $Set                 = "Both",
    [int]    $Sample              = 3,
    [switch] $All,
    [string] $ResultJsonPath      = (Join-Path ([IO.Path]::GetTempPath()) "fsi-smoke-test-result.json"),
    [int]    $PollIntervalSeconds = 3,
    [int]    $PollTimeoutSeconds  = 600,
    [switch] $PassThru
)

$ErrorActionPreference = "Stop"

# Epic Sandbox => emrId 0, Cerner Sandbox => emrId 2. The skill is scoped to org 0
# of each; the stub folders hold only org-0 patient data.
$SandboxFolders = @(
    @{ Folder = "Epic Sandbox";   EmrId = 0; Emr = "Epic" },
    @{ Folder = "Cerner Sandbox"; EmrId = 2; Emr = "Oracle" }
)

function Read-ErrorBody($err) {
    if ($err.Exception.Response) {
        try { return (New-Object IO.StreamReader($err.Exception.Response.GetResponseStream())).ReadToEnd() } catch { }
    }
    return $err.Exception.Message
}

# ---------------------------------------------------------------------------
# Parse the WireMock stubs into a flat request set. Each stub carries the
# request identifiers under metadata.fsiiInput and the patient name under
# metadata.description. Variant/response-only stubs have no fsiiInput — skip them.
# Dedupe by (emrId, MRN, CSN) so format-variant duplicates collapse to one request.
# ---------------------------------------------------------------------------
function Get-StubRequests {
    param([string] $Root, [array] $Sandboxes)

    $seen = @{}
    $requests = @()

    foreach ($sb in $Sandboxes) {
        $dir = Join-Path $Root $sb.Folder
        if (-not (Test-Path $dir)) { continue }

        foreach ($file in Get-ChildItem -Path $dir -Filter *.json -File) {
            try { $json = Get-Content -Raw -LiteralPath $file.FullName | ConvertFrom-Json } catch { continue }

            $fi = $json.metadata.fsiiInput
            if (-not $fi -or -not $fi.medicalRecordNumber -or -not $fi.contactSerialNumber) { continue }

            $emrId = if ($null -ne $fi.emrId) { [int]$fi.emrId } else { $sb.EmrId }
            $org   = if ($fi.organizationId) { [string]$fi.organizationId } else { "0" }
            $mrn   = [string]$fi.medicalRecordNumber
            $csn   = [string]$fi.contactSerialNumber

            $key = "$emrId|$mrn|$csn"
            if ($seen.ContainsKey($key)) { continue }
            $seen[$key] = $true

            # DateOfService may be a full datetime in the stub; the request needs a
            # past yyyy-MM-dd. Normalize to the date portion.
            $dos = [string]$fi.dateOfService
            $parsed = [datetime]::MinValue
            if ([datetime]::TryParse($dos, [ref]$parsed)) { $dos = $parsed.ToString("yyyy-MM-dd") }

            $name = if ($json.metadata.description) { [string]$json.metadata.description } else { "$($sb.Emr) $csn" }

            $requests += [pscustomobject]@{
                Name          = $name
                Emr           = $sb.Emr
                EmrId         = $emrId
                OrganizationId = $org
                MedicalRecordNumber = $mrn
                ContactSerialNumber = $csn
                DateOfService = $dos
            }
        }
    }
    return $requests
}

# Classify a finished (or failed) request. $Terminal is false when the job never
# reached a terminal status within the budget => `slow` (soft, non-pass).
function Get-FailureKind {
    param($Status, [bool]$Terminal, [int]$DataChars, [string]$Message, [string]$SubmitError, [int]$SubmitStatus)

    if ($SubmitError) {
        if ($SubmitStatus -eq 401 -or $SubmitError -match "not authorized|unauthorized|401") { return "auth-401" }
        return "submit-fail"
    }
    if (-not $Terminal) { return "slow" }
    if ($Status -in @("Failed", "Terminated")) { return "orchestration-error" }
    if ($Status -ne "Completed") { return "slow" }

    $hasError = $Message -match "fail|error|not authorized|not found|notfound|exception|more than one"
    if ($DataChars -gt 0 -and -not $hasError) { return $null }   # pass

    if ($Message -match "not ?found|no .*(found|match)|stale") { return "stale-data" }
    if ($DataChars -eq 0) { return "empty-data" }
    return "orchestration-error"
}

Write-Host "FSI smoke test -> $BaseUrl/v1/patients  (OID: $Oid)" -ForegroundColor Cyan

# --- Preflight: is FSI Interface up? -----------------------------------------
try {
    Invoke-RestMethod -Uri "$BaseUrl/v1/endpoints" -Method GET -TimeoutSec 5 | Out-Null
} catch {
    Write-Host ""
    Write-Host "FSI Interface not reachable at $BaseUrl/v1/endpoints" -ForegroundColor Red
    Write-Host "  $($_.Exception.Message)" -ForegroundColor DarkGray
    Write-Host "  Start the stack first (docker compose up) and confirm it's listening on the host/port above." -ForegroundColor Yellow
    return
}

# --- Preflight: do the stubs exist? ------------------------------------------
if (-not (Test-Path $StubsPath)) {
    Write-Host ""
    Write-Host "Stub source not found at $StubsPath" -ForegroundColor Red
    Write-Host "  Point -StubsPath at MockData/Stubs in your local FSI checkout." -ForegroundColor Yellow
    return
}

# --- Build the request set from stubs ----------------------------------------
$wantedFolders = switch ($Set) {
    "Epic"   { $SandboxFolders | Where-Object { $_.Emr -eq "Epic" } }
    "Oracle" { $SandboxFolders | Where-Object { $_.Emr -eq "Oracle" } }
    default  { $SandboxFolders }
}

$allRequests = Get-StubRequests -Root $StubsPath -Sandboxes $wantedFolders
if (-not $allRequests -or $allRequests.Count -eq 0) {
    Write-Host ""
    Write-Host "No usable stub requests found under $StubsPath for set '$Set'." -ForegroundColor Red
    return
}

# Sample per EMR unless -All. Deterministic: sort by name, take first N.
if ($All) {
    $work = $allRequests
} else {
    $work = $allRequests |
        Group-Object EmrId |
        ForEach-Object { $_.Group | Sort-Object Name | Select-Object -First $Sample }
}

Write-Host ("  sourced {0} encounter(s) from stubs; testing {1}" -f $allRequests.Count, $work.Count)

$headers = @{ "X-MS-CLIENT-PRINCIPAL-ID" = $Oid; "Content-Type" = "application/json" }

# --- Submit all first (so polling can run concurrently) ----------------------
$jobs = @()
foreach ($req in $work) {
    $body = @{
        contactSerialNumber       = $req.ContactSerialNumber
        dateOfService             = $req.DateOfService
        emrId                     = $req.EmrId
        medicalRecordNumber       = $req.MedicalRecordNumber
        organizationId            = $req.OrganizationId
        requestedPatientResources = @("FullChart")
    }
    $submitTime = [DateTimeOffset]::UtcNow
    try {
        $resp = Invoke-RestMethod -Uri "$BaseUrl/v1/patients" -Method POST -Headers $headers -Body ($body | ConvertTo-Json -Compress) -TimeoutSec 30
        $jobs += [pscustomobject]@{
            Req = $req; JobId = $resp.jobId; SubmitError = $null; SubmitStatus = 202; SubmitTime = $submitTime
            Status = "Pending"; Response = $null; Terminal = $false; CompletedAt = $null
        }
        Write-Host ("  submitted {0,-28} jobId={1}" -f $req.Name, $resp.jobId)
    } catch {
        $status = try { [int]$_.Exception.Response.StatusCode } catch { 0 }
        $msg = Read-ErrorBody $_
        $jobs += [pscustomobject]@{
            Req = $req; JobId = $null; SubmitError = $msg; SubmitStatus = $status; SubmitTime = $submitTime
            Status = "SUBMIT_FAIL"; Response = $null; Terminal = $true; CompletedAt = $submitTime
        }
        Write-Host ("  SUBMIT FAIL {0,-28} {1}" -f $req.Name, $msg) -ForegroundColor Red
    }
}

# --- Poll concurrently against one wall-clock budget -------------------------
function Poll-Job($job) {
    try {
        $r = Invoke-RestMethod -Uri "$BaseUrl/v1/orchestration/$($job.JobId)" -Method GET -Headers $headers -TimeoutSec 30
        $job.Response = $r
        $job.Status = $r.status
        if ($r.status -in @("Completed", "Failed", "Terminated")) {
            $job.Terminal = $true
            $job.CompletedAt = [DateTimeOffset]::UtcNow
        }
    } catch {
        # 404 during the init window — leave as Pending and try again next pass.
    }
}

$deadline = (Get-Date).AddSeconds($PollTimeoutSeconds)
while ((Get-Date) -lt $deadline) {
    $outstanding = @($jobs | Where-Object { $_.JobId -and -not $_.Terminal })
    if ($outstanding.Count -eq 0) { break }
    foreach ($job in $outstanding) { Poll-Job $job }
    if (@($jobs | Where-Object { $_.JobId -and -not $_.Terminal }).Count -eq 0) { break }
    Start-Sleep -Seconds $PollIntervalSeconds
}

# --- End-of-run re-check: one final GET for anything still outstanding --------
# Catches jobs that finished between the last poll pass and the deadline.
foreach ($job in @($jobs | Where-Object { $_.JobId -and -not $_.Terminal })) { Poll-Job $job }

# --- Build result rows (camelCase) -------------------------------------------
$rows = @()
foreach ($job in $jobs) {
    $r = $job.Response
    $dataChars = if ($r -and $r.data) { ($r.data | Out-String).Length } else { 0 }
    $message = if ($job.SubmitError) { $job.SubmitError } elseif ($r) { ($r.message -split "`n")[0] } else { "no status response" }
    $kind = Get-FailureKind -Status $job.Status -Terminal $job.Terminal -DataChars $dataChars -Message $message -SubmitError $job.SubmitError -SubmitStatus $job.SubmitStatus
    $pass = ($null -eq $kind)

    $endTime = if ($job.CompletedAt) { $job.CompletedAt } else { [DateTimeOffset]::UtcNow }
    $elapsed = [int]([Math]::Round(($endTime - $job.SubmitTime).TotalSeconds))

    $rows += [pscustomobject]@{
        request        = $job.Req.Name
        emr            = $job.Req.Emr
        emrId          = $job.Req.EmrId
        mrn            = $job.Req.MedicalRecordNumber
        csn            = $job.Req.ContactSerialNumber
        dateOfService  = $job.Req.DateOfService
        status         = $job.Status
        dataChars      = $dataChars
        elapsedSeconds = $elapsed
        jobId          = if ($job.JobId) { $job.JobId } else { "-" }
        pass           = $pass
        failureKind    = $kind
        message        = $message
    }
}

# --- Render clean box table (no raw JSON) ------------------------------------
function Write-BoxTable($rows) {
    $cols = @("Request", "Status", "Data", "Elapsed", "jobId")
    $n = $cols.Count
    $display = foreach ($row in $rows) {
        $jid = if ($row.jobId.Length -gt 8) { $row.jobId.Substring(0, 8) + [char]0x2026 } else { $row.jobId }
        [pscustomobject]@{
            Cells = @(
                $row.request,
                $(if ($row.pass) { $row.status } else { "$($row.status)*" }),
                ("{0:N0} chars" -f $row.dataChars),
                ("{0}s" -f $row.elapsedSeconds),
                $jid
            )
            Pass = $row.pass
        }
    }
    $widths = @(0) * $n
    for ($i = 0; $i -lt $n; $i++) {
        $widths[$i] = $cols[$i].Length
        foreach ($d in $display) { if ($d.Cells[$i].Length -gt $widths[$i]) { $widths[$i] = $d.Cells[$i].Length } }
    }
    $H = [char]0x2500; $V = [char]0x2502
    function _border($l, $m, $r) {
        $s = "$l"
        for ($i = 0; $i -lt $n; $i++) { $s += ([string]$H * ($widths[$i] + 2)); if ($i -lt ($n - 1)) { $s += $m } }
        return $s + $r
    }
    function _dataRow($cells) {
        $s = "$V"
        for ($i = 0; $i -lt $n; $i++) { $s += " " + ([string]$cells[$i]).PadRight($widths[$i]) + " $V" }
        return $s
    }
    Write-Host (_border ([char]0x250C) ([char]0x252C) ([char]0x2510))
    Write-Host (_dataRow $cols)
    Write-Host (_border ([char]0x251C) ([char]0x253C) ([char]0x2524))
    foreach ($d in $display) {
        if ($d.Pass) { Write-Host (_dataRow $d.Cells) } else { Write-Host (_dataRow $d.Cells) -ForegroundColor Yellow }
    }
    Write-Host (_border ([char]0x2514) ([char]0x2534) ([char]0x2518))
}

Write-Host ""
Write-BoxTable $rows

$passed = ($rows | Where-Object pass).Count
Write-Host ""
Write-Host ("PASSED {0}/{1}  (Completed + non-empty data + no error)" -f $passed, $rows.Count) -ForegroundColor $(if ($passed -eq $rows.Count) { "Green" } else { "Yellow" })

$fails = $rows | Where-Object { -not $_.pass }
if ($fails) {
    Write-Host "`nFailures (* in table):" -ForegroundColor Yellow
    foreach ($f in $fails) { Write-Host ("  {0}: {1} ({2})" -f $f.request, $f.failureKind, $f.message) }
    if ($fails | Where-Object failureKind -eq "slow") {
        Write-Host "  Note: 'slow' means still running at the ${PollTimeoutSeconds}s budget, not a failure — raise -PollTimeoutSeconds and re-run." -ForegroundColor DarkGray
    }
}

# --- Write machine-readable results for the agent ----------------------------
$result = [pscustomobject]@{
    generatedAt        = (Get-Date).ToUniversalTime().ToString("o")
    baseUrl            = $BaseUrl
    stubsPath          = $StubsPath
    set                = $Set
    pollTimeoutSeconds = $PollTimeoutSeconds
    summary            = [pscustomobject]@{
        passed    = $passed
        total     = $rows.Count
        allPassed = ($passed -eq $rows.Count)
    }
    results            = $rows
}
$result | ConvertTo-Json -Depth 6 | Set-Content -Path $ResultJsonPath -Encoding utf8
Write-Host ""
Write-Host "Results JSON: $ResultJsonPath" -ForegroundColor DarkGray

if ($PassThru) { $rows }
