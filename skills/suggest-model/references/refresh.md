# Refresh procedure

Use this procedure only when the user asks for a refresh.
The refresh uses the web and quota. Do not write a file before the user approves the changes.

1. Read the primary sources for each plan:
   - Anthropic: https://code.claude.com/docs/en/model-config, https://code.claude.com/docs/en/fast-mode, https://code.claude.com/docs/en/mcp, https://code.claude.com/docs/en/costs, https://claude.com/pricing, the plan articles on https://support.claude.com, and the model pages on https://www.anthropic.com.
   - OpenAI: https://learn.chatgpt.com/docs/models, https://learn.chatgpt.com/docs/pricing, https://learn.chatgpt.com/docs/changelog, https://learn.chatgpt.com/docs/codex/cli, https://learn.chatgpt.com/docs/config-file/config-reference, https://learn.chatgpt.com/docs/extend/mcp, and https://learn.chatgpt.com/docs/plugins.
2. For each role in the catalog, find these items:
   - A newer model in the same family that the plan includes without credits.
   - The effort levels and the default effort of the model.
   - Plan limits on effort levels, such as Astra Extra High.
   - Changes to the commands, the web search mode, the connectors, and the MCP support.
   - New items that need credits. Add these items to the excluded list.
3. Read the independent measurements:
   - Artificial Analysis: the coding agent comparisons at https://artificialanalysis.ai/agents/coding-agents and the model comparisons. Read all effort rows and all benchmark columns. The pages hide most effort rows by default.
   - https://snorkel.ai/leaderboard/terminal-bench-4-0/ and https://www.vals.ai/benchmarks/terminal-bench-4.
   - https://arena.ai/leaderboard/code/webdev and https://arena.ai/leaderboard/text/creative-writing.
   - Code review, tool use, research, and 3D benchmarks: MacroscopeBench, MCP-Atlas, DeepResearch Bench, Blender Bench, and 3DCodeBench.
4. Read the vendor guidance: launch posts and effort guides.
5. Read a practitioner report only when it names the current model versions and uses more than one run.
6. Record each number with its date and source. Give each claim one grade from [the evidence](evidence.md).
   Trust an aggregator site only when the primary page shows the same number.
7. Connect each role to its new model. A new model takes the role of the model that it replaces.
   If no measurement exists for the new model, use the effort that the vendor recommends. Mark the row "provisional".
8. Examine the assumption for each role and the grade for each routing row.
   - If an assumption is no longer true, change the routing.
   - If the evidence for a row is about a replaced model, set the grade to Weak.
   - Remove a gap from the known gaps only when real evidence exists.
9. Show the user the changes to each file and a short summary. Write the files only after the user approves.
10. Set `Verified` to the current date in each file. Set `Review by` to 30 days after the current date.
