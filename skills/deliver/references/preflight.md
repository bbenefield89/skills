# Delivery preflight

Complete preflight before editing:

1. Confirm an authoritative implementation request exists.
2. Extract concrete acceptance criteria. Ask when required behavior is ambiguous or contradictory.
3. Read repository guidance and identify its precedence relative to the current request.
4. Record the initial staged, unstaged, and untracked non-ignored worktree.
5. Identify unrelated existing changes and any overlap with the requested work.
6. Detect applicable technology profiles from repository evidence.
7. Discover focused test commands and the repository's final validation command.
8. Verify only the tools required by the selected implementation and validation path.
9. Confirm any requested external mutation. Commit and push authority default to false.

Profile evidence may include manifests, project files, file extensions, framework configuration, and repository guidance. Load every clearly applicable profile in a mixed-technology repository. When evidence is ambiguous or no profile exists, use the core standard plus repository guidance and ask before inventing technology-specific rules.

Validation-command discovery is repository-driven, not profile-driven. A missing final validation command does not block implementation and must not trigger another setup skill. Continue and finish as Unverified if implementation and review otherwise pass.

Preflight outcomes:

- **Ready:** scope, authority, change ownership, tools, and commands are sufficiently known.
- **Ready with unverified finish:** implementation can proceed, but no adequate final validation command exists.
- **Blocked:** unresolved scope, authority, overlap, conflict, or missing required implementation tool prevents safe work.

Do not treat missing optional tooling or absent project setup automation as a blocker.
