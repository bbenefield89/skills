---
name: create-test-plan
description: Generate a QA Test Plan from the current coding session's context and append it to the bottom of the matching Jira ticket's description. Infers the ticket from the current git branch, drafts a Prereqs + numbered Steps plan with every request, payload, and query as a ready-to-copy code block, shows it for approval, then writes it non-destructively (existing description preserved; a prior Test Plan block is replaced, not duplicated). Use after a session of writing code, when the user says "create a test plan", "add a test plan to the ticket", or "/create-test-plan".
---

# Create Test Plan

## Shared writing standard

Before you write user-facing prose or artifact prose, read and apply
[the shared ASD-STE100 skill](../asd-ste100/SKILL.md). Preserve this skill's required output contract.

If the shared skill or profile is unavailable, state that limit in the response.
This notice is the only exception to an exact-output rule.
Then apply ASD-STE100 as closely as possible from the available context.

Turn the work just done in this session into a QA Test Plan and append it to the **end of the Jira ticket's description**. This runs at the tail of a coding session — the agent already has the context of what changed and what is risky. The skill's job is to shape that context into the fixed Test Plan format and write it to Jira safely.

Invocation: `/create-test-plan [ticket-key]`
- `ticket-key` — optional. Normally inferred from the current git branch (see Step 2).

## Step 0 — Resolve the Jira `cloudId`

The Atlassian MCP calls need a `cloudId`.

1. **Reuse if available.** Read `%USERPROFILE%\.claude\tempo\config.json` (written by `log-hours`). If it exists and has a `cloudId`, use it.
2. **Otherwise resolve it.** Call `getAccessibleAtlassianResources` and take the CorroHealth site's `id`. If more than one resource is returned and the right one is ambiguous, ask the user which site.

Do not re-prompt for a `cloudId` that is already discoverable.

## Step 1 — Confirm there is context to draw on

This skill only makes sense after code has been written or reviewed in the session. If the session has no such context (fresh session, nothing changed), **stop and say so** — do not invent a plan from nothing. Ask the user to describe what should be tested, or to run this after the implementation work.

## Step 2 — Resolve the ticket key

1. If a key was passed as an argument, use it.
2. Otherwise read the current branch: `git rev-parse --abbrev-ref HEAD`, and extract Jira keys matching `[A-Z]+-\d+`.
   - **Exactly one** distinct key → use it.
   - **Zero, or more than one** distinct key → **ask** the user which ticket. Never guess.
3. Validate the key with `getJiraIssue` before drafting. If it 404s or is not accessible, stop and report — do not proceed to write.

## Step 3 — Draft the Test Plan

Write the plan from the session's code context. Use this **exact** shape (a leading `---` rule, then the heading and two sections). Note how each step carries its data as labeled, ready-to-copy code blocks — a tester should never have to retype or assemble anything:

````md
---
# Test Plan

**Prereqs**

<Only things genuinely different from the norm. QA are professionals — do not spell out
basics like "open Postman". Omit obvious setup. If there truly are none, write a single
line such as "None beyond the usual environment.">

**Steps**

1. Submit the Epic retrieval request.

   Endpoint:

   ```http
   POST http://localhost:8080/v1/patients
   ```

   Body:

   ```json
   {
     "oid": "1.2.840.114350.1.13.297.3.7.1.1",
     "vendor": "EPIC",
     "patient": {
       "mrn": "E1000234",
       "firstName": "Marion",
       "lastName": "Hale",
       "dateOfBirth": "1961-04-17"
     }
   }
   ```

   Expect `202` with a `jobId`.
2. Poll the job until it finishes.

   Endpoint:

   ```http
   GET http://localhost:8080/v1/orchestration/{jobId}
   ```

   Confirm `status` is `COMPLETED`, `patient.demographics` is non-empty, and `errors` is `[]`.
3. Verify the job persisted.

   Query:

   ```sql
   SELECT job_id, vendor, status, error_count
   FROM orchestration_job
   WHERE oid = '1.2.840.114350.1.13.297.3.7.1.1'
   ORDER BY created_at DESC
   LIMIT 5;
   ```

   Expect one row, `COMPLETED`, `error_count = 0`.
````

Content rules:
- **Prereqs** — free-form, short. Only genuinely non-obvious setup ("point the client at the staging OID", "seed record X first"). No hand-holding. If nothing is unusual, say so in one line rather than padding.
- **Steps** — a numbered list of concrete actions a tester performs, in order. Each step is one verifiable action with the expected outcome where it matters. Derive them from what actually changed this session — the endpoints, flows, edge cases, and error paths the code touched — not generic boilerplate.
- Keep it a **test plan**, not a spec restatement. Steps tell QA what to *do* and what they should *see*.

### Copyable artifacts

Testing should be paste-and-run. Anything the tester has to move out of the plan and into another tool is a **copyable artifact** and gets its own code block.

