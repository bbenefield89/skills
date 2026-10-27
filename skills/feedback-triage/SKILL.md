---
name: feedback-triage
description: Walk through review feedback one item at a time, leading each to a locked-in outcome of Fix, Do Not Fix, or Defer, ending with a summary table. Source is either /code-review findings (high/medium/low, skipping info) or open threads on an Azure DevOps PR. Use when the user says "triage the findings", "triage the PR", "triage the review", "walk me through the review threads/comments", or similar.
argument-hint: "[pr [<PR link/ID> | <ticket>] | cr]"
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

Read the argument first:

- `pr <PR link or ID>`: use **PR threads** (step 2b) for that PR.
- `pr <ticket>`: the ticket is an issue key such as `FACS-123`. Use **PR threads** (step 2b). Step 2b finds the PR from the ticket.
- `pr` alone: use **PR threads** (step 2b). Step 2b finds the active PR for the current git branch.
- `cr`: use **CR findings** (step 2a), conversation only.
- No argument: pick from the user's wording, as follows.

With no argument:

- If the user names a PR ("triage the PR", "triage the PR threads") or gives a PR link/ID, use **PR threads** (step 2b).
- Else if `/code-review` findings are already in this conversation, or the user says "triage the findings/review", use **CR findings** (step 2a).
- Else ask which source, once.

## 2a. Gather CR findings

With the `cr` argument: use only the latest `/code-review` findings in this conversation. If the conversation has none, say so and stop. Do not look for a saved review document. Do not ask for a paste.

With no argument:

1. Findings already in this conversation from a `/code-review` run.
2. If none: look for a saved review document for the current branch.
3. If none: ask for a path or paste.

Group by severity — `high`, `medium`, `low` — dropping every `info` finding without mentioning it.

## 2b. Gather PR threads

1. Find the PR:
   - A PR link or ID is known: use it.
   - `pr <ticket>`: find the PR for that ticket through the project's ticket tracker (for example, the development or remote links on a Jira issue), with whatever tracker access the session has. If the tracker shows several PRs, ask the user which one. If it shows none, ask for a PR link or ID.
   - `pr` alone: find the active PR for the current git branch in Azure DevOps. If the branch has no active PR, say so and ask for a PR link or ID.
   - Otherwise: ask for a PR link or ID.
2. Look at the PR directly (e.g. `az repos pr show`, the PR's web view, or whatever tool is already available in this session) and pull every **open/active** thread in full — every comment in the thread, each with its author and in chronological order, plus a link to the thread and file/line context if any. Skip threads already `Fixed`, `Closed`, or `Won't Fix`.
3. No severity tiers here — process threads in the order they appear on the PR.

Don't invent or require a special config file for this. If the session can already reach Azure DevOps (CLI login, browser, or otherwise), use that directly.

## 2c. Classify logic-neutral items

Before the walk, sort every item from step 2a or 2b. Apply this to both sources.

An item is **logic-neutral** when its change touches only:

- test files,
- Markdown (`.md`) or other documentation files,
- code comments, or
- formatting and whitespace.

It must make no difference to runtime behavior.

- An item that mixes a logic change with a logic-neutral change is **not** logic-neutral.
- An item you are not sure about is **not** logic-neutral.
- Both get the normal walk in step 4. A wrong auto-accept skips a decision that the user wants to make.

Hold the logic-neutral items back. Step 4 does not walk them. Step 4b shows them.

## 3. Set up the tracking scratchpad

Before the first item, create a scratch file in the OS temp directory (not the repo). After each item is locked in, append one line. Add the `(auto)` marker after the outcome for an item that step 4b auto-accepts:

- For CR: finding/severity/outcome/rationale.
- For PR threads: thread link, opener, full comment history (author + text per comment, in order), outcome, rationale.

Working memory only, in case the session runs long enough to compact. Never present it as a deliverable.

## 4. Walk the items, one at a time

For CR: all **high**, then all **medium**, then all **low**. For PR threads: in PR order. Skip the logic-neutral items from step 2c. Within that order, one item at a time:

1. **Recommend first.** State the item — for a thread, its link, who opened it, and who else commented (if anyone); for a finding, its title/location — and a recommended outcome (Fix / Do Not Fix / Defer) with one concise one-line reason.
2. **Explain the issue.** Give the fuller explanation of what's wrong and why it matters. For a thread with more than one comment, summarize the back-and-forth so far — who said what — before moving to discussion, so nothing already settled between reviewers gets re-litigated.
3. **Discuss.** Let the user ask questions or push back. Stay here as long as needed.
4. **Agree on resolution.** Discuss how to fix it (or firm up the do-not-fix / defer rationale) until you agree on an approach.
5. **Lock it in.** Record the outcome and rationale/approach to the scratchpad. State plainly that no action happens now — not a code fix, not a thread reply, not a status change — it's handled after the full pass.
6. Move to the next item.

## 4b. Batch the logic-neutral items

After the last item of step 4, and before the final summary, show all logic-neutral items from step 2c as one list. Skip this step if there are none.

Each entry shows:

- the item: the finding title and location, or the thread link and opener, and
- the recommended outcome (**Fix**, **Do Not Fix**, or **Defer**) with a one-line reason.

Every item in the list locks in with your recommendation, whatever the outcome is. The list is for the user's awareness. It is not a confirmation step, so do not wait for approval.

- The user can name any item in the list to pull it out. A pulled-out item goes through the normal walk in step 4.
- Record each remaining item in the scratchpad with the `(auto)` marker, for example `Fix (auto)`.
- State plainly that no action happens now, as in step 4.

## 5. Final summary

After step 4b, present a table directly in chat. In the Outcome column, write `(auto)` after the outcome of each item that step 4b auto-accepted, for example `Fix (auto)`.

- For CR: `| Finding | Severity | Outcome | Rationale / Approach |`
- For PR threads: `| Thread (linked) | Opened by | Also commented | Outcome | Rationale / Approach |`

This table is the deliverable. The scratch file is not — leave it in temp.

## Notes

- Nothing here posts to Azure DevOps or a ticket tracker. Deferred/fix/reply actions are a separate, later step.
- "Do Not Fix" is for feedback that turns out to be incorrect — capture *why*, since that's the part worth keeping.
