# Scene standards

<!-- setup-godot-project:scenes:start;version=1 -->
**Applies to:** All `.tscn` files outside `addons/`, and each script that creates or changes nodes. Agents can edit `.tscn` files as text.

> **Editing this file:** The `setup-godot-project` skill owns the text between the `setup-godot-project:scenes` markers. The skill replaces that text when its template changes, so do not edit it. Add each project rule under [Project rules](#project-rules), below the end marker. Number project rules P1, P2, and so on. Give each project rule a statement, a Correct and an Incorrect example, and a **Checked by** line. If a project rule replaces a rule in the block, name that rule in the project rule. The project rule then applies.

Cite a rule by its number, such as "scenes.md rule 3" or "scenes.md rule P1".

## Rules

### 1. Stable objects go in scenes

Put each object that always exists in a `.tscn` file. Walls, characters, cameras, spawn points, collision shapes, and persistent UI are examples. `Node.new()`, a script that builds children, and setup code in `_ready()` are signs of a departure.

```gdscript
# Correct: room.tscn contains the Door node, and the script uses it.
@export var door: Door

# Incorrect: the script builds a node that always exists.
func _ready() -> void:
	var door := Door.new()
	add_child(door)
```

Exception: an object whose existence or quantity changes at runtime, such as a projectile or one item of a data-driven list. Write the dynamic reason in a comment at that place in the code.

### 2. Repeated items are reusable scenes

Make a scene for one repeated item, such as a list card. Code instantiates one copy for each item and gives the copy its data. Code does not build the item node by node.

```gdscript
# Correct
@export var card_scene: PackedScene

func _add_card(item: InventoryItem) -> void:
	var card: ItemCard = card_scene.instantiate() as ItemCard
	card.show_item(item)
	card_list.add_child(card)

# Incorrect
func _add_card(item: InventoryItem) -> void:
	var card := PanelContainer.new()
	var title := Label.new()
	title.text = item.title
	card.add_child(title)
	card_list.add_child(card)
```

### 3. The scene holds static values

Put each value that a designer can set in the scene, in an Inspector-editable resource, or in the Theme. Sizes, spacing, alignment, text, and artwork are examples. A script does not assign such a value.

```gdscript
# Correct: the scene sets the label text and the minimum size in the Inspector.
func show_score(score: int) -> void:
	score_label.text = score_template.format({"score": score})

# Incorrect
func _ready() -> void:
	score_label.custom_minimum_size = Vector2(200, 40)
	title_label.text = "High Scores"
```

### 4. Code holds runtime state

Put data values, visibility, input, focus, and animation in the script that owns them, not in the scene.

```gdscript
# Correct: the script sets visibility from the game state.
func _on_game_paused() -> void:
	pause_panel.visible = true
	resume_button.grab_focus()

# Incorrect: the scene sets visible = true on a panel that the game state controls,
# so the panel shows before any state exists.
```

### 5. Node references in `.tscn` text

When you edit `.tscn` text, store each exported node reference with Godot's `node_paths` metadata and a valid `NodePath`. A property assignment without that metadata is not a valid node reference. This rule goes with gdscript.md rule 9.

```text
# Correct
[node name="Room" type="Node3D" node_paths=PackedStringArray("door")]
script = ExtResource("1_room")
door = NodePath("Door")

# Incorrect
[node name="Room" type="Node3D"]
script = ExtResource("1_room")
door = NodePath("Door")
```

### 6. Node names

Name each node in PascalCase for its role.

```text
# Correct
[node name="DoorHinge" type="Node3D" parent="."]

# Incorrect
[node name="Node3D2" type="Node3D" parent="."]
[node name="door_hinge" type="Node3D" parent="."]
```

### 7. No unique names

Do not mark a node as a scene unique name. A script gets the node through a typed `@export`, as gdscript.md rule 9 states, so a unique name is not necessary.

```text
# Correct
[node name="Door" type="Node3D" parent="."]

# Incorrect
[node name="Door" type="Node3D" parent="."]
unique_name_in_owner = true
```

## Checked by

| Rule | Check |
|---|---|
| 1–7 | Review |
<!-- setup-godot-project:scenes:end -->

## Project rules

None.
