---
name: suggest-model
description: Suggests the model and reasoning effort for a coding task in Claude Code and in Codex, and names the better tool. Use when the user asks which model or effort to use for a task, or when another skill needs a model suggestion.
---

# Suggest Model

Suggest one model and effort for Claude Code and one for Codex. Then name the winner.
This skill only suggests. The user changes the model.

## Steps

1. Read [the model picks](references/models.md).
2. Find the task. Use the user's description and the current conversation.
   If the task is not clear, ask the user one question.
   If another skill called this skill, do not ask. Select the nearest task type and state the assumption.
3. Match the task to one task type in the picks table.
   If two task types fit, use the task type that describes the work more exactly.
   If no task type fits, use the nearest task type and state the assumption.
4. Copy the Claude Code pick, the Codex pick, and the winner from that row.
5. Reply in the output format below.

## Output format

Reply with this table and the lines below it. Add no other text.

```markdown
| Tool | Model | Effort | Set with |
|---|---|---|---|
| Claude Code | <model> | <effort> | <commands> |
| Codex | <model> | <effort> | <commands> |

**Winner:** <Claude Code, Codex, or Tie>. <reason from the picks table, one sentence>
**Task type:** <task type from the picks table>
```

Add these lines only when they apply:

- If you assumed the task type, add `**Assumed:** <assumption>`.
- If the `As of` date in the picks is more than 60 days old, add `**Note:** The picks are from <date>. Refresh them.`

## Refresh

When the user asks to refresh the picks, follow the refresh section in [the model picks](references/models.md).
