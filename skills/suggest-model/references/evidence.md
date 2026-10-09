# Evidence

**Verified:** 2026-10-09

Each claim has a grade:

- Strong: two or more independent sources agree.
- Moderate: one independent measurement, or vendor guidance and a practitioner report agree.
- Weak: one small study, a mirror of a source, results for older models, or LLM judges only.
- None: no evidence.

AA is Artificial Analysis. The AA model scores come from the AA test harness, not from Claude Code or Codex.
The costs are API prices. They are not the quota of a plan.
All sources were accessed on 2026-10-09.

| ID | Claim | Grade | Sources |
|---|---|---|---|
| E1 | Opus costs several times more for each task than Sonnet. Sonnet is sufficient for scoped work. At medium, the cost for each task is $1.34 for Opus and $0.48 for Sonnet. | Strong | https://support.claude.com/en/articles/14552983-models-usage-and-limits-in-claude-code, https://artificialanalysis.ai/models/releases/comparisons/claude-opus-5-5-vs-claude-sonnet-5-5, https://paddo.dev/blog/default-was-right/ (2026-09-29) |
| E2 | Terminal-Bench 4.0 from low to max. Opus 5.5: 31, 53, 57, 60, 60. Sonnet 5.5: 21, 30, 44, 57, 64. Sonnet xhigh ($2.01) scores the same as Opus high ($1.82). Opus is faster. | Moderate | https://artificialanalysis.ai/models/releases/comparisons/claude-opus-5-5-vs-claude-sonnet-5-5 |
| E3 | On long repository changes (DeepSWE), the score changes little with effort. Claude Code with Sonnet: 62 to 72. Codex with Sol: 68 to 73. | Moderate | https://artificialanalysis.ai/agents/coding-agents/comparisons/claude-code-vs-codex |
| E4 | The coding agent index for Codex with GPT-6.1 Sol from low to max: 57, 61, 60, 63, 60. Codex with Astra at max: 62, at approximately 7 times the API cost of Sol at xhigh. | Moderate | https://artificialanalysis.ai/agents/coding-agents/comparisons/claude-code-vs-codex, https://benchlm.ai/benchmarks/aacodingagents (2026-10-07) |
| E5 | Haiku 5.5 and Luna are weak at agentic coding and tool workflows. Claude Code with Haiku at medium: index 34. Luna: Terminal-Bench 4.0 at 12.6 or lower. Anthropic states that Sonnet and Opus are better for complex agentic coding. | Strong | https://artificialanalysis.ai/models/releases/comparisons/claude-haiku-5-5-vs-gpt-6-luna, https://www.anthropic.com/claude-haiku-5-5 (2026-10-07) |
| E6 | More effort decreases missed cases (59 to 24) and incomplete fixes (31 to 10). More effort increases misreads (25 to 47). With a detailed specification, the effort levels give similar results. If the model skips work, increase the effort. If the model fails with the full context, use a larger model. `max` gives diminishing returns. | Moderate | https://claude.dev/blog/spending-your-effort/ (2026-09-25), https://claude.com/blog/claude-model-and-effort-level-in-claude-code (2026-07-07), https://code.claude.com/docs/en/model-config |
| E7 | Writing. Text Arena creative writing: Opus 5.5 high 1517 ±17, Sonnet 5.5 xhigh 1463 ±19, GPT-6.1 Sol max 1462 ±20, Astra max 1448 ±13. AA-Briefcase business documents at medium: Opus 1628, Astra 1459, Sonnet 1442, Sol 1365. More effort improves long documents much, mostly on Sonnet. No benchmark measures tickets, short messages, or prompts. | Moderate | https://arena.ai/leaderboard/text/creative-writing (2026-10-08), https://artificialanalysis.ai/models/releases/comparisons/claude-opus-5-5-vs-claude-sonnet-5-5 |
| E8 | Knowledge work. GDPval-AA at medium: Opus 1586, Astra 1468, Sol 1433, Sonnet 1324. LLM judges grade the tasks. | Moderate | https://artificialanalysis.ai/models/releases/comparisons/claude-opus-5-5-vs-gpt-6-1-sol, https://artificialanalysis.ai/methodology/intelligence-benchmarking |
| E9 | Factual recall without sources. AA-Omniscience from low to max: Opus 39 to 46, Astra 41 to 44, Sol 38 to 42, Sonnet 19 to 32, Haiku 3 to 11, Luna −9 to 1. | Moderate | https://artificialanalysis.ai/models/releases/comparisons/claude-opus-5-5-vs-gpt-6-1-sol, https://artificialanalysis.ai/models/releases/comparisons/claude-haiku-5-5-vs-gpt-6-luna |
| E10 | Reading supplied documents. AA-LCR changes little with the model or the effort: 76 to 85 for the large models, 77.3 for Haiku at medium, and 78.3 for Luna at medium. Questions about PDF files (GDP.pdf): Sol 27 to 32, Opus 26 to 29, Sonnet 16 to 26. | Moderate. For PDF files, Weak. | https://artificialanalysis.ai/models/releases/comparisons/claude-opus-5-5-vs-gpt-6-1-sol, https://artificialanalysis.ai/models/releases/comparisons/claude-haiku-5-5-vs-gpt-6-luna |
| E11 | Tool workflows across SaaS APIs. AutomationBench-AA at medium: Astra 64.6, Sol 62.6, Opus 61.2, Sonnet 54.9, Luna 40.5, Haiku 28.6. Effort helps mostly above low. No MCP benchmark measures the current models. | Moderate | https://artificialanalysis.ai/models/releases/comparisons/claude-opus-5-5-vs-gpt-6-1-sol, https://labs.scale.com/leaderboard/mcp_atlas |
| E12 | Claude Code against Codex, at max effort only. Snorkel Terminal-Bench 4.0: Claude Code with Opus 64.8 ±3.1, with Sonnet 61.8 ±2.9. Codex with Astra 58.2 ±2.8, with Sol 58.2 ±3.1. AA index: Claude Code with Sonnet max 68, with Opus max 66. Codex with Sol xhigh 63. | Weak | https://snorkel.ai/leaderboard/terminal-bench-4-0/, https://artificialanalysis.ai/agents/coding-agents/comparisons/claude-code-vs-codex |
| E13 | Plus estimates for each 5 hours: Astra 5 to 45 messages, Sol 15 to 160 messages. Fast mode uses 2.5 times the quota. | Moderate | https://learn.chatgpt.com/docs/pricing |
| E14 | Code review. CodeRabbit, 13 known bugs: Opus 5.5 found 8 at 66.7% precision. Sonnet 5.5 found 6 at 41.2% precision. Different models found different bugs. MacroscopeBench, older models: Opus 5 high recall 76.6%, Astra max precision 91.7%. No review data exists for GPT-6.1 Sol. | Weak | https://www.coderabbit.ai/blog/sonnet-5-5-model-review (2026-09-28), https://macroscope.com/content/ai-code-review-benchmark-best-models (2026-09-22) |
| E15 | Planning. No benchmark exists. Anthropic recommends Opus for architecture decisions. Reasoning benchmark (Humanity's Last Exam) at medium: Opus 54.7, Sol 49.9, Sonnet 39.8. OpenAI states that Astra asks focused questions. | Weak | https://code.claude.com/docs/en/costs, https://artificialanalysis.ai/models/releases/comparisons/claude-opus-5-5-vs-gpt-6-1-sol, https://learn.chatgpt.com/docs/models |
| E16 | 3D modeling, older models. 3DCodeBench with Blender scripts: one attempt succeeds 91% for Opus 4.7, 90.6% for GPT-5.5, and 80.4% for Sonnet 4.6. Error feedback increases success from 70% to 97%. More reasoning helps the strongest models little. SceneActBench: Opus 4.6 high 48.9, GPT-5.4 medium 48.7, Sonnet 5 high 39.5. | Weak | https://arxiv.org/abs/2606.01057, https://arxiv.org/abs/2607.22393 |
| E17 | 3D modeling, current models. One report states that Astra leads Blender Bench v1 and that Opus 5.5 leads modeling and cloth. The primary results were not found. One Blender MCP test used 60% of a session for one scene. | Weak | https://x.com/LeeLeepenkman/status/2105768195110162443, https://www.mindstudio.ai/blog/claude-blender-mcp-60-percent-tokens-donut-test-results (2026-05-01) |
| E18 | Codex can give less reasoning than the API at the same effort. One account reports this. Nobody has repeated the result. | Weak | https://www.orcarouter.ai/blog/gpt-6-astra-codex-reasoning-budget (2026-10-08) |

## Known gaps

No evidence exists for these items:

- Tickets, short messages, notes, and prompts for other agents.
- Planning and design decisions with the current models.
- MCP connector workflows with the current models.
- 3D modeling with the current models, from a primary source.
- Code review with GPT-6.1 Sol.
- Non-coding results inside Claude Code or Codex.
- Opus 5.5 below max inside Claude Code, and Astra below max inside Codex.
- The quota cost of each model on Claude Pro. A comparison of the Pro quota and the Plus quota.
- Plus access to Astra Extra High, Max, and Ultra.
