# Godot rules

Read `project.godot` and the applicable engine version.
Inspect relevant scripts, `.tscn` scenes, `.tres` resources, and inherited scenes together.
Apply this profile to Godot projects using GDScript or C#.

## Repository standards

Read `docs/agents/godot-standards.md` in the reviewed repository. `setup-godot-project` publishes it.
Evaluate every rule that applies to the reviewed code. Cite each one by its ID and link the document.
If the document is absent, state that limit in the report. Then review with GO1, GO2, other repository guidance, and official Godot documentation.

The document is a repository requirement.
Report a departure as a Rule violation in the Repository table.
Report a Defect only when the code produces an incorrect result.
Report an authoring preference separately from a behavior defect.
Before you report a departure, check for a stated exception, a native limitation, or a dynamic requirement that justifies the code.
Respect project-owned guidance that selects another convention, such as programmatic UI.
Rate a declaration-spacing departure Low.
GD7 documentation coverage replaces the general preference to leave obvious methods without comments.

A container controls its child layout. Check manual child positioning against the parent's layout behavior.

Example: A static menu builds labels and coordinates in `_ready()` despite an applicable scene-authoring requirement.
Report the requirement violation with its source and a scene-based correction.
A runtime inventory list that instantiates authored item scenes agrees with the GD4 exception.

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
