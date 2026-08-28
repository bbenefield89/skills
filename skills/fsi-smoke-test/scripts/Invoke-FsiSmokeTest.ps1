<#
.SYNOPSIS
    Agent-run smoke test for FSI Interface. Sources its request set from the local
    WireMock stubs (MockData/Stubs), submits each to the NON-MOCK /v1/patients
    endpoint, polls /v1/orchestration/{jobId} until each finishes, then reports
    which requests completed with real (non-empty) data and no errors.

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

    A request "passes" only when: orchestration Status == Completed AND data is
    non-empty AND the result message contains no failure text. Failures are
    classified (stale-data / auth-401 / timeout / orchestration-error / empty-data /
    submit-fail) so the agent can report WHY, not just THAT.

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
    Seconds between status polls. Default 3.

.PARAMETER PollTimeoutSeconds
    Max seconds to wait per request before giving up. Default 180.

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
    [int]    $PollTimeoutSeconds  = 180,
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

# --- Submit -------------------------------------------------------------------
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
    try {
        $resp = Invoke-RestMethod -Uri "$BaseUrl/v1/patients" -Method POST -Headers $headers -Body ($body | ConvertTo-Json -Compress) -TimeoutSec 30
        $jobs += [pscustomobject]@{ Req = $req; JobId = $resp.jobId; SubmitError = $null; SubmitStatus = 202 }
        Write-Host ("  submitted {0,-28} jobId={1}" -f $req.Name, $resp.jobId)
    } catch {
        $status = try { [int]$_.Exception.Response.StatusCode } catch { 0 }
        $msg = Read-ErrorBody $_
        $jobs += [pscustomobject]@{ Req = $req; JobId = $null; SubmitError = $msg; SubmitStatus = $status }
        Write-Host ("  SUBMIT FAIL {0,-28} {1}" -f $req.Name, $msg) -ForegroundColor Red
    }
}

# --- Classify a finished (or failed) request ---------------------------------
function Get-FailureKind {
    param($Status, [int]$DataChars, [string]$Message, [string]$SubmitError, [int]$SubmitStatus)

    if ($SubmitError) {
        if ($SubmitStatus -eq 401 -or $SubmitError -match "not authorized|unauthorized|401") { return "auth-401" }
        return "submit-fail"
    }
    if ($Status -in @("Failed", "Terminated")) { return "orchestration-error" }
    if ($Status -ne "Completed") { return "timeout" }

    $hasError = $Message -match "fail|error|not authorized|not found|notfound|exception"
    if ($DataChars -gt 0 -and -not $hasError) { return $null }   # pass

    if ($Message -match "not ?found|no .*(found|match)|stale") { return "stale-data" }
    if ($DataChars -eq 0) { return "empty-data" }
    return "orchestration-error"
}

# --- Poll ---------------------------------------------------------------------
$rows = @()
foreach ($job in $jobs) {
    if (-not $job.JobId) {
        $kind = Get-FailureKind -Status "SUBMIT_FAIL" -DataChars 0 -Message "" -SubmitError $job.SubmitError -SubmitStatus $job.SubmitStatus
        $rows += [pscustomobject]@{
            Request = $job.Req.Name; Emr = $job.Req.Emr; EmrId = $job.Req.EmrId
            Mrn = $job.Req.MedicalRecordNumber; Csn = $job.Req.ContactSerialNumber; DateOfService = $job.Req.DateOfService
            Status = "SUBMIT_FAIL"; DataChars = 0; JobId = "-"; Pass = $false; FailureKind = $kind; Message = $job.SubmitError
        }
        continue
    }

    $status = "Pending"; $elapsed = 0; $r = $null
    while ($elapsed -lt $PollTimeoutSeconds -and $status -notin @("Completed", "Failed", "Terminated")) {
        Start-Sleep -Seconds $PollIntervalSeconds
        $elapsed += $PollIntervalSeconds
        try {
            $r = Invoke-RestMethod -Uri "$BaseUrl/v1/orchestration/$($job.JobId)" -Method GET -Headers $headers -TimeoutSec 30
            $status = $r.status
        } catch {
            $status = "Pending"   # 404 during the init window — keep waiting
        }
    }

    $dataChars = if ($r -and $r.data) { ($r.data | Out-String).Length } else { 0 }
    $message   = if ($r) { ($r.message -split "`n")[0] } else { "no status response" }
    $kind      = Get-FailureKind -Status $status -DataChars $dataChars -Message $message -SubmitError $null -SubmitStatus 202
    $pass      = ($null -eq $kind)

    $rows += [pscustomobject]@{
        Request = $job.Req.Name; Emr = $job.Req.Emr; EmrId = $job.Req.EmrId
        Mrn = $job.Req.MedicalRecordNumber; Csn = $job.Req.ContactSerialNumber; DateOfService = $job.Req.DateOfService
        Status = $status; DataChars = $dataChars; JobId = $job.JobId; Pass = $pass; FailureKind = $kind; Message = $message
    }
}

