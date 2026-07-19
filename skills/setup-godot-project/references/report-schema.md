# Setup report

Keep successful output concise. Include full command output only for failures or when the user requests it.

```markdown
**Setup result**

<Standard or explicitly reduced setup; concise outcome.>


**Infrastructure created or updated**

- `<path>`

  - <why it changed>


**Consolidated legacy configuration**

- <migrated or removed artifact, or None.>


**Preserved customization**

- <preserved artifact and reason, or None.>


**Dependencies**

- Godot <version and executable source>
- Just <version>
- GUT <version>


**Validation**

- `just import` — <result>
- `just test tests/test_gut_setup.gd` — <result>
- `just test-all` — <result>
- `just runtime` — passed | not applicable: no main scene
- `just validate` — <result>


**Conflicts or reduced setup**

- None.
```

When external work was selected, add concise remote and authentication state. Never claim standard setup while a required capability is missing.
