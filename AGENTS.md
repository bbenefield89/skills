# Agent instructions

## Add a skill to the marketplace

Register each new skill in `.claude-plugin/marketplace.json`. Add its path to the `skills` list of one plugin.
If the user names no plugin, select the plugin whose scope fits the skill. State the selection in your reply so the user can change it.

- `general-skills`: portable skills that do not depend on one employer, project, or game engine.
- `corrohealth-skills`: skills that depend on CorroHealth systems, repositories, or workflows, such as FSI, Tempo, or Azure DevOps pull requests.
- `godot-skills`: skills for Godot projects or GDScript.

If no plugin fits, propose a new plugin and ask the user before you create it.
