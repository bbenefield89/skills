---
name: pr-response-review
description: Report how an Azure DevOps PR owner handled each thread from the last round of review, giving every thread a status such as Fixed, Not fixed, or Self resolved, backed by the code. Use when the PR owner has responded and the PR is ready for another round of review, or when the user says "the owner responded", "check how they handled my comments", "status my PR threads", or similar.
---

# PR response review

## Shared writing standard

Before you write user-facing prose, read and apply
[the shared ASD-STE100 skill](../asd-ste100/SKILL.md). Preserve this skill's
required output contract. Apply it for **every** response for the whole session,
not just the first.

If the shared skill or profile is unavailable, state that limit in the response.
This notice is the only exception to an exact-output rule.

## What this skill does

The user reviewed an Azure DevOps PR and opened threads. The owner has now
responded and pushed changes. This skill enumerates the user's threads from that
review round and reports, per thread, how the owner handled it.

This skill is **read-only**. It never fixes code, never replies to a thread,
never changes a thread status, and never posts to Azure DevOps. The chat report
is the whole deliverable.

## 1. Identify the PR

1. Use the PR link or ID the user gave.
2. If none, infer the PR from the current branch and confirm it with the user
   before continuing.

## 2. Gather the threads

Pull every thread on the PR in full — each comment with its author, in
chronological order — plus the thread link and the file/line context.

Use whatever access this session already has: the Azure DevOps CLI
(`az repos pr show`, or `az devops invoke` against the pull-request threads
endpoint), the PR web view, or a configured MCP server. Do not invent or require
a config file for this.

Keep a thread when **the user opened it**. Drop threads opened by someone else,
and drop system/vote threads. Keep a thread even when its status is already
`Fixed`, `Closed`, or `Won't Fix` — an owner-resolved thread still needs a
verdict, and a wrongly closed one is the most useful finding in the report.

If a thread's author cannot be determined, keep it and say so in the report.

## 3. Pin the review round

Find the commit the PR was at when the user's threads were written:

1. Prefer the PR iteration the threads were made against, from the thread data.
2. Else use the last commit on the PR branch before the earliest of the user's
   thread timestamps.
3. Else ask the user for the commit or iteration.

Fetch the branch first so both commits are local.

## 4. Judge each thread

For every thread, in PR order:

1. **Read the diff** from the review-round commit to the branch head to see what
   the owner actually changed in response.
2. **Read the current code** at the thread's file and lines as it exists now, to
   confirm whether the original issue is gone. The diff alone can hide a problem
   that lives in untouched code.
3. **Read the owner's reply** for intent — what they say they did, what they
   pushed back on, and what they treated as optional.
4. Assign a status. When the diff and the code disagree with the reply, the code
   wins.

If the review-round commit cannot be pinned, judge from the current code alone
and state that limit in the report.

## 5. Statuses

Core statuses:

| Status | Meaning |
| --- | --- |
| **Fixed** | The owner addressed the issue and pushed changes that fix it. |
| **Not fixed** | The owner pushed changes, but the change is incorrect and the original issue is still present. |
| **Self resolved** | The thread told the owner it was optional and could be self resolved if deemed unnecessary, and the owner did so. |

Also available:

| Status | Meaning |
| --- | --- |
| **Partially fixed** | Some concerns in the thread are addressed, others are still open. |
| **No response** | The owner did not reply and nothing changed. The thread still waits on them. |
| **Awaiting reviewer** | The owner asked a question or pushed back. The next move belongs to the user, so no verdict yet. |

The status column is open. When a thread fits none of the above, name a new
status that describes it plainly and define it in a line under the table. Never
force a thread into a status that misstates what happened.

## 6. Report

Present one table in chat, in PR order:

`| # | Thread (linked) | File:line | Status | Evidence |`

`Evidence` is one or two sentences: what the owner said, what the code now does,
and for any status other than Fixed, what is still wrong or still needed.

Under the table, add:

- Definitions for any status invented for this run.
- A short **Still open** list of the threads that need the user to act, with the
  action for each (re-comment, reply, or resolve).
- The commits compared, so the user can check the range.

## Notes

- A thread the owner marked `Fixed` is not evidence of a fix. Judge the code.
- Quote or point to the specific line when calling a thread **Not fixed**. The
  user has to defend that verdict on the PR.
- Deciding what to do about the still-open threads is the next step and belongs
  to the user, or to `/feedback-triage` for a fresh round.
