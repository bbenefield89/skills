---
name: log-hours
description: Log a day's working hours to Tempo by deducing per-ticket time from all available sources (Jira activity, git, Azure DevOps, GitHub, Outlook calendar, Steady), merging in any time the user supplies, showing a table for approval, then posting worklogs — each tagged with its required Tempo Project — capped at 8h/day. Use when the user says "log my hours", "update Tempo", "book my time for <date>", "fill in my timesheet", or anything that maps to recording worklog time for a day.
---

# Log hours to Tempo

Deduce how a day was spent, show the user a table, and — only after explicit approval — post the time as Jira worklogs (which Tempo syncs from). The daily total (already-logged + newly-posted) must **never exceed 8 hours**.

Invocation: `/log-hours [date] [freeform time hints]`
- `date` — optional, natural language ok ("today", "yesterday", "July 2"). Defaults to **today**.
- freeform hints — optional, e.g. `1h on 738, spent the morning in meetings`. **These are authoritative** (see Step 4).

## Step 0 — Load (or create) config

Config is **user-scoped**: `%USERPROFILE%\.claude\tempo\config.json` (Windows) / `~/.claude/tempo/config.json`. It persists across every repo.

```json
{
  "version": 1,
  "cloudId": "<jira-cloud-id>",
  "accountId": "<your-atlassian-account-id>",
  "workday_hours": 8,
  "overhead_ticket": "CCINT-6",
  "rounding_minutes": 15,
  "timezone": "America/New_York",
  "sources": {
    "jira": true, "git": true, "azure_devops": true,
    "github": true, "calendar": true, "steady": true
  }
}
```

- **If it exists and parses**, use it.
- **If missing**, run first-time setup: ask for `cloudId`, `accountId`, `overhead_ticket`, `workday_hours` (default 8), `rounding_minutes` (default 15), `timezone`, and which `sources` to mine. Write the file (create the dir) and tell the user where it lives.
- **Shared integration details** (Azure DevOps org/project/tenant, GitHub handle) are **read from `~/.claude/steady-checkin/config.json`** when present — do not re-ask. If that file is absent and `azure_devops`/`github` are enabled, prompt for the missing values and store them under a `steady_checkin_fallback` key here.

**Tempo REST token (required for the Tempo Project column).** Setting `_Project_` needs Tempo's own REST API (Jira-core worklogs can't write it). Read the token from the `TEMPO_API_TOKEN` env var **first** (preferred — keeps the secret out of files); fall back to a `tempo_api_token` key in this config only if the env var is absent. Base URL `https://api.tempo.io/4`. If neither is set when a project needs writing, ask the user to mint one (Jira → **Tempo → Settings → API integration → New Token**, scopes: View/Manage worklogs + View accounts) and set it as `TEMPO_API_TOKEN`. Never echo the token back; if the user pastes it in chat, remind them to rotate it afterward.

Reconfigure on demand when the user says "reconfigure log-hours".

## Step 1 — Resolve the date and parse time hints

1. Resolve the target date to `YYYY-MM-DD` in the config `timezone`.
2. Parse any time hints from the args into `(ticket, duration)` pairs and/or meeting time. Normalise ticket references ("738" → `FACS-738`, "ccint6"/"ccN6" → the `overhead_ticket`). These pairs are **locked** and flow through unchanged.

## Step 2 — Auth-probe enabled sources

For each enabled source, probe before polling (same discipline as `steady-checkin`). Run probes in one parallel batch:

| Source | Probe | Fix if it fails |
|---|---|---|
| `github` | `gh auth status` | `gh auth login` |
| `azure_devops` | `az account show --query tenantId -o tsv` (must match the tenant in steady-checkin config) | `az login --tenant <tenant>` |
| MCP (Jira, calendar, Steady) | cheapest read (`atlassianUserInfo`, `get_me`) | `/mcp` → Authenticate |
| **Tempo REST token** (needed to set `_Project_`) | **First check the token exists** — read `TEMPO_API_TOKEN` env var, else the `tempo_api_token` config key. If found, validate it with a cheap call (`GET https://api.tempo.io/4/work-attributes`). | **If the token is missing, query the user for it** before going further: ask them to mint one (Jira → **Tempo → Settings → API integration → New Token**, scopes: View/Manage worklogs + View accounts) and set it as `TEMPO_API_TOKEN` (preferred, e.g. `setx TEMPO_API_TOKEN "<token>"` then restart the session) or paste it to store under `tempo_api_token`. If pasted in chat, remind them to rotate it. If the token exists but the validation call returns 401/403, treat it as expired/revoked and re-prompt the same way. |

Collect all failures into one message and halt until fixed — do not poll a half-authenticated set and produce a misleading table. Exception: the user explicitly says "skip <source> today". The Tempo token is only skippable if the user opts out of the Tempo Project column for this run — otherwise its absence halts the run just like any other failed probe, because a blank `_Project_` is a miscategorised worklog.

