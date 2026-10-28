<!-- setup-godot-project:template=godot-standards;version=1 -->
# Godot standards

Apply this standard when writing, cleaning, or reviewing project-owned Godot scripts, scenes, and resources. Use the same rules across projects.
Exclude vendored dependencies such as GUT.
GD1, GD2, and GD7 apply to GDScript. The other rules apply to GDScript and C#.

The rules are defaults.
Explicit user instructions override them.
A project-specific exception recorded in project-owned guidance overrides the matching rule. Record it there rather than changing this universal standard.
Godot permits the alternatives, so each rule is policy rather than an engine restriction.
Check engine APIs against the project's Godot version.
Cite a rule by its ID, such as `GD3`.

Setup publishes this fixed document and its `AGENTS.md` pointer. It does not inspect or change project code.

## GD1. Typed GDScript

- Prefer concrete project types to `Node`, `Object`, and other broad engine types.
- Give locals, parameters, and return values explicit types in place of avoidable `Variant` inference and loose `:=`.
- Use typed enums for closed sets of states.
- Prefer typed getters and stable interfaces to mixed dictionaries.
- Call known typed methods directly. A reflective `.call()` hides the contract.
- Cast an unavoidable broad result to its concrete type. Node lookups and dictionary extraction are examples.
- Reference a registered `class_name` type directly. Keep `preload()` when the resource has no registered type, explicit resource loading is the intent, or a documented load-order constraint requires it.
- When a project type does not resolve, refresh the Godot import and class metadata and keep the concrete type.
- Apply the official GDScript style guide by hand. These standards need no formatter, linter, Python, or gdtoolkit dependency, so add none.

Exception: a genuine dynamic requirement, documented at the use site, permits reflection or dynamic typing.

## GD2. Declarations

Give each project-owned `.gd` file a unique `class_name`.
A named class gives other scripts a concrete type for exports, casts, and static typing.
Exceptions: an autoload script whose name would hide its singleton, and a test script that the test framework finds by path.

Put one blank line between a documented member and the `##` comment of the next member:

```gdscript
## Anchor that sets where the model stands on the pedestal.
@export var model_anchor: Node3D

## Material that replaces every model material while the design appears as a silhouette.
@export var silhouette_material: Material
```

Related declarations that share one comment or have no comments can stay on adjacent lines.

## GD3. Node references

Reference an edit-time node through a typed export that the owning scene assigns in the Inspector.
Use `@export var player: PlayerController` in GDScript and `[Export]` in C#.
Export the node type in place of a `NodePath` plus a runtime lookup.
Lookups by name or path include `%UniqueName`, `$Path`, `get_node()`, `find_child()`, and `GetNode()`.
Exception: a node whose existence, identity, or quantity is known only at runtime.
An instantiated child and a node that another system adds are examples.

In `.tscn` text, serialize an exported node reference with Godot's `node_paths` metadata and a valid `NodePath` value.
A property assignment without that metadata is not a valid node-reference export.

## GD4. Scene authoring

Author a stable, intentional object in a `.tscn` scene.
Stable walls, authored characters, cameras, spawn points, collision geometry, and persistent UI are examples.
Author stable UI structure, fixed copy, spacing, dimensions, and artwork in scenes and Inspector-editable resources.
Keep runtime state, data values, visibility, input, focus, and animation in the code that owns them.
`Node.new()`, scripted child assembly, and presentation setup in `_ready()` are the usual signs of a departure.

Exception: an object whose existence or quantity is dynamic.
Projectiles, procedural enemies, generated terrain, pooled effects, and data-driven lists are examples.
Instantiating an authored scene for each item of a variable list is a valid dynamic use.
When code builds an object that looks stable, document the dynamic reason at that site.

## GD5. UI layout and theming

Use `Control` anchors, containers, size flags, and minimum sizes for ordinary UI layout.
Use a Theme resource, a theme type variation, or an Inspector theme override for stable styling.
Code that repeatedly calculates positions or dimensions is the usual sign of a layout departure.
Code that sets colors, fonts, StyleBoxes, or `add_theme_*_override` values is the usual sign of a styling departure.
Exceptions: a custom `Container`, animation, safe-area adaptation, a layout that native containers cannot express, and styling that runtime state selects.

## GD6. Inspector configuration

Export a value when a designer tunes it. Keep fixed implementation details private.
Put designer-owned presentation configuration in the fitting exported property, theme, resource, or localization contract.
Keep one property for each tuning decision. Remove duplicate, irrelevant, and competing properties from changed resources and scripts.

## GD7. Native documentation

Write documentation as native `##` comments so that it shows in editor hover help.
Document every project-owned script, including tests:

- Begin each script with a header that briefly explains what it does, enumerates its responsibilities, and states its single reason to change.
- Document every method, including private helpers, lifecycle callbacks, and test methods.
- Document every signal.
- Document named classes, exported properties, enums, and non-obvious constants.

Describe behavior, parameters, return value, side effects, emitted signals, preconditions, failure behavior, or the listener contract, as applicable. Omit sections that genuinely do not apply.
Explain intent and contracts rather than syntax.

Use Godot BBCode that renders correctly in hover help: `[param name]`, `[member]`, `[constant]`, `[signal]`, and `[code]`.

- Use a single `[br]` at the end of the preceding content line.
- Never use `[br][br]`.
- Never begin a documentation line with `[br]`.
- Put `[br]` after bold section labels.

Signal example:

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

## Official references

Use the project's documentation version when it differs from `stable`.

- [GDScript style guide](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html): Declaration order and blank-line conventions.
- [GDScript exported properties](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_exports.html): Typed node exports assigned in the Inspector.
- [GDScript documentation comments](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_documentation_comments.html): Native `##` syntax and BBCode tags.
- [Nodes and scene instances](https://docs.godotengine.org/en/stable/tutorials/scripting/nodes_and_scene_instances.html): Node references and scene instancing.
- [Scene organization](https://docs.godotengine.org/en/stable/tutorials/best_practices/scene_organization.html): Scene dependencies and ownership.
- [Using Containers](https://docs.godotengine.org/en/stable/tutorials/ui/gui_containers.html): Native sizing and positioning, including custom containers.
- [Size and anchors](https://docs.godotengine.org/en/stable/tutorials/ui/size_and_anchors.html): Native layout across parent sizes.
- [Introduction to GUI skinning](https://docs.godotengine.org/en/stable/tutorials/ui/gui_skinning.html): Theme resources, type variations, and local overrides.
