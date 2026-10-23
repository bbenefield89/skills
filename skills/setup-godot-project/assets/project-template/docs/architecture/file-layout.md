# File layout

<!-- setup-godot-project:file-layout:start;version=1 -->
**Applies to:** Each file that an agent adds, moves, or renames, outside `addons/`. Do not move or rename an existing file only to follow these rules. A folder migration needs its own request.

> **Editing this file:** The `setup-godot-project` skill owns the text between the `setup-godot-project:file-layout` markers. The skill replaces that text when its template changes, so do not edit it. Add each project rule under [Project rules](#project-rules), below the end marker. Number project rules P1, P2, and so on. Give each project rule a statement, a Correct and an Incorrect example, and a **Checked by** line. If a project rule replaces a rule in the block, name that rule in the project rule. The project rule then applies. Keep the [Folder map](#folder-map) current.

Cite a rule by its number, such as "file-layout.md rule 2" or "file-layout.md rule P1". The [Folder map](#folder-map) at the end lists each top-level folder of this project and what it holds.

## Rules

### 1. Place by owner

Put each file in the folder of the system that owns it. Choose by the responsibility of the file, not by its base class or its extension. Keep the scenes, scripts, resources, and UI of one feature together.

```text
# Correct
features/rewards/reward_rules.gd
features/rewards/ui/reward_popup.tscn

# Incorrect
scripts/reward_rules.gd
scenes/reward_popup.tscn
```

### 2. Scene and script together

Keep the main script of a scene in the same folder as the scene, with the same base name.

```text
# Correct
features/rewards/ui/reward_popup.tscn
features/rewards/ui/reward_popup.gd

# Incorrect
features/rewards/ui/reward_popup.tscn
features/rewards/scripts/popup_logic.gd
```

### 3. File and folder names

Name each file and each folder in snake_case, as the GDScript style guide states. The file name of a script matches its `class_name` in snake_case.

```text
# Correct
reward_popup.gd   (class_name RewardPopup)

# Incorrect
RewardPopup.gd
rewardPopup.gd
```

### 4. Entities and features

An entity is an object in the game world, such as a player, a door, or a prop. A feature is a system or an activity, such as fishing, collecting, or dialogue. Put an entity in `entities/` and a feature in `features/`. A physical object that a system uses stays an entity. The rules of a system stay in its feature, even when only one entity uses them.

```text
# Correct
entities/door/door.tscn
features/locks/lock_rules.gd

# Incorrect: the lock rules are in the entity because only doors use them now.
entities/door/lock_rules.gd
```

### 5. UI placement

Put the UI of one feature in `features/<feature>/ui/`. Put only game-wide UI, such as the HUD, menus, and the shared Theme, in the root `ui/` folder. UI asks a feature to do an operation through the feature's contract. The game rules stay in the feature.

```text
# Correct
features/rewards/ui/reward_popup.tscn
ui/common/confirm_dialog.tscn

# Incorrect
ui/reward_popup.tscn
```

### 6. Resources with their definition

Keep a Resource script and its `.tres` instances together in the `resources/` folder of the owner. A resource that several features use still has one owner. Put a shared authored dataset, such as an item catalog, in `data/<domain>/`.

```text
# Correct
features/dialogue/resources/dialogue_line.gd
features/dialogue/resources/greeting.tres

# Incorrect
data/greeting.tres
scripts/resources/dialogue_line.gd
```

### 7. Standard folders

Use these top-level folders. Create a folder only when a file needs it.

| Folder | Holds |
|---|---|
| `features/<feature>/` | Game systems: their scenes, scripts, exclusive resources, and UI |
| `entities/<kind>/` | Objects in the game world, with their scenes, scripts, and exclusive resources |
| `levels/<location>/` | Playable locations and their authored composition |
| `scenes/<composition>/` | Game-wide composition scenes and their scripts, such as `scenes/main/main.tscn` |
| `ui/<responsibility>/` | Game-wide HUD, menus, shared presentation, and themes |
| `app/bootstrap/` | Startup helpers that are not the script of a scene |
| `app/autoload/` | Application-wide services that Godot registers as autoloads |
| `app/config/` | Application configuration and input registration |
| `core/<responsibility>/` | Primitives and types that have no game owner and no game rules |
| `data/<domain>/` | Shared authored datasets |
| `persistence/<responsibility>/` | Save and load boundaries, serializers, migrations, and stored-data models |
| `assets/<kind>/` | Passive art, audio, fonts, materials, shaders, and animation that more than one feature uses |
| `tests/` | All tests. See `docs/standards/testing.md`. |
| `docs/` | Standards, architecture, process, and decision records |
| `addons/` | Third-party add-ons |

```text
# Correct
scenes/main/main.tscn
levels/harbor/harbor.tscn

# Incorrect: a playable location in the composition folder.
scenes/harbor.tscn
```

### 8. No empty folders

Create a folder only when a real file needs it. A folder does not justify a new system, autoload, or interface.

```text
# Correct
Create features/rewards/ in the same change that adds reward_rules.gd.

# Incorrect
Create features/rewards/, features/quests/, and features/shop/ for future work.
```

### 9. Safe file moves

When you move or rename a file:

1. Move its `.uid` and `.import` sidecar files with it.
2. Update each reference: scenes, resources, project settings, `Justfile` paths, export filters, tests, and current documents.
3. Keep node names, serialized node references, UIDs, and saved-data identities.
4. Run `just import`, the focused tests, and then `just validate`.

```text
# Correct
git mv features/doors/door.gd entities/door/door.gd
git mv features/doors/door.gd.uid entities/door/door.gd.uid

# Incorrect
git mv features/doors/door.gd entities/door/door.gd
(The .uid file stays in the old folder, and the UID reference breaks.)
```

## Checked by

| Rule | Check |
|---|---|
| 9 | `just import` and `just validate` find broken references. |
| 1–8 | Review |
<!-- setup-godot-project:file-layout:end -->

## Project rules

None.

## Folder map

| Folder | Holds |
|---|---|
