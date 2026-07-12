---
name: gdscript-cleanup
description: Cleans changed GDScript and directly related Godot scenes using typed interfaces, native documentation, and scene-authoring rules. Use after Godot implementation or when the user requests scoped GDScript hygiene.
---

# GDScript Cleanup

Perform active, behavior-preserving post-implementation hygiene. Read [references/gdscript-standards.md](references/gdscript-standards.md) for every run and [references/scene-authoring.md](references/scene-authoring.md) when touched code creates or assembles nodes.

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
