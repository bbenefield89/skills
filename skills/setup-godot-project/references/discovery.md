# Read-only discovery

Inspect only setup-owned infrastructure:

- `project.godot`, exact Godot version evidence, configured main scene, enabled editor plugins, and relevant warning settings.
- Godot CLI, Just, and Git availability.
- Git state, remotes, `.gitignore`, `AGENTS.md`, `CLAUDE.md`, and setup-owned managed markers.
- `Justfile`, `justfile`, and other case variants; required recipes and their actual expansion through `just --list`, `just --summary`, or `just --dump`.
- Tests, configured test frameworks, `addons/gut`, GUT `plugin.cfg`, and identifiable installed version.
- Recognized legacy setup-godot-project policy documents and AGENTS blocks listed in reconciliation.
- Availability of `$setup-matt-pocock-skills` when issue-tracking/domain setup is selected or legacy ownership must be transferred.
- GitHub CLI and authentication only when GitHub work is selected.

Do not infer that a missing search result proves incompatibility. For GUT selection, inspect the exact Godot line, live compatibility data, release/tag metadata, `plugin.cfg`, and complete published releases.

If Just is missing, detect the operating system and an available package manager, then propose the exact installation command for approval. Because the repository validation interface depends on Just after standard setup, stopping or an explicitly approved reduced setup are the only choices when installation is declined.

If Godot is not on `PATH`, inspect common installation locations and report the executable found. Offer either an explicitly approved persistent `PATH` update or a repository-specific `GODOT` environment override/Justfile default. Never modify `PATH` silently.

Treat Git remote configuration and GitHub CLI authentication as separate states. Invalid GitHub authentication blocks only approved external GitHub mutations, not local setup.

When `$setup-matt-pocock-skills` is required but unavailable, name the missing workflow and offer installation through the available skill-installation mechanism. Do not emit substitute tracker/domain guidance. Preserve existing owning-workflow artifacts and require explicit approval before continuing with only the independent Godot infrastructure steps.

Do not scan gameplay code for hygiene, architecture, quality debt, or baseline violations. For existing projects, inspect only enough source to measure whether proposed warning settings parse.
