# Catalog

**Verified:** 2026-10-09
**Review by:** 2026-11-08

Plans: Claude Pro for Claude Code, and ChatGPT Plus for Codex.

## Roles

The routing uses roles. This table connects each role to the current model.
At each refresh, examine the assumption for each role.

| Role | Model | Name in the tool | Assumption |
|---|---|---|---|
| CC-Large | Opus 5.5 | `opus` | It is the strongest Claude model on Pro. At medium or high, it gives better value than CC-Mid at xhigh on difficult work. It makes fewer factual errors than CC-Mid. |
| CC-Mid | Sonnet 5.5 | `sonnet` | It costs approximately one third of CC-Large for each task. It is sufficient for scoped work at medium. Below xhigh, it loses much quality on difficult work. |
| CC-Small | Haiku 5.5 | `haiku` | It is sufficient to read and extract information from supplied material. It is weak at agentic coding, tool workflows, and factual recall. |
| CX-Main | GPT-6.1 Sol | `gpt-6.1-sol` | Its scores are near CX-Strong, and it uses a part of the quota. Its score changes little between medium and max. |
| CX-Strong | GPT-6 Astra | `gpt-6-astra` | It uses approximately 3 times the Plus quota of CX-Main. It shows no clear gain over CX-Main in Codex. |
| CX-Small | GPT-6 Luna | `gpt-6-luna` | It has a large quota. It is weak at agentic work and factual recall. Start it at high. |

## Claude Code on Claude Pro

- Default: Opus 5.5 at medium.
- Effort levels: `low`, `medium`, `high`, `xhigh`, and `max`. All three models use `medium` as the default.
- `max` applies to the current session only.
- Minimum version: Claude Code v2.1.293. Earlier versions connect `haiku`, `sonnet`, or `opus` to older models.

| Action | Command |
|---|---|
| Set the model | `/model <alias>`. In the picker, Enter saves the default, and `s` applies the model to this session only. |
| Set the effort | `/effort <level>`. `/effort auto` restores the default. |
| Start with settings | `claude --model <alias> --effort <level>` |
| Reason more for one turn | Put `ultrathink` in the prompt. |
| Plan with Opus, build with Sonnet | `/model opusplan` |
| Show the quota | `/usage` |

Capabilities:

- Web search: the WebSearch and WebFetch tools. The permissions must allow the tools.
- Connectors: the connectors that the user adds at claude.ai show in Claude Code when the user signs in with the subscription. Connect Microsoft 365 (Outlook and Teams) at claude.ai. `claude mcp add` cannot add Microsoft 365.
- MCP servers: `claude mcp add`. `/mcp` shows the connected servers.
- Deep research: the `/deep-research` workflow. It uses much quota.
- Images: Claude Code can read image files, such as renders.

Limits: Pro has a 5-hour limit and a weekly limit. Claude Code and claude.ai share the limits. Anthropic publishes no numbers. Opus uses more quota than Sonnet.

## Codex on ChatGPT Plus

- Default: GPT-6.1 Sol. Its default effort is probably Medium. Check it with `/status`.
- Minimum version: Codex CLI 0.159.1.

| Label | Config value |
|---|---|
| Light (Low in the CLI) | `low` |
| Medium | `medium` |
| High | `high` |
| Extra High | `xhigh` |
| Max | `max` |
| Ultra | `ultra` |

- GPT-6.1 Sol supports Light to Max.
- GPT-6 Luna supports Light to Max.
- GPT-6 Astra shows the Light, Medium, and Extra High presets. Some paid plans omit Astra Extra High.
- Picker-gated: Astra Extra High, Max for each model, and Ultra. OpenAI does not state that Plus includes them. Suggest them only if the picker of the user shows them.

| Action | Command |
|---|---|
| Set the model and effort | `/model`, then select the model and the effort. For Max or Ultra, select More reasoning…. |
| Start with settings | `codex -m <id> -c model_reasoning_effort=<value>` |
| Save the settings | `model` and `model_reasoning_effort` in `~/.codex/config.toml` |
| Set the Plan mode effort | `plan_mode_reasoning_effort` in `~/.codex/config.toml` |
| Show the settings and usage | `/status` |
| Desktop app | The model control below the composer |

Capabilities:

- Web search: the default mode is `cached`. It uses an OpenAI index and has no live web access. For current information, start with `codex --search`, or set `web_search = "live"`.
- MCP servers: `codex mcp add`, or `[mcp_servers.<name>]` in `~/.codex/config.toml`. `/mcp` shows the servers. Local MCP servers can be unavailable in Codex cloud.
- Plugins (connectors): `/plugins` in the CLI or the desktop app. The IDE extension does not support plugins. The documentation does not state which plugins Plus includes.
- Code review: the built-in review of uncommitted changes, a commit, or a base branch.
- Images: the `view_image` tool reads local images.
- Data use: on Plus, OpenAI can use data from connected apps for training when "Improve the model for everyone" is on.

Limits: OpenAI estimates the local messages for each 5 hours. These numbers are not fixed limits. Weekly limits can also apply.

| Model | Messages for each 5 hours |
|---|---|
| GPT-6 Astra | 5–45 |
| GPT-6.1 Sol | 15–160 |
| GPT-6 Luna | 350–3,000 |

Fast mode (`/fast`) uses 2.5 times the quota.

## Excluded

Never suggest these items:

- Claude Fable 5 and Fable 5.1. On Pro, they use usage credits.
- The `best` alias. On Pro, it can select Fable.
- Claude fast mode (`/fast`). It uses usage credits only.
- Codex Ultrafast. Plus does not include it.
- GPT-5.5. It leaves Codex on 2026-10-14.
- GPT-6 Sol and the GPT-5.6 models. GPT-6.1 Sol replaces them.
- Each item that needs purchased credits.

## Known changes

- 2026-10-14: GPT-5.5 leaves Codex.
- Artificial Analysis can test Sonnet 5.5 again on its release build. The Sonnet scores can change.