## Step 3 — Read the already-logged baseline

Read existing worklogs for the date so newly-added time only fills the *unlogged* gap and the 8h ceiling counts everything.

- Query: `worklogAuthor = currentUser() AND worklogDate = "<date>"`, then read each issue's worklogs for entries on that date.
- ⚠️ **Read-back caveat — surface this every run.** Worklogs booked *through Tempo* are authored by *"Timesheets by Tempo - Jira Time Tracking"* (app account `557058:295406f3-a1fc-4733-b906-dd15d021bd79`), **not** the user — so `worklogAuthor = currentUser()` and email filters miss them. Treat the baseline as **best-effort**: report what was found, and explicitly note that Tempo-entered time may exist that the API did not return. Never claim the baseline is exact.
- ⚠️ **Overhead-ticket pre-check (mandatory).** Explicitly check whether the `overhead_ticket` (e.g. `CCINT-6`) already has a worklog on the target date **before** proposing any meeting time. Signal: if the overhead ticket appears in the `worklogDate = "<date>"` match above, an entry already exists. Note that high-volume recurring tickets like `CCINT-6` return only a truncated slice of their worklog history in the `worklog` field, so the *amount* may be invisible even when the *existence* is confirmed — do **not** assume it's absent just because you can't read its minutes. When an entry already exists, default to **treating meeting time as already logged** and do not add more; only add/adjust meeting time if the user explicitly directs it, and warn them a duplicate may result (see Step 8 — you cannot delete it afterward).

## Step 4 — Poll sources in parallel

One parallel batch, skipping any disabled source. Capture only `ticket / signal / timestamp` — discard bodies.

- **Jira** *(primary signal)* — issues the user touched that day: their worklogs, status transitions, comments, field edits. JQL `assignee = currentUser() AND updated >= "<date>" AND updated < "<date+1>"`, plus the worklog query from Step 3.
- **Git** — commits authored by the user that day in the **current repo**: `git log --author="<name-or-email>" --since="<date> 00:00" --until="<date> 23:59" --pretty=%s`. Map commit subjects to ticket keys.
- **Azure DevOps** — PRs the user created/updated/reviewed that day. `@me` does **not** resolve in `az repos pr list` — use the email: `az repos pr list --creator <email> --status active ...` and `--reviewer <email>`.
- **GitHub** — `gh search prs --author @me --state open` and `--review-requested @me`; commits via git (above).
- **Outlook calendar** — `outlook_calendar_search` for the day; meeting durations aggregate to the `overhead_ticket`. Drop lunch/focus/decompress auto-blocks.
- **Steady** — `get_check_in_form` for the date as a cross-reference for which tickets were in play (not a time source on its own).

## Step 5 — Build the allocation

1. **Meetings** → `overhead_ticket` at their real calendar duration — **but only if the Step 3 overhead-ticket pre-check found no existing worklog for the day.** If one already exists, treat the meeting as already logged and add nothing; surface it in the table as a pre-existing entry, not a new one. Add meeting time over an existing entry only on explicit user instruction, with a duplicate warning.
2. **Dev / review** → estimate per ticket from signal density (commits, PR activity, transitions, comments). Each row carries a **one-line rationale** naming its evidence.
3. **Merge user hints** (Step 1) — authoritative. They override any deduced value for the same ticket; never silently discard or reduce them.
4. **Subtract the Step 3 baseline** so only unlogged work is added.
5. **Round** each entry to `rounding_minutes`.
6. This is **"log real time, capped at 8h"** — do **not** pad the day to reach 8h. A light day stays under 8h. 8h is a ceiling, not a target.
7. **Suggest a Tempo Project (`_Project_`) for every row.** The project is a **required** Tempo work attribute; a worklog with a blank `_Project_` is miscategorised (this is the gap that Jira-core posting silently leaves). Fetch the live picklist once — `GET https://api.tempo.io/4/work-attributes`, read the `_Project_` entry's `names` map (label ← key) — then map each row to its best-fit project from the ticket subject / meeting topic. Meetings map **per meeting** by topic; a meeting that spans everything (e.g. backlog refinement) → the internal/overhead project. When a single overhead entry's meetings map to different projects, plan to **split it into one worklog per meeting** at post time. These are suggestions — never guess silently at financial categorisation; the user confirms or amends the mapping before posting.

## Step 6 — Show the table (always, before posting)

