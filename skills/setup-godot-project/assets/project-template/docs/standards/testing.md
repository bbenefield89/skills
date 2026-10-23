# Testing standards

<!-- setup-godot-project:testing:start;version=1 -->
**Applies to:** All GDScript tests and test helpers in `tests/`.

> **Editing this file:** The `setup-godot-project` skill owns the text between the `setup-godot-project:testing` markers. The skill replaces that text when its template changes, so do not edit it. Add each project rule under [Project rules](#project-rules), below the end marker. Number project rules P1, P2, and so on. Give each project rule a statement, a Correct and an Incorrect example, and a **Checked by** line. If a project rule replaces a rule in the block, name that rule in the project rule. The project rule then applies.

Cite a rule by its number, such as "testing.md rule 3" or "testing.md rule P1". Run one test file with `just test <path>` and all tests with `just test-all`.

## Rules

### 1. Location

Put each test in `tests/`. GUT searches only that folder and its subfolders.

| Folder | Contents |
|---|---|
| `tests/unit/<feature>/` | A focused test of one feature. `<feature>` is the name of the feature folder. |
| `tests/integration/` | A test of the production composition or of more than one feature |
| `tests/regression/` | A test for a named bug |
| `tests/fixtures/` | Shared test helpers and test scenes |

```text
# Correct
tests/unit/doors/test_door_controller.gd
tests/integration/test_room_and_lighting.gd

# Incorrect
features/doors/test_door_controller.gd
```

### 2. File names

Name each test file `test_<subject>.gd`, and make it extend `GutTest`. A test script has no `class_name`, as gdscript.md rule 8 states.

```gdscript
# Correct: tests/unit/doors/test_door_controller.gd
extends GutTest

# Incorrect: tests/unit/doors/door_tests.gd
class_name DoorTests
extends GutTest
```

### 3. Test names

Name each test method `test_` followed by the expected result, as a sentence in snake case.

```gdscript
# Correct
func test_locked_door_does_not_open() -> void:

# Incorrect
func test_door() -> void:
func test_1() -> void:
```

### 4. Test comments

Start the `##` comment of each test method with "Proves". This is the test form of gdscript.md rule 11.

```gdscript
# Correct
## Proves that a locked door stays closed when the player uses it.
func test_locked_door_does_not_open() -> void:

# Incorrect
## Door test.
func test_locked_door_does_not_open() -> void:
```

### 5. Layout of a test

Put the setup, the action, and the assertions in that order. Put one blank line between the groups.

```gdscript
# Correct
func test_locked_door_does_not_open() -> void:
	var door := DoorController.new()
	door.is_locked = true

	door.use()

	assert_eq(door.state, DoorController.DoorState.CLOSED)

# Incorrect
func test_locked_door_does_not_open() -> void:
	var door := DoorController.new()
	assert_eq(door.state, DoorController.DoorState.CLOSED)
	door.is_locked = true
	door.use()
	assert_eq(door.state, DoorController.DoorState.CLOSED)
```

### 6. Public interface

Test behavior through the public methods, properties, and signals of a class. Do not call or read its private members, because a test that uses private members fails when the implementation changes but the behavior does not.

```gdscript
# Correct
door.use()
assert_eq(door.state, DoorController.DoorState.OPENING)

# Incorrect
door._start_open_animation()
assert_true(door._is_animating)
```

### 7. Bug fixes

Each bug fix adds a test that fails before the fix and passes after it. Put the test in `tests/regression/` when the bug has a name or a ticket.

```text
# Correct
1. Add tests/regression/test_door_opens_twice.gd. It fails.
2. Fix the bug. The test passes.

# Incorrect
1. Fix the bug.
2. Run the existing tests. They pass, but no test shows the bug.
```

### 8. Isolated data

A test uses disposable saves and settings in a temporary location, and removes them after the test. A test never reads or writes the data of the player.

```gdscript
# Correct
var save_path: String = "user://test_saves/door_test.json"
var store := SaveStore.new(save_path)

# Incorrect
var store := SaveStore.new(SaveStore.PLAYER_SAVE_PATH)
```

### 9. One direction

Production code never loads a file from `tests/` or from a diagnostic scene folder. Each export preset excludes these folders with `exclude_filter` in `export_presets.cfg`. When you add a test or diagnostic folder outside `tests/`, add it to each preset.

```gdscript
# Correct: production code uses only production resources.
const DOOR_SCENE: PackedScene = preload("res://features/doors/door.tscn")

# Incorrect
const DOOR_SCENE: PackedScene = preload("res://tests/fixtures/door_fixture.tscn")
```

## Checked by

| Rule | Check |
|---|---|
| 1, 2 | `just test-all` runs only files in `tests/` that match `test_*.gd`. A test in another place or with another name does not run. |
| 9 | `exclude_filter` in `export_presets.cfg`. Review for production code that loads test files. |
| 3–8 | Review |
<!-- setup-godot-project:testing:end -->

## Project rules

None.
