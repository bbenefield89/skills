---
name: feedback-triage
description: Walk through review feedback one item at a time, leading each to a locked-in outcome of Fix, Do Not Fix, or Defer, ending with a summary table. Source is either /code-review findings (high/medium/low, skipping info) or open threads on an Azure DevOps PR. Use when the user says "triage the findings", "triage the PR", "triage the review", "walk me through the review threads/comments", or similar.
---

# Feedback triage

## Shared writing standard

Before you write user-facing prose or artifact prose, read and apply
[the shared ASD-STE100 skill](../asd-ste100/SKILL.md). Preserve this skill's required output contract. Apply it for **every** response for the whole triage session, not just the first — the same standing rule `/tldr` applies to itself.

If the shared skill or profile is unavailable, state that limit in the response.
This notice is the only exception to an exact-output rule.
Then apply ASD-STE100 as closely as possible from the available context.

Take the user through every item of review feedback and land each one on a **locked-in** outcome: **Fix**, **Do Not Fix**, or **Defer**. This skill never fixes code, replies to a thread, changes a thread's status, or creates a ticket. Locking in only records the decision for handling afterward — for both sources, equally.

## 1. Pick the source

- If the user names a PR ("triage the PR", "triage the PR threads") or gives a PR link/ID, use **PR threads** (step 2b).
- Else if `/code-review` findings are already in this conversation, or the user says "triage the findings/review", use **CR findings** (step 2a).
- Else ask which source, once.

## 2a. Gather CR findings

1. Findings already in this conversation from a `/code-review` run.
2. If none: look for a saved review document for the current branch.
3. If none: ask for a path or paste.

Group by severity — `high`, `medium`, `low` — dropping every `info` finding without mentioning it.

## 2b. Gather PR threads

1. If no PR link/ID is already known, ask for it.
2. Look at the PR directly (e.g. `az repos pr show`, the PR's web view, or whatever tool is already available in this session) and pull every **open/active** thread in full — every comment in the thread, each with its author and in chronological order, plus a link to the thread and file/line context if any. Skip threads already `Fixed`, `Closed`, or `Won't Fix`.
3. No severity tiers here — process threads in the order they appear on the PR.

Don't invent or require a special config file for this. If the session can already reach Azure DevOps (CLI login, browser, or otherwise), use that directly.

## 3. Set up the tracking scratchpad

Before the first item, create a scratch file in the OS temp directory (not the repo). After each item is locked in, append one line:

- For CR: finding/severity/outcome/rationale.
- For PR threads: thread link, opener, full comment history (author + text per comment, in order), outcome, rationale.

Working memory only, in case the session runs long enough to compact. Never present it as a deliverable.

## 4. Walk the items, one at a time

For CR: all **high**, then all **medium**, then all **low**. For PR threads: in PR order. Within that order, one item at a time:

1. **Recommend first.** State the item — for a thread, its link, who opened it, and who else commented (if anyone); for a finding, its title/location — and a recommended outcome (Fix / Do Not Fix / Defer) with one concise one-line reason.
2. **Explain the issue.** Give the fuller explanation of what's wrong and why it matters. For a thread with more than one comment, summarize the back-and-forth so far — who said what — before moving to discussion, so nothing already settled between reviewers gets re-litigated.
3. **Discuss.** Let the user ask questions or push back. Stay here as long as needed.
4. **Agree on resolution.** Discuss how to fix it (or firm up the do-not-fix / defer rationale) until you agree on an approach.
5. **Lock it in.** Record the outcome and rationale/approach to the scratchpad. State plainly that no action happens now — not a code fix, not a thread reply, not a status change — it's handled after the full pass.
6. Move to the next item.

## 5. Final summary

After the last item, present a table directly in chat.

- For CR: `| Finding | Severity | Outcome | Rationale / Approach |`
- For PR threads: `| Thread (linked) | Opened by | Also commented | Outcome | Rationale / Approach |`

This table is the deliverable. The scratch file is not — leave it in temp.

## Notes

- Nothing here posts to Azure DevOps or a ticket tracker. Deferred/fix/reply actions are a separate, later step.
- "Do Not Fix" is for feedback that turns out to be incorrect — capture *why*, since that's the part worth keeping.