- **Split on transfer, not length.** If the tester must move it into another tool, it gets a code block — however short. That includes a bare endpoint URL, a single OID, one header value, a connection string. If the tester only *reads* it to compare against what they observe (`202`, `COMPLETED`, a field name like `patient.demographics`), leave it as inline backticks.
- **One block per artifact.** A step needing an endpoint and a body has two blocks, not one merged `curl`. Blocks sit inline, directly under the step that uses them — never collected into a separate section at the bottom.
- **Label every block** with a short lead-in line above it — `Endpoint:`, `Body:`, `Query:`, `Header:`, `Response:` — including when a step has only one.
- **Never make QA assemble a request.** A payload without its destination is incomplete. Always include the method and full URL as its own block alongside the body.
- **Tag the language** on every block (`json`, `sql`, `http`, `bash`, `xml`) so Jira syntax-highlights it and renders the copy button.
- **Pretty-print structured data.** Multi-line, indented JSON/XML — not minified, not wrapped in prose.
- **Real values from this session.** Use the actual OIDs, ids, MRNs, and payloads the session exercised, so the artifact works on first paste. The session has intimate knowledge of what correctly drives this code — spend it here rather than emitting `<REPLACE_ME>` placeholders.
- **Credentials are the one exception** — tokens, API keys, passwords, and connection secrets are placeholders, never pasted into a ticket description. Name the substitution in Prereqs.

## Step 4 — Show it and wait for approval

Show the full drafted Test Plan and the resolved ticket key. **Wait for explicit approval** before writing to Jira. A neutral "ok"/"thanks" is not enough — wait for a clear go ("looks good, add it", "yep write it"). Incorporate any edits the user asks for and re-show if the change is substantial.

**Flag unverified artifacts here, not in the ticket.** If any request, payload, or query in the draft was *constructed* from reading code rather than actually executed during the session, say so alongside the draft — name which ones. The user can then accept it, correct it, or have the agent run it first. The ticket itself ships without hedging language either way.

## Step 5 — Append non-destructively (detect-and-replace)

The existing description must survive untouched; the Test Plan lands at the **bottom**. A re-run must **replace** a previous Test Plan block, not stack a second one.

1. **Read the current description.** `getJiraIssue` for the key, requesting the description. Keep the returned ADF document.
2. **Detect an existing Test Plan block.** Scan the description's ADF content for a heading node with text `Test Plan` (and the `---` rule immediately before it, if present). If found, treat that rule + heading + everything after it as the old Test Plan block.
3. **Build the new description:**
   - If an old block was found → drop it and everything after it, then append the new block (rule + `# Test Plan` heading + Prereqs + Steps) to the end.
   - If none was found → append the new block to the end of the existing content.
   - **Append at the ADF-node level** — push the new nodes onto the document's `content` array rather than round-tripping the whole existing description through markdown. This is what guarantees the existing content is not reformatted or lost.
4. **Emit every copyable artifact as a real ADF `codeBlock` node.** This is the step where artifacts get flattened into paragraph text and stop being copyable. On the ADF path, each block is:

   ```json
   {
     "type": "codeBlock",
     "attrs": { "language": "json" },
     "content": [ { "type": "text", "text": "{\n  \"oid\": \"1.2.840...\"\n}" } ]
   }
   ```

   - `attrs.language` is **required** — it drives highlighting and the copy button.
   - The payload lives in a single `text` node carrying real newlines. Do not split it across paragraphs, and do not use `marks: [{ "type": "code" }]` — that is inline code, not a copyable block.
   - A step's `codeBlock` nodes nest inside that step's `listItem`, after its paragraph, so each artifact stays with its step.
   - On the markdown fallback path (see below), the equivalent is a triple-fenced block with the language tag.
5. **Write it back** with `editJiraIssue`, setting the `description` field to the rebuilt document.
   - Preferred: pass the rebuilt **ADF** document directly.
   - If `editJiraIssue` only accepts markdown for `description`, reconstruct the full description as markdown (existing content + the new block) and pass that — but verify in Step 6 that the existing content is intact, since markdown round-tripping can be lossy. If it proves lossy, prefer the ADF path.
6. **Verify.** Re-read the issue with `getJiraIssue` and confirm:
   - (a) the original description content above the Test Plan is unchanged,
   - (b) exactly one `# Test Plan` block exists,
   - (c) it is at the bottom,
   - (d) **every copyable artifact came back as a `codeBlock` node with `attrs.language` set** — not as paragraph text, not as inline code.

   If (d) fails, **report it; do not silently re-write.** A second write to an already-approved description needs the user's go-ahead, and a broken ADF shape will usually reproduce itself on retry.

## Step 6 — Report

State the ticket key, a link to the issue, and that the Test Plan was appended (or replaced, if a prior one existed). If verification in Step 5 flagged any drift in the existing description, or any artifact that failed to render as a code block, say so plainly rather than claiming success.

## Hard rules

- **Never write to the ticket without explicit approval** (Step 4).
- **Existing description is preserved** — append/replace only the Test Plan block; never rewrite the rest.
- **Detect-and-replace** — a re-run leaves exactly one Test Plan block, at the bottom.
- **Nothing a tester must transfer is left uncopyable** — every endpoint, payload, query, and id lands in a labeled, language-tagged `codeBlock`. Never make QA retype, reformat, or assemble a request.
- **Credentials are never pasted** — tokens, keys, and passwords are placeholders named in Prereqs.
- **Never guess the ticket** when the branch yields zero or multiple keys — ask.
- **Do not invent a plan** with no session context — stop and ask instead.
- Prereqs are for the genuinely non-obvious only; QA are professionals.