# --- Render clean box table (no raw JSON) ------------------------------------
function Write-BoxTable($rows) {
    $headers = @("Request", "Status", "Data", "jobId")
    $display = foreach ($row in $rows) {
        $jid = if ($row.JobId.Length -gt 8) { $row.JobId.Substring(0, 8) + [char]0x2026 } else { $row.JobId }
        [pscustomobject]@{
            Cells = @(
                $row.Request,
                $(if ($row.Pass) { $row.Status } else { "$($row.Status)*" }),
                ("{0:N0} chars" -f $row.DataChars),
                $jid
            )
            Pass = $row.Pass
        }
    }
    $widths = @(0, 0, 0, 0)
    for ($i = 0; $i -lt 4; $i++) {
        $widths[$i] = $headers[$i].Length
        foreach ($d in $display) { if ($d.Cells[$i].Length -gt $widths[$i]) { $widths[$i] = $d.Cells[$i].Length } }
    }
    $H = [char]0x2500; $V = [char]0x2502
    function _border($l, $m, $r) {
        $s = "$l"
        for ($i = 0; $i -lt 4; $i++) { $s += ([string]$H * ($widths[$i] + 2)); if ($i -lt 3) { $s += $m } }
        return $s + $r
    }
    function _dataRow($cells) {
        $s = "$V"
        for ($i = 0; $i -lt 4; $i++) { $s += " " + ([string]$cells[$i]).PadRight($widths[$i]) + " $V" }
        return $s
    }
    Write-Host (_border ([char]0x250C) ([char]0x252C) ([char]0x2510))
    Write-Host (_dataRow $headers)
    Write-Host (_border ([char]0x251C) ([char]0x253C) ([char]0x2524))
    foreach ($d in $display) {
        if ($d.Pass) { Write-Host (_dataRow $d.Cells) } else { Write-Host (_dataRow $d.Cells) -ForegroundColor Yellow }
    }
    Write-Host (_border ([char]0x2514) ([char]0x2534) ([char]0x2518))
}

Write-Host ""
Write-BoxTable $rows

$passed = ($rows | Where-Object Pass).Count
Write-Host ""
Write-Host ("PASSED {0}/{1}  (Completed + non-empty data + no error)" -f $passed, $rows.Count) -ForegroundColor $(if ($passed -eq $rows.Count) { "Green" } else { "Yellow" })

$fails = $rows | Where-Object { -not $_.Pass }
if ($fails) {
    Write-Host "`nFailures (* in table):" -ForegroundColor Yellow
    foreach ($f in $fails) { Write-Host ("  {0}: {1} ({2})" -f $f.Request, $f.FailureKind, $f.Message) }
}

# --- Write machine-readable results for the agent ----------------------------
$result = [pscustomobject]@{
    generatedAt = (Get-Date).ToUniversalTime().ToString("o")
    baseUrl     = $BaseUrl
    stubsPath   = $StubsPath
    set         = $Set
    summary     = [pscustomobject]@{
        passed    = $passed
        total     = $rows.Count
        allPassed = ($passed -eq $rows.Count)
    }
    results     = $rows
}
$result | ConvertTo-Json -Depth 6 | Set-Content -Path $ResultJsonPath -Encoding utf8
Write-Host ""
Write-Host "Results JSON: $ResultJsonPath" -ForegroundColor DarkGray

if ($PassThru) { $rows }
