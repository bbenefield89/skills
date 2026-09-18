---
name: review-triage
description: Walk through code-review findings one at a time — high severity first, then medium, then low, skipping info — leading each to a locked-in outcome of Fix, Do Not Fix, or Defer. Ends with a summary table. Use after /code-review has produced findings, or when the user says "triage the findings", "let's go through the review", or "walk me through the review findings".
---

# Review triage

Take the user through every finding from a code review and land each one on a **locked-in** outcome: **Fix**, **Do Not Fix**, or **Defer**. This skill never fixes code, creates tickets, or otherwise acts on a finding — locking in only records the decision for handling afterward.

## Important: required voice for this entire skill

Before your first response in this skill, and before **every** response for the rest of the triage session — recommendations, issue explanations, back-and-forth discussion, fix-approach discussion, lock-in confirmations, and the final summary table — read and apply [the asd-ste100 skill](../asd-ste100/SKILL.md) and its writing profile.

This is not a one-time setup step. Treat it the same way `/tldr` treats its own voice requirement: the rule stays in force for every single turn until the triage session ends, not just the first message.

Keep technical tokens exact — file paths, code, identifiers, finding titles/IDs, and severity labels are not reworded by STE. STE governs the prose around them.

If the asd-ste100 skill or its profile is unavailable, say so in your response. This is the only exception to following it exactly. Then apply ASD-STE100 as closely as possible from what's available.

## 1. Find the findings

In order:

1. Findings already in this conversation from a `/code-review` run earlier in the session.
2. If none: look for a saved review document for the current branch (check `docs/`, `.scratch/`, or wherever this repo's `code-review` skill writes its output).
3. If none: ask the user for a path or paste.

Group by severity — `high`, `medium`, `low` — and drop every `info` finding. Do not list, count, or mention skipped `info` findings.

## 2. Set up the tracking scratchpad

Before the first finding, create a scratch file in the OS temp directory (not the repo), e.g. `review-triage-<branch-or-timestamp>.md`. After each finding is locked in, append a line: finding id/title, severity, outcome, one-line rationale. This is working memory only, in case the session gets long enough to compact — never present it to the user as a deliverable.

## 3. Walk the findings, in order

Process **all high** findings, then **all medium**, then **all low**. Within each severity, one finding at a time:

1. **Recommend first.** Before explaining anything, state the finding's title/location and a recommended outcome (Fix / Do Not Fix / Defer) with a single concise one-line reason.
2. **Explain the issue.** Now give the fuller explanation of what's wrong and why it matters.
3. **Discuss.** Let the user ask questions, push back, or explore alternatives. Stay here as long as they want — don't rush to a fix.
4. **Agree on resolution.** Once the issue itself is understood, discuss how to fix it (or firm up the do-not-fix / defer rationale) until you both agree on an approach.
5. **Lock it in.** Record the outcome and the agreed approach/rationale to the scratchpad. State clearly that this is locked in and no action happens now — it's handled after the full pass.
6. Move to the next finding.

## 4. Final summary

After the last low finding is locked in, present a table directly in chat:

| Finding | Severity | Outcome | Rationale / Approach |
|---|---|---|---|

This table is the deliverable of the session. The scratch file is not; leave it in temp and don't offer to keep or move it.

## Notes

- Deferred findings are only recorded here — creating the actual follow-up ticket is a separate, later step (e.g. via `create-ticket`), not part of this skill.
- "Do Not Fix" is for findings that turn out to be incorrect or not a real issue — capture *why* it's not real, since that's the part worth keeping.
