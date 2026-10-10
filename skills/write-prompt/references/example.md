# Examples

## A plan with one step

A user asks for a prompt to find every caller of a deprecated API in a large repository.
The task has one part. The search reads many files, and the parent needs only the list. So the dispatch selects Plan with one step and one agent.
`suggest-model` returns Research · Light with Haiku 5.5, medium. The subagent form uses `subagent_type: Explore`, `model: haiku`, `effort: medium`, and `run_in_background: false`.
The dispatch has no `Step` line, `Input` line, or "When the step finishes" line, because the plan has one step.
The task prompt names the API, the directories to search, and the directories to ignore.
Its output format asks for a table of file path, line, and call form. It tells the agent to run one real search check, because the model is Haiku 5.5.
The response has no run section, because the plan has no parent step. The subagent sets its own model and effort.

## A plan with three steps

A user asks for a prompt to migrate every caller of a deprecated API to its replacement. The repository has four modules.
The planning finds three parts with different picks. Each part passes the cost rule:

1. Step 1 finds the callers. Research · Light: Haiku 5.5, medium. The part is large, and its output is a compact table.
   The subagent form uses `Explore` and `run_in_background: false`, because step 2 needs the table.
2. Step 2 migrates the routine callers. Build · Standard: Sonnet 5.5, medium. The modules do not depend on each other, so the step has four agents, one for each module.
   Each subagent form uses `general-purpose` and `run_in_background: true`. The Input line names the step 1 table, and each agent gets the rows for its module.
   Each task prompt tells the agent to run the module tests, and to report each caller that it did not migrate, with the reason, under "Difficult cases". The list can be empty.
3. Step 3 migrates the difficult cases. Build · Hard: Opus 5.5, high, because verification is important.
   The line `Run only if: a step 2 report lists a difficult case` gates the step. The Input line names the "Difficult cases" lists from step 2.
   The step uses the parent form, because the step is small and its input is only the step 2 reports. If the parent runs on Opus 5.5, it does the step in its session. Otherwise it spawns a `general-purpose` subagent with `model: opus` and `effort: high`.
   It is the only parent step, so the shared model is Opus 5.5 and the shared effort is high.

No step continues a subagent, because each step needs a different model.
"When the plan finishes" tells the parent to give the user one table of the migrated callers for each module, the difficult cases and their result, and the test results.
The response ends with the run section, because step 3 is a parent step. It goes after the code block:

```markdown
**Run with**
- Claude Code: Opus 5.5, high — `/model opus`, then `/effort high`
- Applies to: step 3, which runs in this session on Opus 5.5.
```
