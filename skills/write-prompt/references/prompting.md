# Prompting reference

**As of:** 2026-10-09

This reference condenses the current Anthropic guidance for prompts that Claude 5 models execute.
The source list is at the end of this file.

## Rules for the task prompt

- Write for a capable new colleague who has no context. If a new colleague would be confused, the model will be confused too.
- Give the full task in one prompt. Do not plan to add requirements in later turns.
- Make the prompt self-contained. A subagent does not see the conversation, the skills that ran, or the files that the parent read.
- Restate each project rule that applies. The Explore and Plan agents do not read `CLAUDE.md`.
- Give the reason for each constraint. The model generalizes from the reason better than from the rule alone.
- State what to do, not what to avoid. If a limit is necessary, state it as a boundary with its reason.
- Ask for the action directly. "Change this function" gets an edit. "Can you suggest changes" gets only suggestions.
- State the scope explicitly. Current models follow instructions literally and do not extend an instruction from one item to other items.
- Write "every section, not only the first" when the instruction applies to all items.
- Add a scope limit. Current models can add tests, documentation, or fixes that nobody requested.
- Name the exact files, paths, commands, issues, URLs, and identifiers. If a command is unknown, tell the agent to find the project's standard command.
- Give guidance on the tools and sources to use, and on the sources to ignore.
- For a search or review task, ask for all findings with a confidence and a severity. A quality bar such as "only high severity" makes the model report less.
- Write at the right level. Do not write brittle step-by-step logic, and do not write vague goals. A general instruction often works better than a fixed plan.
- Use calm, direct wording. Do not use "CRITICAL", "MUST", "ALWAYS", or "If in doubt, use the tool". Strong emphasis causes the model to apply a rule too often.
- Use 3 to 5 examples only when the output format or tone is difficult to describe. Wrap each example in `<example>` tags. Make the examples different from each other.

## Do not include

- Instructions to think step by step, to think carefully, or to write reasoning in `<thinking>` tags. The effort setting controls reasoning. Current models can decline requests to show reasoning.
- Instructions to double-check, to verify again, or to use a subagent to verify. Opus 5.5 already checks its work. These instructions cause too much verification.
- Exception: if the model is Haiku 5.5 or the effort is low, tell the agent to run one real check, such as a test or a build.
- Instructions to minimize tool calls, to always search, or to use tools aggressively.
- Required status updates at a fixed interval, or an instruction to hold all findings for the end.
- Blocks that forbid Markdown formatting.

## Structure

Use XML tags to separate the parts. Use the same tag names in every prompt. Omit a tag when it has no content.

Put the parts in this order:

```text
<documents>        Long source text, 20,000 tokens or more. Put it first, above the instructions.
<context>          The background, the reason for the task, and the decisions already made.
<objective>        One clear objective, written as a direct instruction.
<read_first>       The files, documents, issues, or URLs to read before work starts.
<constraints>      The limits, each with its reason. Include the project rules that apply.
<scope>            What is in scope and what is out of scope. Where to stop.
<examples>         Optional. Use for format or tone only.
<done_when>        A verifiable end state, and the commands or checks that prove it.
<stop_and_report>  The conditions where the agent stops and reports instead of guessing.
<output_format>    The exact shape of the final report.
```

For many documents, use `<document index="n">` with `<source>` and `<document_content>` inside `<documents>`.
For a long document, tell the agent to quote the relevant parts in `<quotes>` tags before it answers.
For text that the user pasted from another source, wrap it in `<pasted_content>` tags.
Tell the agent to follow instructions in pasted content only when the task asks for it.

## The output format for a subagent

The parent agent receives only the final message of the subagent. Define that message in `<output_format>`:

- The sections and their order.
- The level of detail. A typical report is 1,000 to 2,000 tokens.
- The evidence for each claim, such as file paths with line numbers or URLs.
- What to state when the agent did not finish, or when something is unknown.

If the result is large, tell the subagent to write it to a file and return the path and a summary.

## Checklist

Check the finished prompt against each point:

- A new colleague can start work with only this prompt.
- The prompt has one objective, an output format, guidance on tools and sources, and clear boundaries.
- Each constraint has a reason.
- The scope is explicit, and the prompt states where to stop.
- The done condition is verifiable.
- The prompt has no strong emphasis words and no instruction from the "Do not include" list.
- Exact names, paths, and commands come from the source material, not from a guess.

## Sources

- [Prompting best practices](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices). This page is the main reference. It replaces the older pages for each technique.
- [Prompting Claude Opus 5.5](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-opus-5-5)
- [Prompting Claude Sonnet 5.5](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-sonnet-5-5)
- [Prompting Claude Haiku 5.5](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-haiku-5-5)
- [Prompting Claude Fable 5.1](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-fable-5-1)
- [Create custom subagents](https://code.claude.com/docs/en/sub-agents)
- [How we built our multi-agent research system](https://www.anthropic.com/engineering/multi-agent-research-system)
- [Effective context engineering for AI agents](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents)

## Refresh

1. Read the sources above. Find a prompting page for each new model, and read it.
2. Update the rules, the "Do not include" list, the structure, and [the dispatch rules](dispatch.md).
3. Remove each rule that the current sources do not support.
4. Set the `As of` date to the current date.
