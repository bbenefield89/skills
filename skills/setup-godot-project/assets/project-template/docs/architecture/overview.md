# Architecture overview

<!-- setup-godot-project:overview:start;version=1 -->
**Applies to:** Each system in the game: its owner, its contract, and its dependencies. For the folder of each file, see `docs/architecture/file-layout.md`.

> **Editing this file:** The `setup-godot-project` skill owns the text between the `setup-godot-project:overview` markers. The skill replaces that text when its template changes, so do not edit it. Add each project rule under [Project rules](#project-rules), below the end marker. Number project rules P1, P2, and so on. Give each project rule a statement, a Correct and an Incorrect example, and a **Checked by** line. If a project rule replaces a rule in the block, name that rule in the project rule. The project rule then applies. Keep the [System map](#system-map) current.

Cite a rule by its number, such as "overview.md rule 2" or "overview.md rule P1". The [System map](#system-map) at the end lists each system, its location, and what it owns.

## Rules

### 1. One owner for each state

Each piece of mutable state has one owner. Other code asks the owner to change the state through the owner's contract.

```gdscript
# Correct
inventory.add_item(key)

# Incorrect: a second system changes the state of the owner directly.
inventory.items.append(key)
```

### 2. Contracts, not internals

Systems communicate through public methods, signals, and typed data or resources. A system does not use the private members or the internal nodes of another system.

```gdscript
# Correct
vehicle.engine_failed.connect(_on_engine_failed)
var fuel: float = vehicle.get_fuel_level()

# Incorrect
var fuel: float = vehicle.get_node("Engine/FuelTank").amount
vehicle._engine.stop()
```

### 3. Composition wires dependencies

A composition scene, such as `scenes/main.tscn`, gives each system its dependencies through typed exports or an `initialize()` call. A system does not search the scene tree, a group, or a global registry for a dependency.

```gdscript
# Correct
@export var pause_service: PauseService

# Incorrect
var pause_service: PauseService = get_tree().root.find_child("PauseService", true, false) as PauseService
```

### 4. Dependency direction

- A composition scene can depend on any system. No system depends on a composition scene.
- UI depends on the contracts of features and entities. Features and entities do not depend on UI.
- A physical entity does not depend on the systems that use it. For example, a door has no dependency on the system that locks it.
- Code in `core/` does not depend on any game folder.

```gdscript
# Correct: the menu reads the feature.
class_name ScoreView
extends Control
@export var scoreboard: Scoreboard

# Incorrect: the feature reads the menu.
class_name Scoreboard
extends Node
@export var score_view: ScoreView
```

### 5. Deep modules

Put substantial behavior behind a small public contract. In the `##` header of the script, document what callers need: inputs, outputs, state changes, emitted signals, and failure behavior. Keep helpers, node paths, and mutable details private.

```gdscript
# Correct: one call does the full job.
func open_with(key: Key) -> bool:

# Incorrect: the caller must know the internal order of steps.
func check_key(key: Key) -> void:
func release_latch() -> void:
func swing_open() -> void:
func play_open_sound() -> void:
```

### 6. No speculative structure

Do not add an event bus, a generic router, an empty service class, or an interface that no current code needs. Application-wide scope alone does not make a system an autoload. Keep the lifetime that the owning scene gives a system.

```text
# Correct
A pause service is a node in the Gameplay scene, and the scene passes it to each user.

# Incorrect
Add an EventBus autoload so that any script can send a "paused" event.
```

### 7. Record decisions and update the map

When you make a decision that is hard to reverse, add a record in `docs/architecture/decisions/`. When you add a system, remove a system, or change an owner, update the [System map](#system-map).

```text
# Correct
The change adds features/rewards/. The same change adds a Rewards row to the map.

# Incorrect
The change adds features/rewards/. The map does not show it.
```

## Checked by

| Rule | Check |
|---|---|
| 1–7 | Review |
<!-- setup-godot-project:overview:end -->

## Project rules

None.

## System map

| System | Location | Owns |
|---|---|---|