Use **exactly** this format — three columns, one **Total** row, and **no worklog-ID column** (worklog IDs don't exist until after posting):

```
| Ticket / Meeting               | Hrs   | Tempo Project              |
|--------------------------------|-------|----------------------------|
| FACS-746 — Oracle CCDA data    | 1.5   | Oracle API Chart Creation  |
| FACS-723 — Config API schema   | 1.0   | IGNiTE Implementations App |
| CCINT-6 · Regroup FHIR Wb      | 1.0   | IGNiTE FHIR Writeback      |
| CCINT-6 · Backlog Refinement   | 1.0   | Internal                   |
| **Total**                      | **8** |                            |
```

Column rules:
- **Ticket / Meeting** — the ticket key **plus a short title**; TL;DR the title if it's long (e.g. `FACS-746 — Oracle CCDA data`, not the full Jira summary). For meetings, use `<overhead_ticket> · <meeting name>` (one row **per meeting** — see Step 5.7).
- **Hrs** — decimal hours (`1.5`, `0.5`), matching the rounded allocation.
- **Tempo Project** — the **suggested** project label for that row (from Step 5.7). These are best-guess suggestions; the user confirms or amends before anything is posted.

Below the table, list a one-line **rationale per row** (the Step 5 evidence — commits, transitions, meeting topic), then state: what was already logged (with the read-back caveat), anything **not** counted and why, and that **nothing is posted yet**.

## Step 7 — Enforce the 8h ceiling

If `baseline + new_total > workday_hours`, **stop and ask** which rows to trim — show the over-cap table and let the user decide. **Never auto-adjust.** Re-show the table after their choice.

## Step 8 — Post (only on explicit approval)

A neutral "ok"/"thanks" is not approval — wait for "post it" / "looks good, send it". Then, per ticket, call `addWorklogToJiraIssue`:
- `cloudId` — from config
- `issueIdOrKey` — the ticket key
- `timeSpent` — Jira format: `"1h"`, `"30m"`, `"1h 30m"`
- `started` — ISO-8601 on the target date at a safe local time with the config timezone offset, e.g. `2026-07-02T09:00:00.000-0400`, so the entry lands on the correct calendar day
- `commentBody` — auto-generated one-liner from that ticket's signals (offer to let the user edit before posting)

**Then set the Tempo Project on every posted worklog** — the Jira-core `addWorklogToJiraIssue` call above leaves `_Project_` **blank**, which is exactly the miscategorisation this column exists to prevent. For each row, using the confirmed mapping from Step 5.7:
1. Find the synced Tempo worklog: `GET https://api.tempo.io/4/worklogs?from=<date>&to=<date>` and match on issue ID + time.
2. Set the project: `PUT https://api.tempo.io/4/worklogs/{tempoWorklogId}`, echoing the worklog's existing `authorAccountId`, `description`, `startDate`, `startTime`, `timeSpentSeconds` (+ `billableSeconds`) and adding `"attributes": [{ "key": "_Project_", "value": "<project key>" }]`. (PUT replaces the worklog — always GET-then-PUT so nothing drifts.)
3. **Split-project meetings:** when one overhead (`CCINT-6`) entry covers meetings in different projects, shrink the original via PUT to the first meeting's hours/project, then `POST https://api.tempo.io/4/worklogs` (with `issueId`, the same fields, and the `_Project_` attribute) for each remaining meeting.
4. **Verify:** re-`GET` the day's worklogs and confirm **every** row shows a non-blank `_Project_` and the total still equals the approved hours, then report.

After posting, report each worklog's ticket / hours / Tempo Project and the final day tally (the Step 6 table shape, now filled in). **Tempo is a hard-to-reverse system of record — confirm before writing, every time.**

⚠️ **Posts are final — there is no delete.** The Atlassian MCP only exposes *add/update* (`addWorklogToJiraIssue`); it cannot delete a worklog, and Jira rejects a zero-time update. You **can** fix a wrong *amount* by re-calling with the `worklogId` and a new `timeSpent`, but a worklog created on the wrong ticket can only be removed by the user by hand (Jira issue → Work log tab, or the Tempo timesheet). Because of this, lean on the Step 3 overhead pre-check rather than posting speculative meeting time you'd need to undo.

## Hard rules

- Daily total (baseline + new) **never exceeds `workday_hours`** (default 8).
- **Never post without explicit approval.**
- **User-supplied time is authoritative** — never silently overridden or trimmed without asking.
- Meetings / non-ticket time → `overhead_ticket` (`CCINT-6`) — **only after the Step 3 pre-check confirms no meeting worklog already exists for the day.** Never blindly add meeting time; a duplicate cannot be deleted via the tools.
- Always show the table first (the Step 6 three-column format: **Ticket / Meeting · Hrs · Tempo Project**); always surface the read-back caveat.
- **Every posted worklog must end with a non-blank `_Project_`.** Suggest it in the draft, confirm the mapping with the user, set it via the Tempo REST API on post, and verify no row is left blank. Never guess financial categorisation silently.
- "Log real time, cap at 8h" — do not pad to reach 8h.
- Round every entry to `rounding_minutes`.
