# Jira review workflow

This file records how CorroHealth teams move tickets during code review. The
FACS project uses it. DACS uses the same flow.

## Statuses

`In Development` → `PR Code Review` → `Code Review Pass` → `Ready for QA` →
`Deploy to Production` → `Done`

`Blocked` is available from every status.

## Transitions that this skill uses

| From | Transition name | To |
|---|---|---|
| In Development | Development Complete | PR Code Review |
| PR Code Review | Code review completed | Code Review Pass |
| PR Code Review | Code review unsuccessful | In Development |

Find each transition by its name with `getTransitionsForJiraIssue`. Then call
`transitionJiraIssue` with the returned ID. The IDs (81, 41, and 111 in FACS)
can change, so do not use them directly.

If the ticket has no transition with the expected name, skip the transition.
Report the ticket's current status and the transitions that Jira offered.

## Assignment rules

Jira has no reviewer field and no developer field. The assignee is the only
routing mechanism, so each step sets it:

1. **PR created.** The ticket goes to PR Code Review. Assign it to the first
   required reviewer.
2. **Reviewer votes, and other required reviewers did not vote.** The status
   stays PR Code Review for every vote. Assign the ticket to the next required
   reviewer.
3. **Last required reviewer votes, and every required vote is Approve.** Run
   `Code review completed`. Assign the ticket to the PR author.
4. **Last required reviewer votes, and any required vote is not Approve.** Run
   `Code review unsuccessful`. Assign the ticket to the PR author. Approve with
   suggestions counts as not Approve, because the author must address the
   suggestions.

The author moves the ticket from Code Review Pass to Ready for QA and assigns it
to QA. This skill does not do that step, because the author knows if the ticket
needs QA. Infrastructure tasks skip QA.

## Status guard

Make a Jira write only when the ticket is in the status that the step expects:

- `create` expects In Development, or PR Code Review for a reused PR.
- `review` expects PR Code Review.

For any other status, skip the Jira write and report the current status.
