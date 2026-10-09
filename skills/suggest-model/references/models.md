# Model picks

**As of:** 2026-10-09

## Picks table

| Task type | Examples | Claude Code | Codex | Winner | Reason |
|---|---|---|---|---|---|
| Mechanical edit | Rename, reformat, boilerplate, a one-line fix | Haiku 5.5, medium | GPT-6.1 Sol, low | Tie | No benchmark compares the tools for this work. |
| Bulk scan | Search many files, extract data, classify items | Haiku 5.5, medium | GPT-6 Luna, high | Tie | No measurement separates the two picks for this work. |
| Scoped change | A feature or a bug fix in a few files, clear requirements | Opus 5.5, medium | GPT-6.1 Sol, medium | Tie | No measurement compares the two picks at these efforts. |
| Front-end work | Layout, components, visual polish | Sonnet 5.5, high | GPT-6.1 Sol, medium | Tie | No benchmark compares the tools for this work. |
| 3D modeling | Build or edit models, scenes, or assets with a 3D tool or with scripts | Opus 5.5, medium | GPT-6.1 Sol, medium | Tie | No benchmark compares the tools for this work. |
| Code review | Review a diff, a branch, or a module | Opus 5.5, high | GPT-6.1 Sol, xhigh | Tie | No benchmark compares the tools for this work. |
| Design decision | Architecture, a plan, unclear requirements | Opus 5.5, high | GPT-6.1 Sol, xhigh | Tie | No benchmark compares the tools for this work. |
| Code investigation | Explain a codebase, trace behavior, answer questions about a repository | Sonnet 5.5, xhigh | GPT-6.1 Sol, xhigh | Tie | The two picks score within approximately 1 point on repository questions. |
| Hard debugging | Root cause search, build failures, environment or terminal problems | Opus 5.5, xhigh | GPT-6.1 Sol, xhigh | Claude Code | Claude Code scores 6 to 9 points higher on terminal tasks in two independent sources. |
| Long repository change | A refactor, a migration, or a feature in many files, with little supervision | Sonnet 5.5, xhigh | GPT-6.1 Sol, xhigh | Codex | The scores tie, and Codex completes each task in less time and at approximately a third of the cost. |

## Commands

| Tool | Model | Effort |
|---|---|---|
| Claude Code | `/model opus`, `/model sonnet`, `/model haiku` | `/effort low`, `/effort medium`, `/effort high`, `/effort xhigh`, `/effort max`. `/effort auto` restores the default. |
| Codex | `/model`, then select the model | In the same `/model` picker, select Low (Light in the desktop app), Medium, High, or Extra High (xhigh). For Max or Ultra, select More reasoning… |

The Claude Code commands assume the Anthropic API. On Bedrock and Google Cloud, `/model haiku` selects Haiku 4.5 and `/model sonnet` selects Sonnet 4.5.

## Rules for the picks

- Suggest only models that the subscription includes. The table excludes Claude Fable 5.1. On Pro, Fable 5.1 bills to usage credits. On Max, Fable 5.1 scores lower in Claude Code than Opus 5.5 max and Sonnet 5.5 max.
- The table excludes GPT-6 Astra. Astra shows no measured coding gain over GPT-6.1 Sol in Codex.
- The table excludes Claude Haiku 4.5 and GPT-6 Sol. Haiku 4.5 has no effort setting, and the newer models score higher.
- A score difference of less than 5 points is a tie. Two benchmark runners differ by 5 points on the same configuration.
- When two Claude picks tie, suggest the cheaper pick. Cheaper means the lower measured cost for each task. If no cost is measured, cheaper means the lower price tier: Haiku, then Sonnet, then Opus.
- Suggest Haiku 5.5 only for mechanical edits and bulk scans. At each effort, Haiku 5.5 scores more than 5 points below Sonnet 5.5 on the coding agent index.
- If the suggested pick fails, increase the effort one level before you change the model. Exception: if Haiku 5.5 fails at xhigh, change to Sonnet 5.5. Haiku 5.5 max scores lower than xhigh and costs approximately 4 times more.
- Sonnet 5.5 loses much quality below high effort. GPT-6.1 Sol loses little quality between medium and max.

## Evidence

The scores come from two sources that run the models in Claude Code and in Codex: the Artificial Analysis Coding Agent Index (AA) and the Terminal-Bench 4.0 leaderboard (TB).
AA measures terminal tasks with Terminal-Bench 4.0, repository questions with SWE-Atlas-QnA, and long repository changes with DeepSWE v1.1. The AA index is the average of the three.

