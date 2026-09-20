# Publish the architecture document

Use `assets/project-template/godot-architecture.md` as the fixed source for `docs/agents/godot-architecture.md` in every target Godot repository. Copy the same content for new and existing projects. Do not substitute a description of the current layout or generate a deviation report.

Include the document and its pointer in the setup proposal. Retain the existing approval rules before writes.

Add this block to the repository's `AGENTS.md`, creating the file when absent:

```markdown
<!-- setup-godot-project:godot-architecture:start -->
For Godot implementation, file placement, and review, follow [docs/agents/godot-architecture.md](docs/agents/godot-architecture.md).
<!-- setup-godot-project:godot-architecture:end -->
```

Classify each artifact independently. Missing artifacts require creation. An exact template match, allowing line-ending differences, is Current. Preserve unrelated AGENTS content. Duplicate or malformed markers, modified generated text, or contradictory guidance require focused conflict resolution before replacing that content.

The document specifies feature ownership, responsibility-based folders, deep modules, public contracts, and feature-local tests plus root-level integration and regression checks. Publishing it does not authorize gameplay file moves or code refactors. Those require a separate implementation request.

Verify the document, its stable marker, the single AGENTS block, and the pointer target after writing. An unchanged repeat run must propose no documentation edits. The legacy `architecture` AGENTS key and `docs/agents/architecture.md` are distinct from this current artifact.
