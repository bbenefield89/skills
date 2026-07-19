# Godot profile

Load this profile when the repository contains `project.godot`, GDScript, Godot scenes/resources, or equivalent explicit Godot guidance.

Apply these rules to changed project-owned Godot code and directly affected interfaces. Exclude vendored dependencies such as GUT.

## Typed GDScript

- Prefer concrete project types, explicit local and return types, typed enums, typed exported node references, typed getters, and direct method calls.
- Treat avoidable `Variant`, broad engine types, unsafe inference, and reflective method calls as actionable findings.
- Refresh Godot import/class metadata before weakening an unresolved project type.
- Cast unavoidable broad API results to the concrete expected type, including node lookups and dictionary extraction.
- Permit reflection or dynamic typing only for a genuine dynamic requirement documented at the use site.
- Follow the official GDScript style guide manually. Do not introduce a formatter, linter, Python, or gdtoolkit dependency.

## Scene authoring

If a Godot object is a stable, intentional part of the game world, author it in a `.tscn` scene. Create objects at runtime only when their existence or quantity is genuinely dynamic.

Treat stable world objects assembled through `Node.new()`, scripted child construction, or equivalent runtime setup as actionable review findings unless the code documents a genuinely dynamic reason. Do not invent gameplay folders, placeholder scenes, or architecture layers.

## Native documentation

Document every created or changed project-owned script, including tests:

- Begin each script with a native `##` header that briefly explains what it does, enumerates its responsibilities, and states its single reason to change.
- Document every method, including private helpers, lifecycle callbacks, and test methods.
- Document every signal.
- Document named classes, exported properties, enums, and non-obvious constants.

Method and signal documentation describes behavior, parameters with `[param name]`, return value, side effects, emitted signals, preconditions, failure behavior, or listener contract when applicable. Omit sections that genuinely do not apply. Explain intent and contracts rather than syntax.

Use Godot BBCode that renders correctly in editor hover help:

- Use a single `[br]` at the end of the preceding content line.
- Never use `[br][br]`.
- Never begin a documentation line with `[br]`.
- Put `[br]` after bold section labels.

Canonical signal example:

```gdscript
## Emitted after current health is initialized or successfully changed by damage.[br]
## [b]Parameters[/b][br]
## [param current_health] — The new clamped health.[br]
## [param maximum_health] — The configured full-health reference.[br]
## [b]Listener contract[/b][br]
## [code]PlayerHealthBar[/code] listens to update its visible [ProgressBar].
signal health_changed(current_health: int, maximum_health: int)
```

Header example:

```gdscript
## Coordinates health changes for one combatant.[br]
## [b]Responsibilities[/b][br]
## 1. Clamp accepted health values.[br]
## 2. Notify listeners after health changes.[br]
## [b]Single reason to change[/b][br]
## The combatant health-state contract changes.
class_name CombatantHealth
extends Node
```

## Tests

Use the repository's configured Godot test framework. When GUT is configured, run focused GUT tests during implementation and the repository's aggregate command during final validation. Test public behavior and observable scene state; do not expose test-only Godot APIs.

## Stable references

- [Godot GDScript style guide](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html)
- [Godot GDScript documentation comments](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_documentation_comments.html)
- [Godot nodes and scene instances](https://docs.godotengine.org/en/stable/tutorials/scripting/nodes_and_scene_instances.html)
