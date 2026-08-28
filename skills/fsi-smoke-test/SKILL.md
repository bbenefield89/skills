---
name: fsi-smoke-test
description: Agent-run smoke test of FSI Interface patient retrieval. Sources its request set from the local WireMock stubs (MockData/Stubs), submits a small sample of Epic Sandbox + Oracle/Cerner Sandbox requests to the NON-MOCK /v1/patients endpoint with the local-dev OID, polls /v1/orchestration/{jobId} until each finishes, then reports which requests completed with real (non-empty) data and no errors — with a classified reason for each failure. Use when asked to "smoke test FSI", "run the FSI smoke test", "check FSI is retrieving patient data", or to confirm the running stack retrieves patient data end to end.
---

# FSI Smoke Test

Confirms the running FSI stack retrieves patient data end to end. Answers one question: **which requests completed and returned real data with no errors?**

This is the refined successor to `fsi-manual-test`: an agent runs it and reports the result. It sources *what to test* from the local WireMock stubs, tests the **real** retrieval path, emits machine-readable JSON for the agent plus a clean human table, and classifies every failure by reason.

## Quick start

Requires the FSI stack running locally (front door on `http://localhost:8076`) and a local FSI checkout so the stubs exist at `C:\repos\Fsi\MockData\Stubs`.

```powershell
# Default: a small sample of Epic + Oracle/Cerner encounters from the stubs
pwsh "<skill-dir>/scripts/Invoke-FsiSmokeTest.ps1"

# One sandbox only
pwsh "<skill-dir>/scripts/Invoke-FsiSmokeTest.ps1" -Set Epic

# Every stub-sourced encounter
pwsh "<skill-dir>/scripts/Invoke-FsiSmokeTest.ps1" -All
```

`<skill-dir>` is this skill's directory (where this `SKILL.md` lives).

## How the agent runs it (deterministic sequence)

Real-EMR calls plus polling take ~1–3 minutes for a handful of requests. Follow these steps exactly:

1. **Run** `scripts/Invoke-FsiSmokeTest.ps1` as a **background** command (add `-Set`/`-All`/`-StubsPath` as the user asked; otherwise defaults).
2. **Wait** for it to finish. Do not poll it — let it complete.
3. **Read the results JSON** — the script prints `Results JSON: <path>` on its last line (default `{temp}\fsi-smoke-test-result.json`). Parse that file; do **not** scrape the console table.
4. **Report** from the JSON: state `summary.passed`/`summary.total`, and for any failed result name its `failureKind` and one-line `message`. Distinguish real regressions from `stale-data` (rotated sandbox identifiers, not a code break).

The terminal shows a clean table for the human; the JSON is the agent's source of truth.

## What passes

A request passes only when: orchestration `status == Completed` **AND** data is non-empty **AND** the result message contains no failure text. An orchestration can report `Completed` while carrying an error and empty data (e.g. `GetPatientModelAsync NotFound`) — that is a **fail**.

`failureKind` values in the JSON:

| Kind | Meaning |
|---|---|
| `null` | Passed. |
| `stale-data` | Completed but the sandbox identifier no longer resolves (data rotated). Not a code regression. |
| `empty-data` | Completed with no data and no clear "not found" reason. |
| `orchestration-error` | Orchestration Failed/Terminated, or Completed with error text. |
| `timeout` | Did not finish within the poll timeout. |
| `auth-401` | Submit rejected as unauthorized (check the OID / environment). |
| `submit-fail` | Submit rejected for another reason. |

## The facts that make this work (learned the hard way)

The script encodes these; do not deviate without checking the code.

| Thing | Value | Why |
|---|---|---|
| Submit endpoint | `POST {base}/v1/patients` | **Non-mock.** `/v1/mock/patients` routes to WireMock, whose stubs are stale — mock requests complete with empty data. |
| Retrieve endpoint | `GET {base}/v1/orchestration/{jobId}` | Async — submit returns `202` + jobId; data arrives only after the orchestration completes. |
| Base URL | `http://localhost:8076/api` | FSI Interface (Azure Functions, route prefix `/api`). |
| Auth header | `X-MS-CLIENT-PRINCIPAL-ID: local-dev` | Container runs `ASPNETCORE_ENVIRONMENT=Development` → registry loads from `consumer-client-mappings.Development.json`, whose only consumer OID is the literal `local-dev`. Other OIDs → `401`. |
| Scope | Epic Sandbox (emrId 0, org 0) + Oracle/Cerner Sandbox (emrId 2, org 0) | The only sandboxes with stub patient data; both authorized for `local-dev`. |

**Retrieval auth:** `/v1/orchestration/{jobId}` requires the **same OID** that submitted the job. The script polls with the same `local-dev` header.

## Where the request data comes from

The script parses the WireMock stubs — it does **not** hand-maintain a patient list:

- Reads `MockData/Stubs/Epic Sandbox/*.json` and `MockData/Stubs/Cerner Sandbox/*.json`.
- Takes each stub's `metadata.fsiiInput` (`medicalRecordNumber`, `contactSerialNumber`, `dateOfService`, `emrId`, `organizationId`) and `metadata.description` (patient name).
- Skips response-only variant stubs (no `fsiiInput`) and dedupes by `emrId + MRN + CSN`.

Stub identifiers can be stale against the **live** sandboxes (sandbox data rotates) — those surface as `failureKind: stale-data`, not hidden.

## Customizing

- `-Set Epic|Oracle|Both` (default `Both`)
- `-Sample <n>` — encounters per EMR in a default run (default `3`); ignored with `-All`
- `-All` — test every stub-sourced encounter for the selected set
- `-StubsPath <path>` — MockData/Stubs location (default `C:\repos\Fsi\MockData\Stubs`)
- `-BaseUrl`, `-Oid`, `-PollIntervalSeconds` (3), `-PollTimeoutSeconds` (180)
- `-ResultJsonPath <path>` — where to write the results JSON (default `{temp}\fsi-smoke-test-result.json`)
- `-PassThru` — also return the row objects (default: table + JSON only)

## Deliberately out of scope

- **The mock path** (`/v1/mock/*`) — this skill targets the real endpoint on purpose.
- **The other sandboxes** (Rochester, PeaceHealth, Northwestern, Shannon, Sheridan) — they have no stub patient data, so nothing to source a request from.
- **Patient discovery / EMR auth** — no `Patient.Search`, no direct-EMR calls, no OAuth/Key Vault. Everything runs through the FSI front door with `local-dev`.
