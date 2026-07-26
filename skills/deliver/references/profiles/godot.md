# Godot profile

Load this profile when the repository contains `project.godot`, GDScript, Godot scenes/resources, or equivalent explicit Godot guidance.

Apply these rules to changed project-owned Godot code and directly affected interfaces. Exclude vendored dependencies such as GUT.

## Typed GDScript

- Prefer concrete project types, explicit local and return types, typed enums, typed exported node references, typed getters, and direct method calls.
- Treat avoidable `Variant`, broad engine types, unsafe inference, and reflective method calls as actionable findings.
- Refresh Godot import/class metadata before weakening an unresolved project type.
- Cast unavoidable broad API results to the concrete expected type, including node lookups and dictionary extraction.
- Permit reflection or dynamic typing only for a genuine dynamic requirement documented at the use site.
- Reference a registered `class_name` type directly. Keep `preload()` when the resource has no registered type, explicit resource loading is the intent, or a documented load-order constraint requires it.
- Follow the official GDScript style guide manually. Do not introduce a formatter, linter, Python, or gdtoolkit dependency.

## Configuration and Inspector authoring

- Apply the core configuration-cohesion and YAGNI rules to custom `Resource` fields, exported properties, nodes, physics processing, and mechanics.
- Keep Inspector authoring unambiguous. Remove duplicate, irrelevant, or competing tuning properties from changed resources and scripts.
- Put designer-owned presentation configuration in the appropriate exported property, theme, resource, or localization contract. Do not export every literal by default; keep fixed implementation details private.

## Scene authoring

If a Godot object is a stable, intentional part of the game world, author it in a `.tscn` scene. Create objects at runtime only when their existence or quantity is genuinely dynamic.

Treat stable world objects assembled through `Node.new()`, scripted child construction, or equivalent runtime setup as actionable review findings unless the code documents a genuinely dynamic reason. Do not invent gameplay folders, placeholder scenes, or architecture layers.

## Scene dependencies

- Make required cross-boundary scene dependencies explicit with concrete typed exports and wire them in the owning scene. A stable private child owned by the same scene may use a typed `%UniqueName` lookup; do not export internal details solely to avoid `%`.
- When editing `.tscn` text, serialize exported node references with Godot's `node_paths` metadata and valid `NodePath` values. Ordinary property assignment without the required metadata does not establish a valid node-reference export.
- After changing scene dependencies, verify that the project parses the scripts and can load and instantiate every affected scene. Textual inspection alone is insufficient.

## Behavioral ownership

Apply the core cohesion and state-model prompts to Godot responsibilities such as:

- An enum combines encounter, movement, attack, interruption, and reaction concepts that can vary independently.
- A script coordinates several responsibilities across AI decisions, attacks, reactions, presentation, health, timers, and physics.
- Transient runtime state such as knockback, hit-stun, feedback, or timers has no focused owner.
- Character-specific scripts own telegraph styling, strike geometry, collision configuration, or indicators that change for a different reason from character policy.

Move transient state and attack presentation to focused modules or resources when current behavior demonstrates distinct ownership. A reusable reaction seam is justified when multiple real clients, such as NPC and player combatants, require the same policy.

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

Use the repository's configured Godot test framework. Test public behavior and observable scene state; do not expose test-only Godot APIs.

For gameplay refactors, apply the core behavior-preservation rule to relevant contracts such as attack timing, interruption resistance, reactions, collision, pursuit, and presentation transitions. Do not mechanically assert this example list.

For fixtures derived from authored scenes or resources, compare expected values with the current authored source when applying the core fixture-drift rule.

Use progressive Godot feedback during Implementation:

1. Parse changed scripts.
2. Load and instantiate affected scenes, especially after changing exported node references or `.tscn` metadata.
3. Run focused behavior tests.
4. Run the full relevant Godot test suite.

When GUT is configured, use focused GUT tests for the relevant steps. Final Validation still uses the repository's documented aggregate command; the profile does not invent one.

## Stable references

- [Godot GDScript style guide](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html)
- [Godot GDScript documentation comments](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_documentation_comments.html)
- [Godot nodes and scene instances](https://docs.godotengine.org/en/stable/tutorials/scripting/nodes_and_scene_instances.html)
