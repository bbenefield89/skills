# Godot rules

Read `project.godot` and the applicable engine version.
Inspect relevant scripts, `.tscn` scenes, `.tres` resources, and inherited scenes together.
Apply this profile to Godot projects using GDScript or C#.

The editor-authoring rules below are this skill's review defaults.
Treat them as recommendations unless the user or repository makes them requirements.
Godot supports both scene authoring and runtime construction.

## GO1. Use native UI layout

Prefer `Control` anchors, containers, size flags, minimum sizes, and Theme resources for ordinary UI layout.
Identify code that repeatedly calculates positions or dimensions for stable UI.
Check whether native layout already expresses the required arrangement.
For custom geometry, identify the native limitation or dynamic requirement that justifies the code.
Accept a custom `Container`, animation, safe-area adaptation, or dynamic layout when evidence supports the need.

A container controls its child layout. Check manual child positioning against the parent's layout behavior.
Report a conflict as a defect only when the code produces an incorrect result.
Report an authoring preference separately from a behavior defect.

## GO2. Author stable presentation in scenes and resources

Prefer scenes and Inspector-editable resources for stable UI structure, fixed copy, spacing, dimensions, and artwork.
Keep runtime state, data values, visibility, input, focus, and animation in the appropriate code owner.
Inspect `_ready()` setup and node construction for presentation that could remain editable in the scene.
Accept runtime construction when existence or quantity is genuinely dynamic.
Instantiating an authored scene for a variable list is a valid dynamic use.
Respect an explicit repository decision to use programmatic UI.

## GO3. Respect scene ownership and lifecycle

Trace node dependencies through scene creation, tree entry, readiness, replacement, and deletion.
Inspect hardcoded paths across scene boundaries and dependencies on unrelated ancestors or global state.
Check signal subscriptions and callbacks against the engine's connection and object-lifetime behavior.
Check resource mutation for unintended effects on shared instances.
Report an ownership concern only with a concrete reuse, lifecycle, or state consequence.

## GO4. Respect language and engine contracts

For GDScript, inspect unsafe Variant assumptions, invalid node casts, and reflective calls that hide known contracts.
Use repository rules to judge typing and native `##` documentation requirements.
For C#, combine this profile with the C# and .NET profile.
Check engine APIs against the project's version before declaring them invalid.
Use existing project validation when appropriate. Headless checks do not prove responsive layout or visual quality.

Example: A static menu builds labels and coordinates in `_ready()` despite an applicable scene-authoring requirement.
Report the requirement violation with its source and a scene-based correction.
A runtime inventory list that instantiates authored item scenes does not violate the static-authoring preference.

## Official references

Use the project's documentation version when it differs from `stable`.
The authoring preference above is a review policy rather than a claim that Godot forbids code-based UI.

- [Using Containers](https://docs.godotengine.org/en/stable/tutorials/ui/gui_containers.html): Native sizing and positioning, including custom containers.
- [Size and anchors](https://docs.godotengine.org/en/stable/tutorials/ui/size_and_anchors.html): Native layout across parent sizes.
- [Scene organization](https://docs.godotengine.org/en/stable/tutorials/best_practices/scene_organization.html): Scene dependencies and ownership.
