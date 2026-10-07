# Jira comment mode

`/ticket-to-tasks jira [ticket-key]` drafts tasks for a Jira ticket and posts the approved tasks as one comment.
This mode uses no tracker contract. Its only write is that one comment.
The ticket's description, fields, status, and child issues stay as they are.

## Resolve the ticket

1. Use the ticket key from the invocation, if the user gave one.
2. Otherwise read the current branch with `git rev-parse --abbrev-ref HEAD` and extract the Jira keys that match `[A-Z][A-Z0-9]+-\d+`.
   Use the key when the branch has exactly one distinct key. Ask the user when it has none or more than one.
3. Read the ticket with the available Jira tools: summary, description, comments, and child issues.
   If the ticket cannot be read, report the failure and stop.

## Draft the tasks

Follow "Gather context" and "Draft tasks for review" in the skill, with these changes:

- Synthesize the specification from the specification reference as working context. Keep it out of the tracker.
  Put every decision that a worker needs into the task drafts.
- Use `Agent` or `Human` as the executor. Apply the executor rules in the task reference.
- Refer to blockers by draft task number and title.
- State the resolved ticket key in the review, and state that approval posts one comment to that ticket.
- If the ticket already has a tasks comment from this mode, state that in the review and ask whether to post a new comment.

Wait for explicit approval before posting.

## Post the comment

Reread the ticket's comments. Then post the approved drafts as one comment in this shape:

```markdown
# Tasks

| Task | What it delivers | Executor | Suggested model |
|---|---|---|---|
| <N>. <title> | <Plain-English result.> | <Agent or Human> | <Approved model suggestion, or `—`.> |

## <N>. <title>

**What to build:** <The end-to-end behavior or enabling result.>

**Context:** <The decisions, starting state, and later work needed to execute this task independently.>

**Blocked by:** <Task numbers and titles, or "None".>

**Acceptance criteria:**

- <Criterion>

**Validation:** <The behavioral seam and checks.>
```

Write one table row and one section per task in the approved work order.
Write each table result as one short sentence of plain, non-technical English.
Send the comment in the format that the Jira tool accepts, and keep the table and headings.

Read the comment back. Verify that the ticket has exactly one new comment and that every approved task appears one time, in order.
Give the user the ticket link and report the result.

If no Jira tool can post the comment, or the post fails, report that and give the comment text in the chat for the user to post.