| Measurement | Claude Code | Codex | Source |
|---|---|---|---|
| Terminal tasks | Opus 5.5 max: 64.9 (TB), 63.1 (AA). Sonnet 5.5 max: 61.8 (TB), 66.2 (AA). Sonnet 5.5 xhigh: 58.1 (AA). Haiku 5.5 max: 29.8 (AA) | GPT-6.1 Sol max: 58.2 (TB), 53.0 (AA). GPT-6.1 Sol xhigh: 54.5 (AA) | TB, AA |
| Repository questions | Opus 5.5 max: 66.4. Sonnet 5.5 max: 66.9. Sonnet 5.5 xhigh: 62.1. Haiku 5.5 xhigh: 51.6. Haiku 5.5 medium: 41.7. Sonnet 5.5 low: 39.0 | GPT-6.1 Sol xhigh: 61.0 | AA |
| Long repository changes | Sonnet 5.5 max: 72.0. Opus 5.5 max: 68.4. Sonnet 5.5 xhigh: 68.4. Haiku 5.5 xhigh: 49.0 | GPT-6.1 Sol xhigh: 73.2. GPT-6.1 Sol medium: 72.0 | AA |
| Time for each task | Opus 5.5 max: 65 minutes. Sonnet 5.5 max: 87 minutes. Sonnet 5.5 xhigh: 27 minutes. Sonnet 5.5 low: 6 minutes. Haiku 5.5 medium: 14 minutes. Haiku 5.5 xhigh: 26 minutes | GPT-6.1 Sol xhigh: 16 minutes | AA |
| Cost for each task | Opus 5.5 max: $13.04. Sonnet 5.5 max: $14.19. Sonnet 5.5 xhigh: $3.33. Sonnet 5.5 low: $0.48. Haiku 5.5 medium: $0.23. Haiku 5.5 xhigh: $0.61 | GPT-6.1 Sol xhigh: $1.04 | AA |
| Sonnet 5.5 index by effort | low 42, medium 46, high 55, xhigh 63, max 68 | Not applicable | AA |
| Haiku 5.5 index by effort | low 28, medium 34, high 35, xhigh 41, max 37 | Not applicable | AA |
| GPT-6.1 Sol index by effort | Not applicable | low 57, medium 61, high 60, xhigh 63, max 60 | AA |

The scores for 3D modeling come from older models in research harnesses that use Blender. They show a direction only.

| Measurement | Result | Source |
|---|---|---|
| Scene tasks through Blender tools | Opus 4.6 high: 48.9. GPT 5.4 medium: 48.7. GPT 5.4 high: 48.7. Sonnet 5 high: 39.5 | SceneActBench |
| Effort for the strongest models | More reasoning changes the score by fewer than 5 points | 3DCodeBench |
| Scripts that run without an error | One attempt: 70%. Attempts with error feedback: 97% | 3DCodeBench |
| Human preference for generated objects | GPT-5.5: 1163. Opus 4.7: 1006 | 3DCodeBench |

Limits of the evidence:

- Opus 5.5 has measured scores only at max effort. The Opus picks below max effort follow the guidance from Anthropic.
- No benchmark measures mechanical edits or bulk scans. The Haiku 5.5 picks follow the guidance from Anthropic and the scores on repository questions.
- The AA costs for Haiku 5.5 exclude the higher price for prompts above 100K tokens. The real cost is probably higher.
- The Claude scores on AA include some attempts that an older model completed after a refusal.
- No benchmark compares the tools for front-end work, code review, or design decisions.
- No benchmark measures the current models for 3D modeling. The picks follow the scores of the older models.

## Refresh

1. Read the sources below and find the current models, effort levels, and scores.
   AA hides most effort rows by default. Read all the rows.
2. Update the picks table, the commands, the rules, and the evidence.
3. Set the `As of` date to the current date.

Sources:

- Claude models and effort: https://platform.claude.com/docs/en/models/overview, https://platform.claude.com/docs/en/about-claude/models/choosing-a-model, https://platform.claude.com/docs/en/build-with-claude/effort, and https://code.claude.com/docs/en/model-config
- Claude Haiku 5.5: https://www.anthropic.com/claude-haiku-5-5
- Codex models and effort: https://learn.chatgpt.com/docs/models.md and https://learn.chatgpt.com/docs/model-selection.md
- Artificial Analysis Coding Agent Index: https://artificialanalysis.ai/agents/coding-agents and https://artificialanalysis.ai/methodology/coding-agents-benchmarking
- Terminal-Bench leaderboard: https://www.tbench.ai/leaderboard/terminal-bench/4.0
- SceneActBench: https://arxiv.org/abs/2607.22393
- 3DCodeBench: https://arxiv.org/abs/2606.01057
