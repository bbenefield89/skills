# Plan format

Use this format for the Plan mode. [The dispatch rules](dispatch.md#plan-the-steps) state when to use each part of it.

````text
<dispatch>
Run the plan below. Do the steps in order. Spawn the agents of one step in one message.
Add the reports named in the Input line of a step after the task prompt of each agent in that step.
Do the work of a step in this session only when its agent form tells you to.
Reason: <one sentence from the dispatch rules>

Step <n>: <short name>
- Run only if: <condition that the parent checks in the earlier reports>
- Input: <none | the reports of steps <n> | continue the subagent from step <n>>
- Agents:
  <one agent form below for each agent in the step>
- When the step finishes: <what the parent does with the reports>

When the plan finishes: <what the parent does with the reports>
</dispatch>

<task_prompt id="<n>">
<the task prompt, in the structure from the prompting reference>
</task_prompt>
````

## Agent forms

The subagent form spawns a new subagent:

```text
- task_prompt id="<n>": Spawn one subagent. Give it the complete text inside <task_prompt id="<n>"> as its prompt. Use the settings for the tool that you run in, exactly:
  - In Claude Code, use the Agent tool:
    - subagent_type: <agent type>
    - model: <opus | sonnet | haiku>
    - effort: <low | medium | high | xhigh | max>
    - run_in_background: <true | false>
  - In Codex:
    - agent: <default | worker | explorer>
    - model: <model id>
    - reasoning effort: <low | medium | high | xhigh>
  - Task type: <task type from suggest-model>
```

The parent form lets the parent do the step when it runs on the shared model of the parent steps for its tool. [The dispatch rules](dispatch.md#parent-steps) state how to find the shared model and effort:

```text
- task_prompt id="<n>": If you run on <Claude Code model name> or <Codex model name>, do the task in <task_prompt id="<n>"> in this session. Otherwise, spawn one subagent. Give it the complete text inside <task_prompt id="<n>"> as its prompt. Use the settings for the tool that you run in, exactly:
  - In Claude Code, use the Agent tool:
    - subagent_type: <agent type>
    - model: <opus | sonnet | haiku>
    - effort: <low | medium | high | xhigh | max>
    - run_in_background: false
  - In Codex:
    - agent: <default | worker | explorer>
    - model: <model id>
    - reasoning effort: <low | medium | high | xhigh>
  - Task type: <task type from suggest-model>
```

The continue form sends the step to a subagent from an earlier step:

```text
- task_prompt id="<n>": Continue the subagent from step <n>. Send it the complete text inside <task_prompt id="<n>"> as a follow-up message. In Claude Code, use the SendMessage tool and its agent ID.
```

## Rules

- Write one `<task_prompt id="<n>">` block for each agent. Number the task prompts through the whole plan.
- Omit the "Run only if" line when the step always runs.
- For a step with 2 or more agents, tell the parent in "When the step finishes" how to combine the reports.
- For a plan with one step, omit the `Step <n>` line, the `Input` line, and the "When the step finishes" line.
- For a plan with one agent, you can write `<task_prompt>` without an id. Then omit the id in the agent form too.
- Write the same model names, the same `model` lines, and the same effort lines in every parent form of one plan. They carry the shared model and effort, not the pick of the step.
- End a plan with a parent form with the run section from [the dispatch rules](dispatch.md#plan-output).
- If the `suggest-model` skill is not available, omit the `model`, `effort`, `reasoning effort`, and `Task type` lines.
