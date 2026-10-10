# Publish the architecture document

Use `assets/project-template/godot-architecture.md` as the fixed source for `docs/agents/godot-architecture.md` in every target Godot repository. Copy the same content for new and existing projects. Do not substitute a description of the current layout or generate a deviation report.

Include the document and its pointer in the setup proposal. Retain the existing approval rules before writes.

Add this block to the repository's `AGENTS.md`, creating the file when absent:

```markdown
<!-- setup-godot-project:godot-architecture:start -->
For Godot implementation, file placement, and review, follow [docs/agents/godot-architecture.md](docs/agents/godot-architecture.md).
<!-- setup-godot-project:godot-architecture:end -->
```

Classify each artifact independently:

- **Missing:** the document or block is absent. Propose creation.
- **Current:** the document matches the template, allowing line-ending differences. No-op.
- **Outdated:** the document's marker names an earlier template version. Propose replacement with the current template and show the difference between the repository copy and the template. The user's approval of that difference authorizes the replacement; the marker alone does not.
- **Hard conflict:** the document has no marker, the current version marker with different content, or duplicate or malformed markers. Resolve the conflict before replacing that content.

Preserve unrelated AGENTS content.

The document specifies feature ownership, responsibility-based folders, deep modules, public contracts, and tests under root `tests/`, with a feature's focused tests in `tests/unit/<feature>/`. Publishing it does not authorize gameplay file moves or code refactors. Those require a separate implementation request.

Verify the document, its stable marker, the single AGENTS block, and the pointer target after writing. An unchanged repeat run must propose no documentation edits. The legacy `architecture` AGENTS key and `docs/agents/architecture.md` are distinct from this current artifact.

## Change a rule

Edit only the template, and raise the version in its marker by one in the same change. A rule change without a version change leaves every published copy classified as a Hard conflict.
