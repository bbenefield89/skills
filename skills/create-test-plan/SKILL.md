---
name: create-test-plan
description: Generate a QA Test Plan from the current coding session's context and append it to the bottom of the matching Jira ticket's description. Infers the ticket from the current git branch, drafts a Prereqs + numbered Steps plan, shows it for approval, then writes it non-destructively (existing description preserved; a prior Test Plan block is replaced, not duplicated). Use after a session of writing code, when the user says "create a test plan", "add a test plan to the ticket", or "/create-test-plan".
---

# Create Test Plan

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

Write the plan from the session's code context. Use this **exact** shape (a leading `---` rule, then the heading and two sections):

```md
---
# Test Plan

**Prereqs**

<Only things genuinely different from the norm. QA are professionals — do not spell out
basics like "open Postman". Omit obvious setup. If there truly are none, write a single
line such as "None beyond the usual environment.">

**Steps**

1. Concrete, ordered step
2. Next step
3. ...
```

Content rules:
- **Prereqs** — free-form, short. Only genuinely non-obvious setup ("point the client at the staging OID", "seed record X first"). No hand-holding. If nothing is unusual, say so in one line rather than padding.
- **Steps** — a numbered list of concrete actions a tester performs, in order. Each step is one verifiable action with the expected outcome where it matters. Derive them from what actually changed this session — the endpoints, flows, edge cases, and error paths the code touched — not generic boilerplate.
- Keep it a **test plan**, not a spec restatement. Steps tell QA what to *do* and what they should *see*.

## Step 4 — Show it and wait for approval

Show the full drafted Test Plan and the resolved ticket key. **Wait for explicit approval** before writing to Jira. A neutral "ok"/"thanks" is not enough — wait for a clear go ("looks good, add it", "yep write it"). Incorporate any edits the user asks for and re-show if the change is substantial.

## Step 5 — Append non-destructively (detect-and-replace)

The existing description must survive untouched; the Test Plan lands at the **bottom**. A re-run must **replace** a previous Test Plan block, not stack a second one.

1. **Read the current description.** `getJiraIssue` for the key, requesting the description. Keep the returned ADF document.
2. **Detect an existing Test Plan block.** Scan the description's ADF content for a heading node with text `Test Plan` (and the `---` rule immediately before it, if present). If found, treat that rule + heading + everything after it as the old Test Plan block.
3. **Build the new description:**
   - If an old block was found → drop it and everything after it, then append the new block (rule + `# Test Plan` heading + Prereqs + Steps) to the end.
   - If none was found → append the new block to the end of the existing content.
   - **Append at the ADF-node level** — push the new nodes onto the document's `content` array rather than round-tripping the whole existing description through markdown. This is what guarantees the existing content is not reformatted or lost.
4. **Write it back** with `editJiraIssue`, setting the `description` field to the rebuilt document.
   - Preferred: pass the rebuilt **ADF** document directly.
   - If `editJiraIssue` only accepts markdown for `description`, reconstruct the full description as markdown (existing content + the new block) and pass that — but verify in Step 6 that the existing content is intact, since markdown round-tripping can be lossy. If it proves lossy, prefer the ADF path.
5. **Verify.** Re-read the issue with `getJiraIssue` and confirm: (a) the original description content above the Test Plan is unchanged, (b) exactly one `# Test Plan` block exists, and (c) it is at the bottom.

## Step 6 — Report

State the ticket key, a link to the issue, and that the Test Plan was appended (or replaced, if a prior one existed). If verification in Step 5 flagged any drift in the existing description, say so plainly rather than claiming success.

## Hard rules

- **Never write to the ticket without explicit approval** (Step 4).
- **Existing description is preserved** — append/replace only the Test Plan block; never rewrite the rest.
- **Detect-and-replace** — a re-run leaves exactly one Test Plan block, at the bottom.
- **Never guess the ticket** when the branch yields zero or multiple keys — ask.
- **Do not invent a plan** with no session context — stop and ask instead.
- Prereqs are for the genuinely non-obvious only; QA are professionals.
