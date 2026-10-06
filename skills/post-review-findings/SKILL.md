---
name: post-review-findings
description: Post code-review findings to an Azure DevOps PR as threads anchored on the code each finding addresses, with Low threads marked optional and self-resolvable. Use after a dry-run `/code-review` when the user says "post the findings", "post the HIGH/MEDIUM/LOW against the PR", or similar.
---

# Post review findings

## Shared writing standard

Before you write thread text, read and apply
[the shared ASD-STE100 skill](../asd-ste100/SKILL.md). Preserve this skill's
required output contract.

If the shared skill or profile is unavailable, state that limit in the response.

## What this skill does

A dry-run `/code-review` produced High, Med, and Low findings in this
conversation. This skill posts each finding to the PR as one Azure DevOps
thread, anchored on the lines it addresses. It never edits code, votes, or
changes existing threads.

## 1. Gather the findings

1. Use the findings from the latest `/code-review` run in this conversation.
2. If none, ask for a path or paste.

Post every High, Med, and Low finding unless the user narrows the set. Leave
coverage notes and verification limits out of threads.

## 2. Identify the PR and pin the commit

1. Use the PR link or ID the user gave. Else infer it from the current branch
   and confirm with the user.
2. Read the PR (`az repos pr show --id <id>`) for its organization, project,
   repository ID, and `lastMergeSourceCommit`.
3. Compare that commit with the commit the review read. If they differ, stop
   and tell the user: line anchors could land on the wrong code. Continue only
   on their instruction (re-review, or re-map each line against the PR head).

## 3. Build each thread

**Anchor:** the file path and the tightest line range from the finding's
location, on the PR's source (right) side.

- The path starts with `/` and is relative to the repository root.
- For a finding on deleted code, anchor on the left side.
- For a finding with no single location, or a file outside the PR diff, post a
  PR-level thread and name the location in the text.

**Body:**

```
**<Severity>: <short title>**

<Finding and impact.>

**Suggested fix:** <suggested fix>

<Rule / source, when the finding cites one.>
```

**Low prefix:** start every Low thread with this line, then a blank line:

> _Optional: This is a low-severity suggestion. If you deem the change
> unnecessary and make no changes, feel free to self-resolve this thread._

**Duplicates:** list the PR's existing threads first. Skip a finding when the
user already has an active thread at the same file and line about the same
issue. Report each skip.

Every finding is ready when it has an anchor (or a stated PR-level reason) and
a body.

## 4. Confirm

Show one preview table in chat, ordered High, Med, Low:

`| # | Severity | Anchor (file:lines) | Title | Action (post / PR-level / skip) |`

Show the full body of the first thread of each severity so the user can check
the format. Wait for explicit approval. Apply any edits the user asks for.

## 5. Post

For each approved thread, POST to the pull-request threads endpoint:

```bash
az devops invoke --area git --resource pullRequestThreads \
  --org <org-url> \
  --route-parameters project=<project> repositoryId=<repo-id> pullRequestId=<id> \
  --http-method POST --api-version 7.1 --in-file <body.json>
```

Write each `body.json` to the scratchpad or OS temp directory:

```json
{
  "comments": [{ "parentCommentId": 0, "content": "<body>", "commentType": 1 }],
  "status": 1,
  "threadContext": {
    "filePath": "/src/Example.cs",
    "rightFileStart": { "line": 42, "offset": 1 },
    "rightFileEnd": { "line": 48, "offset": 1 }
  }
}
```

- For a left-side anchor, use `leftFileStart` and `leftFileEnd` instead.
- For a PR-level thread, omit `threadContext`.
- Write the file as UTF-8 without a BOM. A BOM makes the request fail.

If a post fails, stop and report it. Leave the threads already posted in place.

## 6. Report

Present one table in chat:

`| # | Severity | Thread (linked) | Anchor | Result (posted / skipped / failed) |`

Posting is complete when every approved finding is posted, skipped with a
reason, or reported as failed.
