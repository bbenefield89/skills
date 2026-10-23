# UI standards

<!-- setup-godot-project:ui:start;version=1 -->
**Applies to:** All player UI scenes, UI scripts, and the shared Theme.

> **Editing this file:** The `setup-godot-project` skill owns the text between the `setup-godot-project:ui` markers. The skill replaces that text when its template changes, so do not edit it. Add each project rule under [Project rules](#project-rules), below the end marker. Number project rules P1, P2, and so on. Give each project rule a statement, a Correct and an Incorrect example, and a **Checked by** line. If a project rule replaces a rule in the block, name that rule in the project rule. The project rule then applies. Keep the tables in [Reference](#reference) current.

Cite a rule by its number, such as "ui.md rule 2" or "ui.md rule P1". The [Reference](#reference) section lists the shared Theme, its type variations, the layout check sizes, and the scripts that can set layout values.

## Rules

### 1. Native layout first

Use anchors, containers, size flags, and minimum and maximum sizes for layout. Write layout code only for a limitation that native Control nodes cannot solve. Write the limitation in a comment next to the code, and add the script to [Layout code exceptions](#layout-code-exceptions).

```gdscript
# Correct: the scene uses a VBoxContainer with separation and size flags.
# The script only fills the list.
func show_items(items: Array[InventoryItem]) -> void:
	for item: InventoryItem in items:
		item_list.add_child(_make_row(item))

# Incorrect: the script places each row.
func _layout_rows() -> void:
	for index: int in item_list.get_child_count():
		var row: Control = item_list.get_child(index) as Control
		row.position = Vector2(0, index * 48)
```

### 2. One shared Theme

The project has one shared Theme. The `gui/theme/custom` project setting makes it the default, so every control gets it automatically. [Shared Theme](#shared-theme) gives its path. A scene does not assign a Theme and does not override a font, color, or style.

```text
# Correct
[node name="Title" type="Label" parent="."]
theme_type_variation = &"HeadingLabel"
text = "Settings"

# Incorrect
[node name="Title" type="Label" parent="."]
theme = ExtResource("2_menu_theme")
theme_override_colors/font_color = Color(1, 0.4, 0.6, 1)
theme_override_font_sizes/font_size = 32
text = "Settings"
```

### 3. Special appearance through type variations

For a special appearance, set a named type variation from the shared Theme. If no variation fits, add a new variation to the shared Theme and to [Theme type variations](#theme-type-variations).

```text
# Correct
[node name="Hint" type="Label" parent="."]
theme_type_variation = &"FinePrintLabel"

# Incorrect
[node name="Hint" type="Label" parent="."]
theme_override_font_sizes/font_size = 12
```

### 4. Scripts do not style

A script can read the Theme. It does not change the Theme, and it does not set a font, color, or style.

```gdscript
# Correct: the scene sets the variation, and the script changes only the state.
func set_locked(is_locked: bool) -> void:
	unlock_button.disabled = is_locked

# Incorrect
func set_locked(is_locked: bool) -> void:
	unlock_button.add_theme_color_override("font_color", Color.GRAY)
```

Exception: a style that runtime state selects, which no type variation can express. Write the reason in a comment next to the code.

### 5. Wording lives in scenes

The scene holds each message as a template with named placeholders, such as `{name}`. Code selects the template for a state and supplies the values. The code that owns a state reports a typed cause and holds no wording.

```gdscript
# Correct: the scene sets found_template = "You found {name}!" in the Inspector.
@export var found_template: String

func show_found(item: InventoryItem) -> void:
	message_label.text = found_template.format({"name": item.title})

# Incorrect
func show_found(item: InventoryItem) -> void:
	message_label.text = "You found " + item.title + "!"
```

### 6. No words in artwork

Production artwork has no words, so a designer can edit all text in a Label. A project rule can name an exception, such as a logo.

```text
# Correct: a wordless button background, with the text in the Button.
[node name="PlayButton" type="Button" parent="."]
text = "Play"

# Incorrect: the word is part of the texture.
[node name="PlayButton" type="TextureButton" parent="."]
texture_normal = ExtResource("3_play_button_with_text")
```

### 7. Layout check

Check each UI change at each size in [Layout check sizes](#layout-check-sizes). Set each size with a tool or a preview scene. Do not resize the window by hand, because a hand-resized window does not give repeatable sizes.

```text
# Correct
Open the preview scene and select each listed size with its controls.

# Incorrect
Drag the window edge until the UI looks narrow.
```

## Checked by

| Rule | Check |
|---|---|
| 1–6 | Review |
| 7 | The result for each size in the change report |
<!-- setup-godot-project:ui:end -->

## Project rules

None.

## Reference

### Shared Theme

Not created yet.

### Layout check sizes

| Size | Reason |
|---|---|

### Theme type variations

| Variation | Base | Use |
|---|---|---|

### Layout code exceptions

Each script below sets a layout value or a presentation value because of the limitation in its row.

| Script | Requirement and native limitation | Settings in the scene |
|---|---|---|
