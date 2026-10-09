---
name: write-prompt
description: Writes an agent-ready prompt for any task from current Anthropic prompting guidance. Adds a dispatch block that tells the receiving agent to do the task inline or in subagents, with the agent type, model, and effort from suggest-model. Use when the user asks to write, create, or generate a prompt for an agent, or wants a task packaged for a subagent or another session. Outputs the prompt only and does not run it.
argument-hint: "Optional: the task, or emphasis for the prompt"
---

# Write Prompt

Write one prompt that another agent can execute. The prompt has a dispatch block and one or more task prompts.
This skill only writes the prompt. Do not do the task, and do not spawn a subagent.

Agents read the output, not humans. Do not apply ASD-STE100 to the output.

## Steps

1. Find the task. Use the arguments, the user's request, the conversation, and the referenced material.
2. Collect the context that the executing agent needs. Read the referenced files, issues, and documents.
   Record the exact paths, commands, names, and decisions. The executing agent does not see this conversation.
3. Read [the prompting reference](references/prompting.md) and [the dispatch rules](references/dispatch.md).
4. Ask the clarifying questions. Do this before you write any part of the output.
5. Select the mode, the agent type, and foreground or background with the dispatch rules.
6. Get the model and effort as the dispatch rules state. Do this in every mode.
7. Write the output in the format below. [The example](references/example.md) shows a complete Subagent run.
8. Check each task prompt against the checklist in the prompting reference. Correct each failure.

## Clarifying questions

List each gap that the material does not answer and that would change the prompt:

- The objective, or the done condition.
- The scope: what is in scope, what is out of scope, and where to stop.
- A constraint, such as a file, behavior, or system that must not change.
- A required input, such as a path, a command, an identifier, or a source.
- The output format that the user wants back.
- A dispatch choice that depends on the user, such as whether the task needs the user while it runs.

Ask about each gap. Ask independent questions together, and give a recommended answer for each question.
If the `AskUserQuestion` tool is available, use it. It accepts up to four questions in each call.
If an answer opens a new gap, ask again.

Do not invent a requirement, a path, or a command to fill a gap.
If the user tells you to continue without an answer, use your recommended answer and state it in the `**Assumed:**` line.
This step is complete when each gap has an answer from the user or an assumption that the user accepted.
If the material has no gap, continue to the next step without a question.

## Output format

Put the complete output in one code block with four backticks and the `text` language. Four backticks keep inner code blocks intact.
Add no other text, except the `**Assumed:**` line and the run section below.

For the Inline mode:

````text
<dispatch>
Do the task in <task_prompt> in this session. Do not spawn a subagent.
Reason: <one sentence from the dispatch rules>
</dispatch>

<task_prompt>
<the task prompt, in the structure from the prompting reference>
</task_prompt>
````

For the Subagent mode:

````text
<dispatch>
Spawn one subagent with the Agent tool. Give it the complete text inside <task_prompt> as its prompt.
Do not do the task in this session. Use these settings exactly:
- subagent_type: <agent type>
- model: <opus | sonnet | haiku>
- effort: <low | medium | high | xhigh | max>
- run_in_background: <true | false>
Reason: <one sentence from the dispatch rules>
Task type: <task type from suggest-model>
When the subagent returns: <what the parent does with the report>
</dispatch>

<task_prompt>
<the task prompt>
</task_prompt>
````

For the Parallel subagents mode, use the Subagent format with these changes:

- Start the dispatch with "Spawn <N> subagents with the Agent tool in one message."
- Give one settings list for each subagent. Start each list with `task_prompt id="<n>"`.
- Write one `<task_prompt id="<n>">` block for each subagent.
- In "When the subagents return", tell the parent how to combine the reports.

If you assumed a fact, add one line after the code block: `**Assumed:** <assumption>`.

For the Inline mode, end the response with the run section. Put it after the `**Assumed:**` line. The user reads it to set the session.

```markdown
**Run with**
- Claude Code: <model>, <effort> — `/model <alias>`, then `/effort <effort>`
- Codex: <model>, <effort label> — `/model`, then select <model> and <effort label>
- Better fit: <Claude Code, Codex, or Either>
```
