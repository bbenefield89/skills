# Model picks

**As of:** 2026-10-06

## Picks table

The task types are in order from the lightest to the heaviest.

| Task type | Examples | Claude Code | Codex | Winner | Reason |
|---|---|---|---|---|---|
| Mechanical edit | Rename, reformat, boilerplate, a one-line fix | Sonnet 5.5, low | GPT-6.1 Sol, low | Tie | The two picks do this work correctly and quickly. |
| Bulk scan | Search many files, extract data, classify items | Sonnet 5.5, low | GPT-6 Luna, high | Tie | No measurement separates the two picks for this work. |
| Scoped change | A feature or a bug fix in a few files, clear requirements | Opus 5.5, medium | GPT-6.1 Sol, medium | Tie | No measurement compares the two picks at these efforts. |
| Front-end work | Layout, components, visual polish | Sonnet 5.5, high | GPT-6.1 Sol, medium | Tie | No benchmark compares the tools for this work. |
| Code review | Review a diff, a branch, or a module | Opus 5.5, high | GPT-6.1 Sol, xhigh | Tie | No benchmark compares the tools for this work. |
| Design decision | Architecture, a plan, unclear requirements | Opus 5.5, high | GPT-6.1 Sol, xhigh | Tie | No benchmark compares the tools for this work. |
| Code investigation | Explain a codebase, trace behavior, answer questions about a repository | Opus 5.5, xhigh | GPT-6.1 Sol, xhigh | Claude Code | Claude Code scores approximately 5 points higher on repository questions. One source. |
| Hard debugging | Root cause search, build failures, environment or terminal problems | Opus 5.5, xhigh | GPT-6.1 Sol, xhigh | Claude Code | Claude Code scores 6 to 9 points higher on terminal tasks in two independent sources. |
| Long repository change | A refactor, a migration, or a feature in many files, with little supervision | Opus 5.5, xhigh | GPT-6.1 Sol, xhigh | Codex | The scores are equal, and Codex completes each task in approximately a quarter of the time. |

## Commands

| Tool | Model | Effort |
|---|---|---|
| Claude Code | `/model opus`, `/model sonnet` | `/effort low`, `/effort medium`, `/effort high`, `/effort xhigh`, `/effort max` |
| Codex | `/model`, then select the model | In the same `/model` picker, select Light (low), Medium, High, or Extra High (xhigh) |

## Rules for the picks

- Suggest only models that the subscription includes. Claude Fable 5.1 can bill to usage credits, so the table excludes it.
- The table excludes GPT-6 Astra. Astra shows no measured coding gain over GPT-6.1 Sol in Codex.
- The table excludes Claude Haiku 4.5 and GPT-6 Sol. The newer models in the table score higher.
- A score difference of less than 5 points is a tie. Two benchmark runners differ by 5 points on the same configuration.
- If the suggested pick fails, increase the effort one level before you change the model.
- Sonnet 5.5 loses much quality below high effort. GPT-6.1 Sol loses little quality between medium and max.

## Evidence

All scores come from benchmarks that run the models in Claude Code and in Codex.

| Measurement | Claude Code | Codex | Source |
|---|---|---|---|
| Terminal tasks | Opus 5.5 max: 64.9 and 63.1 | GPT-6.1 Sol max: 58.2. GPT-6.1 Sol xhigh: 54.5 | Terminal-Bench 4.0 leaderboard, Artificial Analysis |
| Repository questions | Opus 5.5 max: 66.4. Sonnet 5.5 max: 66.9 | GPT-6.1 Sol xhigh: 61.0 | Artificial Analysis |
| Long repository changes | Sonnet 5.5 max: 72.0. Opus 5.5 max: 68.4 | GPT-6.1 Sol xhigh: 73.2. GPT-6.1 Sol medium: 72.0 | Artificial Analysis |
| Time for each task | Opus 5.5 max: 65 minutes. Sonnet 5.5 max: 87 minutes | GPT-6.1 Sol xhigh: 16 minutes | Artificial Analysis |
| Sonnet 5.5 by effort | low 42, medium 46, high 55, xhigh 63, max 68 | Not applicable | Artificial Analysis |
| GPT-6.1 Sol by effort | Not applicable | low 57, medium 61, high 60, xhigh 63, max 60 | Artificial Analysis |

Limits of the evidence:

- Opus 5.5 has measured scores only at max effort. The Opus picks below max effort follow the guidance from Anthropic.
- No benchmark compares the tools for front-end work, code review, or design decisions.

## Refresh

1. Read the sources below and find the current models, effort levels, and scores.
2. Update the picks table, the commands, the rules, and the evidence.
3. Set the `As of` date to the current date.

Sources:

- Claude models and effort: https://platform.claude.com/docs/en/models/overview and https://code.claude.com/docs/en/model-config
- Codex models and effort: https://learn.chatgpt.com/docs/models.md and https://learn.chatgpt.com/docs/model-selection.md
- Artificial Analysis Coding Agent Index: https://artificialanalysis.ai/agents/coding
- Terminal-Bench leaderboard: https://www.tbench.ai/
