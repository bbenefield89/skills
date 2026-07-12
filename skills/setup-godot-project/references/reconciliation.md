# Reconciliation

Classify each target:

- **Missing:** propose creation.
- **Exact:** no-op.
- **Compatible drift:** preserve user additions and propose only unambiguous missing content.
- **Hard conflict:** show a focused difference, recommend a convention, and ask.
- **External mutation:** obtain separate explicit approval.

Detailed documents begin from templates and become user-customizable immediately. Never replace a whole existing document merely because a template changed.

Classify a project as greenfield only when it has no configured main scene, gameplay source/scenes, established test framework, or existing agent infrastructure. Classify it as brownfield when any of those signals exists. Ask the user when the evidence conflicts or is ambiguous.

Every detailed template carries a stable `setup-godot-project:template=<name>;version=1` marker and logical `section=<name>` markers. Use these markers only to identify prior template intent; they never authorize overwriting user content.

`AGENTS.md` uses independently managed markers:

```markdown
<!-- setup-godot-project:<key>:start -->
...
<!-- setup-godot-project:<key>:end -->
```

Each key occurs at most once. Preserve unrelated content byte-for-byte. Duplicate/malformed markers or contradictory unmarked guidance are hard conflicts.

Add only universal generated/editor output to `.gitignore`; keep assets, imported source files, tests, and vendored GUT tracked.

For new projects, enable applicable strict GDScript warnings supported by the detected Godot major/minor. For existing projects, measure parsing impact narrowly and ask before tightening.
