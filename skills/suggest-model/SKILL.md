---
name: suggest-model
description: Suggests the model and reasoning effort for a task in Claude Code (Claude Pro plan) and in Codex (ChatGPT Plus plan), and names the better tool. Covers coding, code review, planning, research, writing, tool and connector workflows, and 3D modeling. Use when the user asks which model, effort, or tool to use for a task, or when another skill needs a model suggestion. Use "/suggest-model refresh" to update the catalog.
---

# Suggest Model

Suggest one model and effort for Claude Code and one for Codex. Then name the better tool.
This skill only suggests. The user changes the settings.
During a suggestion, do not search the web, change a setting, or edit a file.

## Reference files

- [The catalog](references/catalog.md) gives the current models, effort levels, commands, capabilities, and exclusions. Use only the names in the catalog.
- [The routing](references/routing.md) gives the picks for each task type and difficulty, the better-tool rules, and the escalation rules.
- [The evidence](references/evidence.md) gives the graded evidence for each rule.
- [The refresh procedure](references/refresh.md) updates the other three files.

## Steps

1. If the arguments start with `refresh`, follow the refresh procedure. Do not do the other steps.
2. Read the catalog and the routing.
3. Find the task. Use the user's description and the current conversation.
4. Select one task type and one difficulty from the routing.
   - If the task has more than one task type, select the type of the most difficult part. State the other type in the `Assumed` line.
   - If the difficulty is not clear and the answer changes the model, ask the user one question.
   - Otherwise, select the nearest difficulty and state the assumption.
5. Find the row for the task type and difficulty in the routing. Copy the Claude Code pick, the Codex pick, and the grade.
6. Apply the rules for the picks in the routing.
7. Select the better tool with the better-tool rules in the routing.
8. Select the next step for each tool with the escalation rules in the routing.
9. Reply in the output format below.

## When another skill calls this skill

- Do not ask the user a question. Select the nearest task type and difficulty.
- Give these fields. The calling skill can change the format. The field names stay the same.
  - `Task type`: <task type> · <difficulty>
  - `Claude Code`: <model>, <effort>
  - `Codex`: <model>, <effort>
  - `Better fit`: <Claude Code, Codex, or Either>
- If the catalog needs a refresh, give the note one time.

## Output format

Reply with this format. Add no other text. Omit each line that does not apply.

```markdown
**Task type:** <task type> · <difficulty>
**Assumed:** <assumption>

**Claude Code**
- Model: <model> (`<alias>`)
- Effort: <effort>
- Set it: `/model <alias>`, then `/effort <effort>`
- Needs: <setup that the task needs>
- If it falls short: <failure> → <next step>

**Codex**
- Model: <model> (`<id>`)
- Effort: <label> (`<value>`)
- Set it: `/model`, then select <model> and <label>
- One run: `codex -m <id> -c model_reasoning_effort=<value>`
- Needs: <setup that the task needs>
- If it falls short: <failure> → <next step>

**Better fit:** <Claude Code, Codex, or Either>. <reason, one sentence> (evidence: <grade>)

**Evidence for the picks:** <grade> · Catalog verified <date>
```

Add these lines only when they apply:

- Add the `Assumed` line when you assumed the task type or the difficulty.
- Add a `Needs` line when the task needs live web search, a connector, an MCP server, or a 3D tool. Copy the setup from the capabilities in the catalog.
- If the effort is the default effort of the tool, add `(default)` after the effort.
- If the current date is after the `Review by` date in the catalog, add `**Note:** The catalog is from <date>. Run /suggest-model refresh.`
- If the user names a model that is not in the catalog, add `**Note:** <model> is not in the catalog. Check /model in that tool.`

## Rules

- Suggest only the models and effort levels in the catalog. Never suggest an item from the excluded list in the catalog.
- Suggest a picker-gated item only with the words "if your picker shows it".
- Never suggest `max` or Ultra as a first pick.
- Copy the grades from the routing. Do not make a grade stronger.
- Do not state the remaining quota of the user. Tell the user to check `/usage` in Claude Code and `/status` in Codex.
- If the user asks why, read the evidence and give the evidence IDs.

## Refresh

When the user asks to refresh the catalog, follow [the refresh procedure](references/refresh.md).
