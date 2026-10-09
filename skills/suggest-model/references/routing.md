# Routing

**Verified:** 2026-10-09

Each pick is `<role>, <effort>`. [The catalog](catalog.md) gives the model for each role.
The grade shows the strength of the evidence for the row: Strong, Moderate, Weak, or None.
[The evidence](evidence.md) gives each evidence ID.

## Task types

| Task type | Examples |
|---|---|
| Build | Write or change code, tests, or scripts. Debug, refactor, or migrate. |
| Review | Review a diff, a branch, a pull request, or a module. |
| Plan | Architecture, a design decision, a task breakdown, or unclear requirements. |
| Research | Find information in files, a repository, documents, or web sources. Compare options. Write a report with sources. |
| Writing | Documentation, tickets, messages, notes, or a prompt for another agent. The facts are known. |
| Tool workflow | A known procedure through MCP connectors or a CLI, such as Jira, Outlook, Teams, or gh. |
| 3D modeling | Build or edit models, scenes, or assets with a 3D tool, such as Blender, or with scripts. |

## Difficulty

| Difficulty | Meaning |
|---|---|
| Light | Short, mechanical, and easy to check. Examples: a rename, a typo, a short message, one lookup, or a search of supplied material. |
| Standard | A clear goal, known inputs, and a small number of steps or files. |
| Hard | One or more of these: an unknown cause, many files or records, conflicting sources, a design decision with a lasting effect, or no automatic checks. |
| Long | The user wants the agent to work for more than approximately 30 minutes without supervision. |

## Picks

| Task type | Difficulty | Claude Code | Codex | Grade | Evidence |
|---|---|---|---|---|---|
| Build | Light | CC-Mid, low | CX-Main, low | Moderate | E1, E6 |
| Build | Standard | CC-Mid, medium. Use high for a bug fix with probable edge cases. | CX-Main, medium | Moderate | E1, E3, E6 |
| Build | Hard | CC-Large, medium. Use high when verification is important. | CX-Main, xhigh | Moderate | E2, E4 |
| Review | Light | CC-Mid, medium | CX-Main, medium | Weak | E14 |
| Review | Standard | CC-Large, medium | CX-Main, medium | Weak | E14 |
| Review | Hard | CC-Large, high | CX-Main, xhigh | Weak | E14 |
| Plan | Light | CC-Mid, medium | CX-Main, medium | None | — |
| Plan | Standard | CC-Large, medium | CX-Main, medium | Weak | E15 |
| Plan | Hard | CC-Large, high | CX-Main, xhigh | Weak | E15 |
| Research | Light | CC-Small, medium | CX-Small, high | Moderate | E10 |
| Research | Standard | CC-Large, medium | CX-Main, medium | Moderate | E8, E9 |
| Research | Hard | CC-Large, high | CX-Main, xhigh | Moderate | E8, E9 |
| Writing | Light | CC-Mid, low | CX-Main, low | None | — |
| Writing | Standard | CC-Mid, medium | CX-Main, medium | Weak | E7 |
| Writing | Hard | CC-Large, medium | CX-Main, xhigh | Moderate | E7 |
| Tool workflow | Light | CC-Mid, low | CX-Main, low | Weak | E11 |
| Tool workflow | Standard | CC-Mid, medium | CX-Main, medium | Moderate | E11 |
| Tool workflow | Hard | CC-Large, medium | CX-Main, xhigh | Moderate | E11 |
| 3D modeling | Light | CC-Mid, low | CX-Main, low | None | — |
| 3D modeling | Standard | CC-Large, medium | CX-Main, medium | Weak | E16 |
| 3D modeling | Hard | CC-Large, high | CX-Main, xhigh | Weak | E16, E17 |

## Rules for the picks

- For a Long task, use the Hard row of the task type. Then set the Claude Code pick to CC-Large, high. Use CC-Large, xhigh only if the user accepts high quota use.
- For a task with high risk, increase the effort of each pick by one level. Do not change the model. High risk includes production data, security, payments, irreversible actions, external messages, and writes to a system of record.
  - In Claude Code, do not increase above xhigh.
  - In Codex, change medium to xhigh. High scores no better than medium in Codex (E4).
- Use Research, Light only for material that the user or the repository supplies. If the task needs facts that the model must know, use Research, Standard. CC-Small, CC-Mid, and CX-Small make more factual errors (E9).
- For Research in Codex, tell the user to start with `codex --search`. The default search uses cached data.
- Never use CC-Small or CX-Small for a step that writes to a system, such as a ticket update or an email (E5, E11).
- For a plan that comes before a build in the same session, suggest `/model opusplan` in Claude Code. In Codex, suggest Plan mode with `plan_mode_reasoning_effort` (E15).
- For Plan, Hard or 3D modeling, Hard, Codex can use CX-Strong, medium if the quota is sufficient. The grade for this option is Weak (E15, E17).
- For 3D modeling, tell the user to run each script, give the errors to the agent, and examine the render. This loop helps more than more effort (E16).
- For 3D modeling, tell the user to save the file at checkpoints and start a new session. 3D sessions use much quota (E17).
- Suggest Codex fast mode only if the user says that speed is important. It uses 2.5 times the quota (E13).

## Better tool

Use the first rule that applies:

1. If the user says that one tool has low quota, select the other tool.
2. If the task needs a connector, an MCP server, or live web search that only one tool has, select that tool. For a Tool workflow task with no information about the setup, write "Either. Use the tool that has the connector."
3. If the user says that one tool gives better results for this work, select that tool.
4. Select the lean for the task type from this table.

| Task type | Lean | Grade | Evidence |
|---|---|---|---|
| Build | Either | None. The scores of the tools are within the measurement noise, and only at max effort. | E12 |
| Review | Claude Code | Weak | E14 |
| Plan | Either | None | — |
| Research | Claude Code. For questions about PDF files, Codex. | Moderate. For PDF files, Weak. | E8, E10 |
| Writing | Claude Code | Moderate | E7 |
| Tool workflow | Either | None. The models score almost the same. | E11 |
| 3D modeling | Either | None. The evidence conflicts. | E17 |

For Either, write: "Either. No evidence shows a difference. Use the tool that has more quota."
For a Review or a Plan with high risk, add: "For a second opinion, use the tool that did not do the work."

## Escalation

When the first pick falls short, find how it failed:

- If the model skipped files, sources, tests, or edge cases, increase the effort one level on the ladder.
- If the model had the full context and tried, but the result is wrong, move to the next model on the ladder, or try the other tool.
- If the model misread the task, make the task clear first. More effort increases misreads (E6).
- If the result is correct but slow, decrease the effort for the next task.

Ladders:

- Claude Code: CC-Mid, low → CC-Mid, medium → CC-Mid, high → CC-Large, medium → CC-Large, high → CC-Large, xhigh.
  Do not use CC-Mid, xhigh. CC-Large, high costs approximately the same and scores the same or better (E2).
- Codex: CX-Main, low → CX-Main, medium → CX-Main, xhigh. Then try the other tool, or CX-Strong, medium if the quota is sufficient.
  Do not use CX-Main, high. It scores no better than medium. Do not use max. It scores lower than xhigh in Codex (E4).

In the `If it falls short` line, write the failure and the next step on the ladder.
