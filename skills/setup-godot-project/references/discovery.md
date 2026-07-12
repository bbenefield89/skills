# Read-only discovery

Inspect:

- `project.godot`, Godot major/minor, configured main scene, and relevant warning settings.
- Git state, history, branches, remotes, `.gitignore`, `AGENTS.md`, and `CLAUDE.md`.
- `docs/agents`, `Justfile`, tests, test framework, and `addons/gut`.
- Godot CLI, Git, `just`, `$deliver`, and every default adapter.
- GitHub CLI/auth only when GitHub work is selected.

The canonical skill source is `C:\Users\bsqua\source\repos\skills\skills\`. For each missing required adapter, name its source folder and offer installation through the available `$skill-installer` workflow. Verify availability again after installation. Do not emit bindings to a missing adapter unless the user explicitly approves reduced setup.

If `just` is missing, detect OS and an available package manager and propose the exact installation command. If Godot is not on `PATH`, inspect common locations and report the executable found; offer either an approved persistent PATH update or a repository-specific `GODOT`/Justfile override.

Do not scan gameplay code for hygiene, architecture, or debt. In an existing project, inspect only enough source to measure whether proposed warning settings parse.
