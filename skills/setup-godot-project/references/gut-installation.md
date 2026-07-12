# GUT installation

For a new installation:

1. Detect Godot major/minor compatibility.
2. Select a compatible published GUT release.
3. Include version and GitHub release URL in the approval plan.
4. After download approval, fetch the release archive and extract only required `addons/gut` content.
5. Record the version in `docs/agents/testing.md`.
6. Run the setup smoke test with `just test tests/test_gut_setup.gd`.

For an existing installation:

- Preserve an identifiable GUT version; upgrades require approval.
- Offer repair from the same version when known files are missing.
- Treat unknown or modified GUT contents as a conflict.
- Treat a different existing test framework as a user choice: retain it, add GUT, or migrate.

Use no GUI or browser automation. Vendored GUT is version-controlled.
