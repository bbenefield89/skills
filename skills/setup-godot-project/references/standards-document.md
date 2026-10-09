# Publish the Godot standards document

Use `assets/project-template/godot-standards.md` as the fixed source for `docs/agents/godot-standards.md` in every target Godot repository. Copy the same content for new and existing projects. Do not adapt the rules to the current code or generate a deviation report.

Include the document and its pointer in the setup proposal. Retain the existing approval rules before writes.

Add this block to the repository's `AGENTS.md`, creating the file when absent:

```markdown
<!-- setup-godot-project:godot-standards:start -->
For Godot scripts, scenes, and UI, follow [docs/agents/godot-standards.md](docs/agents/godot-standards.md) when you write, clean, or review them.
<!-- setup-godot-project:godot-standards:end -->
```

Classify each artifact independently:

- **Missing:** the document or block is absent. Propose creation.
- **Current:** the document matches the template, allowing line-ending differences. No-op.
- **Outdated:** the document's marker names an earlier template version. Propose replacement with the current template and show the difference between the repository copy and the template. The user's approval of that difference authorizes the replacement; the marker alone does not.
- **Hard conflict:** the document has no marker, the current version marker with different content, or duplicate or malformed markers. Resolve the conflict before replacing that content.

Preserve unrelated AGENTS content. When a difference contains a project-specific rule, ask whether to move it to project-owned guidance before the replacement removes it. The template states that such guidance overrides the matching rule.

The document specifies GDScript typing, declarations, node references, scene authoring, UI layout and theming, Inspector configuration, and native documentation. Publishing it does not authorize code cleanup or scene changes. Those require a separate implementation or cleanup request.

Verify the document, its stable marker, the single AGENTS block, and the pointer target after writing. An unchanged repeat run must propose no documentation edits. The legacy `gdscript` AGENTS key and `docs/agents/gdscript.md` are distinct from this current artifact.

## Change a rule

Edit only the template, and raise the version in its marker by one in the same change. A rule change without a version change leaves every published copy classified as a Hard conflict.
