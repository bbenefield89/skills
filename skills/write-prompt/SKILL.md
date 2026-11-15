---
name: write-prompt
description: Writes an agent-ready prompt for any task from current Anthropic prompting guidance, and suggests the model and effort to run it with in Claude Code and in Codex from suggest-model. Use when the user asks to write, create, or generate a prompt for an agent, or wants a task packaged for a subagent or another session. Outputs the prompt only and does not run it.
argument-hint: "Optional: the task, or emphasis for the prompt"
---

# Write Prompt

Write one self-contained task prompt that another agent can execute.
This skill only writes the prompt. Do not do the task, and do not spawn a subagent.
The receiving agent runs in Claude Code or in Codex. Write each prompt so that it runs in both tools.
The receiving agent decides for itself whether to use subagents. The prompt does not plan subagents, steps, or models for it.

Agents read the output, not humans. Do not apply ASD-STE100 to the output.

## Steps

1. Find the task. Use the arguments, the user's request, the conversation, and the referenced material.
2. Collect the context that the executing agent needs. Read the referenced files, issues, and documents.
   Record the exact paths, commands, names, and decisions. The executing agent does not see this conversation.
3. Read [the prompting reference](references/prompting.md).
4. Ask the clarifying questions. Do this before you write any part of the output.
5. Get the model and effort. Invoke the `suggest-model` skill one time, with a one-sentence description of the whole task.
   Keep the Claude Code pick, the Codex pick, and the better fit for the run section. Get the set commands from the catalog of `suggest-model`.
6. Write the output in the format below. [The example](references/example.md) shows a complete response.
7. Check the task prompt against the checklist in the prompting reference. Correct each failure.

## Clarifying questions

List each gap that the material does not answer and that would change the prompt:

- The objective, or the done condition.
- The scope: what is in scope, what is out of scope, and where to stop.
- A constraint, such as a file, behavior, or system that must not change.
- A required input, such as a path, a command, an identifier, or a source.
- The output format that the user wants back.
- Whether the agent can ask the user questions while it runs, or must work alone and stop to report.

Ask about each gap. Ask independent questions together, and give a recommended answer for each question.
If the `AskUserQuestion` tool is available, use it. It accepts up to four questions in each call.
If an answer opens a new gap, ask again.

Do not invent a requirement, a path, or a command to fill a gap.
If the user tells you to continue without an answer, use your recommended answer and state it in the `**Assumed:**` line.
This step is complete when each gap has an answer from the user or an assumption that the user accepted.
If the material has no gap, continue to the next step without a question.

## Output format

Put the complete prompt in one code block with four backticks and the `text` language. Four backticks keep inner code blocks intact.
Add no other text, except the `**Assumed:**` line and the run section below.

````text
<summary>
For the user. The task is in <task_prompt>.
<what the prompt does, in one or two sentences>
</summary>

<task_prompt>
<the task prompt, in the structure from the prompting reference>
</task_prompt>
````

The summary tells the user what the pasted prompt is about when they return to the conversation later. The receiving agent reads it too.
Write the summary as a description of the task, not as an instruction. An instruction there could make the agent start the work before it reads the task prompt.

- Write the first line exactly as the template shows.
- The first sentence after it starts with a present-tense verb in the third person, such as "Migrates" or "Fixes". It is never an instruction, such as "Migrate".
- Keep the summary in agreement with the task prompt. It adds no requirement, file, or step that the task prompt does not have.

If you assumed a fact, add one line after the code block: `**Assumed:** <assumption>`.

## Run section

End each response with this section, after the `**Assumed:**` line. The user reads it to set the session before the prompt runs.

```markdown
**Run with**
- Claude Code: <model>, <effort> — `/model <alias>`, then `/effort <effort>`
- Codex: <model>, <effort label> — `/model`, then select <model> and <effort label>
- Better fit: <Claude Code, Codex, or Either>
```

If the `suggest-model` skill is not available, omit the run section and add an `**Assumed:**` line that states this.
