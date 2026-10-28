# GDScript standards

<!-- setup-godot-project:gdscript:start;version=2 -->
**Applies to:** All `.gd` files outside `addons/`, including tests.

> **Editing this file:** The `setup-godot-project` skill owns the text between the `setup-godot-project:gdscript` markers. The skill replaces that text when its template changes, so do not edit it. Add each project rule under [Project rules](#project-rules), below the end marker. Number project rules P1, P2, and so on. Give each project rule a statement, a Correct and an Incorrect example, and a **Checked by** line. If a project rule replaces a rule in the block, name that rule in the project rule. The project rule then applies.

Cite a rule by its number, such as "gdscript.md rule 4" or "gdscript.md rule P1".

## Rules

### 1. Static types

Give every variable, parameter, and return value an explicit type. Use `:=` only when the value on the right shows the type.

```gdscript
# Correct
var speed: float = 4.0
var timer := Timer.new()
func get_score() -> int:

# Incorrect
var speed = 4.0
var result := compute()
func get_score():
```

### 2. Concrete types

Use the most specific type that is available, not `Node`, `Object`, or `Variant`. Cast a broad result to its concrete type. Call a known method directly, not through `.call()`. Use typed methods and typed data, not mixed dictionaries.

Refer to a registered `class_name` type directly. Use `preload()` only when the resource has no registered type, or when a documented load-order constraint requires it. When a project type does not resolve, run the import again and keep the concrete type.

```gdscript
# Correct
var door: Door = get_child(0) as Door
door.open()

# Incorrect
var door: Node = get_child(0)
door.call("open")
```

Exception: a dynamic requirement that you document at the use site.

### 3. Enums for closed sets

Use a typed `enum` for a fixed set of states, not strings or integers.

```gdscript
# Correct
enum DoorState { CLOSED, OPENING, OPEN }
var state: DoorState = DoorState.CLOSED

# Incorrect
var state: String = "closed"
```

### 4. Boolean names

Start the name of each boolean variable and each boolean-returning function with `is_`, `has_`, or `can_`.

```gdscript
# Correct
var is_paused: bool = false
func has_key() -> bool:

# Incorrect
var paused: bool = false
func key() -> bool:
```

### 5. Signal names

Name each signal for an event that has already occurred, with a verb in the past tense.

```gdscript
# Correct
signal door_opened
signal score_changed(new_score: int)

# Incorrect
signal open_door
signal change_score(new_score: int)
```

### 6. Private members

Start the name of each member that other scripts must not use with `_`.

```gdscript
# Correct
var _elapsed_time: float = 0.0
func _reset_timer() -> void:

# Incorrect
var elapsed_time_internal: float = 0.0
func reset_timer_internal() -> void:
```

### 7. Style guide

Follow the official [GDScript style guide](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html) for names, member order, indentation, and blank lines. Do not add a formatter, a linter, Python, or gdtoolkit to the project.

```gdscript
# Correct
const MAX_SPEED: float = 10.0
class_name PlayerController

# Incorrect
const maxSpeed: float = 10.0
class_name player_controller
```

### 8. Class names

Give each script a unique `class_name`.

```gdscript
# Correct
class_name DoorController
extends Node3D

# Incorrect
extends Node3D
```

Exceptions: an autoload script, because a `class_name` with the same name hides the singleton, and a test script that the test framework finds by path.

### 9. Node references

Get each node that exists when you edit the scene through a typed `@export`, and assign it in the Inspector. Do not find it by name or path.

```gdscript
# Correct
@export var door: Door

# Incorrect
@onready var door: Door = $Room/Door
@onready var door: Door = %Door
@onready var door: Door = get_node("Room/Door")
```

Exception: a node that exists only at runtime, such as an instantiated child or a node that another system adds.

### 10. Exports

Export a value only when a designer tunes it. Keep one exported property for each tuning decision. Keep fixed implementation values private.

```gdscript
# Correct
@export var jump_height: float = 2.0
const _GROUND_CHECK_DISTANCE: float = 0.1

# Incorrect
@export var jump_height: float = 2.0
@export var jump_height_multiplier: float = 1.0
@export var ground_check_distance: float = 0.1
```

### 11. Documentation comments

Document with `##` comments, so that the text shows in editor hover help:

- Each script, with a header that states what it does, its responsibilities, and its single reason to change.
- Each method, including private helpers, lifecycle callbacks, and test methods.
- Each signal, with its parameters and its listener contract.
- Each named class, exported property, enum, and constant whose purpose is not obvious.

Describe behavior and contracts, not syntax. Omit a section that does not apply. Put one blank line between a documented member and the `##` comment of the next member.

```gdscript
# Correct
## Opens and closes one door.[br]
## [b]Responsibilities[/b][br]
## 1. Move the door between its states.[br]
## 2. Notify listeners after the door opens.[br]
## [b]Single reason to change[/b][br]
## The door behavior changes.
class_name DoorController
extends Node3D

## Emitted after the door is fully open.[br]
## [b]Listener contract[/b][br]
## [code]RoomLighting[/code] listens to turn on the room lights.
signal door_opened

## Time in seconds that the door takes to open.
@export var open_duration: float = 0.5

# Incorrect
# Opens doors.
class_name DoorController
extends Node3D
signal door_opened
@export var open_duration: float = 0.5
```

### 12. BBCode in comments

In `##` comments, use `[param name]`, `[member name]`, `[signal name]`, `[constant name]`, and `[code]`. Put one `[br]` at the end of a line. Do not use `[br][br]`, and do not start a line with `[br]`. Put `[br]` after each bold label.

```gdscript
# Correct
## Returns the damage after armor.[br]
## [b]Parameters[/b][br]
## [param amount] — The damage before armor.

# Incorrect
## Returns the damage after armor.[br][br]
## [br][b]Parameters[/b]
## amount — The damage before armor.
```

### 13. Readable function bodies

Make the steps of a function body easy to see. This rule changes the shape of the code, not its behavior.

- Put one blank line between the logical steps of a body, such as local setup, a group of related assignments, and each branch or loop.
- Keep the statements of one step on adjacent lines. A short body with one step needs no blank line.
- Give a condition that the body uses more than once, or that joins several comparisons, a typed local with a descriptive name.
- When branches only select one value, such as a label or a message, move the selection to a small helper that returns the value. Rule 11 applies to the helper.
- Write a statement on one line when a named value or a helper makes that possible.

```gdscript
# Correct
func _refresh() -> void:
	var is_faulted: bool = state == State.FAULT

	visible = is_faulted or state == State.RESTORING
	confirm_button.visible = is_faulted and can_recover
	message_label.text = _state_message()

	if confirm_button.visible:
		confirm_button.text = _confirm_label()
		confirm_button.grab_focus()

# Incorrect
func _refresh() -> void:
	visible = state in [
		State.FAULT,
		State.RESTORING,
	]
	confirm_button.visible = (
		state == State.FAULT and can_recover
	)
	message_label.text = reason
	if confirm_button.visible:
		confirm_button.text = "Retry" if needs_retry else "Recover"
		confirm_button.grab_focus()
```

Exception: a literal or an argument list that has no shorter form can wrap, as the style guide shows.

### 14. Runtime dependencies

Give a script each dependency that another object passes in at runtime in one place, one time.

- A class that is not a node, such as a `RefCounted` or a `Resource`, takes its dependencies as `_init()` parameters.
- A node takes its dependencies in one method named `setup()`. `instantiate()` calls `_init()` without arguments, so a node cannot use `_init()` parameters.
- `setup()` stores the dependencies and connects their signals. It asserts that it runs one time. Work that needs the node in the tree stays in `_ready()`.
- Do not add other public methods that only pass in a dependency, such as `set_session()` or `bind_settings()`.

A node that the scene contains when you edit it is not a runtime dependency. Rule 9 applies to it.

```gdscript
# Correct
func setup(session: PlayerSaveSession, audio: AudioSettings) -> void:
	assert(_session == null, "OptionsMenu receives its dependencies one time.")
	_session = session
	_audio = audio

# A class that is not a node gets its dependencies when it is created.
var store: ProfileStore = ProfileStore.new(storage)

# Incorrect
func set_session(session: PlayerSaveSession) -> void:
	_session = session

func set_audio(audio: AudioSettings) -> void:
	_audio = audio
```

### 15. Method length

Keep a method body at 12 lines or fewer. Count each line that has code. Do not count blank lines, comment lines, or the `func` line.

When a body has 13 or more lines, see whether a split makes it easier for a person or an agent to read. The goal is readability, not the limit.

- Split the body when it has separate steps that each get a clear helper name. Rule 11 applies to each helper.
- Keep the body whole when it is one flat list, such as a `match` that maps values, a `_ready()` that connects signals, or a group of assignments to one object. A split there only moves lines.
- Do not make a helper only to get below 12 lines.

### 16. One job per method

A method does the one job that its name states, at one level of detail. When a description of the method must join unrelated jobs with "and", split the method.

When a method mostly reads one object to configure another object, move that work into the other object, and give it the first object. In the example, `MenuPanels` configured the settings panel piece by piece from the session. The settings panel now does that work in its own `setup()`.

```gdscript
# Correct
# MenuPanels
func setup(session: PlayerSaveSession) -> void:
	assert(_session == null, "MenuPanels receives its save session one time.")
	_session = session

	settings.setup(session)
	settings.settings_changed.connect(_on_settings_changed)
	set_recovery_notice(session.get_recovery_notice())

# SettingsPanel
func setup(session: PlayerSaveSession) -> void:
	_show_settings(session.get_settings())
	set_write_result(session.get_last_write_error())
	session.write_completed.connect(set_write_result)

# Incorrect
# MenuPanels
func bind_save_session(session: PlayerSaveSession) -> void:
	assert(_session == null, "MenuPanels binds its save session one time.")
	_session = session
	settings.configure(session.get_settings())
	settings.set_write_result(session.get_last_write_error())
	session.write_completed.connect(settings.set_write_result)
	settings.settings_changed.connect(_on_settings_changed)
	set_recovery_notice(session.get_recovery_notice())
```

## Checked by

| Rule | Check |
|---|---|
| 1 | The Godot warning `untyped_declaration`, when `project.godot` sets it to error. Review for `:=` where the type is not visible. |
| 2 | The Godot warnings `unsafe_property_access`, `unsafe_method_access`, `unsafe_cast`, and `unsafe_call_argument`, when `project.godot` sets them to error. Review for broad types and `.call()`. |
| 3–16 | Review |

## Official documentation

Use the documentation version of the project when it is not `stable`.

- [GDScript style guide](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html)
- [GDScript exported properties](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_exports.html)
- [GDScript documentation comments](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_documentation_comments.html)
<!-- setup-godot-project:gdscript:end -->

## Project rules

None.
