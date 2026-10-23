---
name: gdscript-cleanup
description: Cleans changed GDScript and directly related Godot scenes using typed interfaces, native documentation, and scene-authoring rules. Use after Godot implementation or when the user requests scoped GDScript hygiene.
---

# GDScript Cleanup

## Shared writing standard

Before you write user-facing prose or artifact prose, read and apply
[the shared ASD-STE100 skill](../asd-ste100/SKILL.md). Preserve this skill's required output contract.

If the shared skill or profile is unavailable, state that limit in the response.
This notice is the only exception to an exact-output rule.
Then apply ASD-STE100 as closely as possible from the available context.

Perform active, behavior-preserving post-implementation hygiene. For every run, read the target repository's `AGENTS.md` and the standards documents that its index names for `.gd` files, `.tscn` files, and UI, usually `docs/standards/gdscript.md`, `docs/standards/scenes.md`, and `docs/standards/ui.md`. Apply each rule that the touched code reaches, including the project rules. A repository that has not migrated points to the legacy `docs/agents/godot-standards.md` instead.

If no standards document exists, ask which standards to apply before you edit. `$setup-godot-project` publishes the documents.

## 1. Resolve scope

Use explicit user scope first, otherwise the task starting point and working diff. Default to changed `.gd` files, changed lines, directly affected interfaces, and directly related `.tscn` scenes. If neither scope source exists, ask.

Leave unrelated legacy issues untouched unless they prevent validation or the user expands scope. Briefly report significant nearby debt.

## 2. Clean in groups

Fix clear in-scope hygiene directly. After each meaningful group, run the narrowest applicable import/parser check and focused tests. Ask before architectural, behavioral, destructive, or scope-expanding changes.

If a project type is unresolved, refresh metadata before changing the type:

1. Run `godot --path . --headless --import --quit` through the repository command interface.
2. Inspect `.godot/global_script_class_cache.cfg` and the intended `class_name` declaration.
3. Retain or restore the concrete type and validate again.

Do not use broad types, preload indirection, or reflective calls merely to evade stale metadata.

## 3. Finish

Use [references/report-schema.md](references/report-schema.md). Within an orchestrated delivery, any unresolved cleanup decision blocks final review.
