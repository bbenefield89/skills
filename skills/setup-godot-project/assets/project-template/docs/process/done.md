# Definition of done

<!-- setup-godot-project:done:start;version=1 -->
**Applies to:** Each change, before an agent says that it is complete.

> **Editing this file:** The `setup-godot-project` skill owns the text between the `setup-godot-project:done` markers. The skill replaces that text when its template changes, so do not edit it. Add each project rule under [Project rules](#project-rules), below the end marker. Number project rules P1, P2, and so on. Give each project rule a statement, a Correct and an Incorrect example, and a **Checked by** line. If a project rule replaces a rule in the block, name that rule in the project rule. The project rule then applies.

Cite a rule by its number, such as "done.md rule 1" or "done.md rule P1".

## Rules

### 1. Focused tests first

While you work, run the tests for the area that you changed with `just test <path>`.

```text
# Correct
just test tests/unit/doors/test_door_controller.gd

# Incorrect
Run only just validate at the end, so each failure takes a full run to find.
```

### 2. Full validation

Run `just validate` before you say that a change is complete. It must pass.

```text
# Correct
just validate: pass.

# Incorrect
The focused tests pass, so the change is complete.
```

### 3. Tests for new behavior

New behavior has tests, as `docs/standards/testing.md` states. A bug fix has a test that failed before the fix.

```text
# Correct
The change adds test_locked_door_does_not_open, and it passes.

# Incorrect
The change adds the lock behavior, and no test covers it.
```

### 4. Standards

The changed files follow the standards in `docs/standards/` and `docs/architecture/` that apply to them, including the project rules.

```text
# Correct
Review the changed .gd files against gdscript.md and fix each departure.

# Incorrect
Leave an untyped variable because the change works.
```

### 5. UI checks

For a UI change, check the layout at each size that `docs/standards/ui.md` lists.

```text
# Correct
Each listed size: checked with the preview scene.

# Incorrect
Checked at one size only.
```

### 6. Documents

Update each document that the change makes incorrect: the [System map](../architecture/overview.md#system-map), the [Folder map](../architecture/file-layout.md#folder-map), the tables in `docs/standards/ui.md`, and the decision records. Do not edit text inside a skill-owned block. Add a project rule below the block.

```text
# Correct
The change adds the Rewards feature and adds rows to the System map and the Folder map.

# Incorrect
The change adds the Rewards feature, and the maps do not show it.
```

### 7. Only the requested change

The change contains only what the ticket or the user asked for. Report other problems that you find, and do not fix them in the same change.

```text
# Correct
Report: "test_pause_service.gd has an unrelated flaky test."

# Incorrect
Rewrite the pause tests in the same change as a layout fix.
```

### 8. Honest report

In the final report, give each command that you ran and its result. State each check that you did not do, as "not checked", with the reason.

```text
# Correct
just validate: pass. UI sizes: not checked, because no display was available.

# Incorrect
All checks pass.   (The UI sizes were not checked.)
```

## Checked by

| Rule | Check |
|---|---|
| 1, 2 | `just test <path>` and `just validate` |
| 3–8 | Review |
<!-- setup-godot-project:done:end -->

## Project rules

None.
