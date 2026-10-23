# Godot rules

Read `project.godot` and the applicable engine version.
Inspect relevant scripts, `.tscn` scenes, `.tres` resources, and inherited scenes together.
Apply this profile to Godot projects using GDScript or C#.

## Repository standards

Read `AGENTS.md` in the reviewed repository and the standards documents that its index names for the reviewed files, usually `docs/standards/gdscript.md`, `scenes.md`, `ui.md`, and `testing.md`. `setup-godot-project` publishes them.
Evaluate every rule that applies to the reviewed code, including the project rules. Cite each one by file and number, such as `gdscript.md rule 11` or `ui.md rule P2`, and link the document.
A repository that has not migrated points to the legacy `docs/agents/godot-standards.md`. Cite its rules by their GD IDs.
If no standards document exists, state that limit in the report. Then review with GO1, GO2, other repository guidance, and official Godot documentation.

The documents are repository requirements.
Report a departure as a Rule violation in the Repository table.
Report a Defect only when the code produces an incorrect result.
Report an authoring preference separately from a behavior defect.
Before you report a departure, check for a stated exception, a native limitation, or a dynamic requirement that justifies the code.
Respect project-owned guidance that selects another convention, such as programmatic UI.
Rate a declaration-spacing departure Low.
Rate a departure from gdscript.md rule 13 (readable function bodies) Low, because it does not change behavior.
The documentation coverage of gdscript.md rule 11 replaces the general preference to leave obvious methods without comments.

A container controls its child layout. Check manual child positioning against the parent's layout behavior.

Example: A static menu builds labels and coordinates in `_ready()` despite an applicable scene-authoring requirement.
Report the requirement violation with its source and a scene-based correction.
A runtime inventory list that instantiates authored item scenes agrees with the exception in scenes.md rule 1.

## GO1. Respect scene ownership and lifecycle

Trace node dependencies through scene creation, tree entry, readiness, replacement, and deletion.
Inspect hardcoded paths across scene boundaries and dependencies on unrelated ancestors or global state.
Check signal subscriptions and callbacks against the engine's connection and object-lifetime behavior.
Check resource mutation for unintended effects on shared instances.
Report an ownership concern only with a concrete reuse, lifecycle, or state consequence.

## GO2. Respect language and engine contracts

For GDScript, inspect unsafe Variant assumptions, invalid node casts, and reflective calls that hide known contracts.
For C#, combine this profile with the C# and .NET profile.
Check engine APIs against the project's version before declaring them invalid.
Use the project's documentation version when it differs from `stable`.
Use existing project validation when appropriate. Headless checks do not prove responsive layout or visual quality.
