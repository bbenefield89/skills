# GUT installation

## New installation

1. Detect the exact installed Godot line.
2. Inspect live GUT compatibility information, complete published releases, the candidate branch/tag, and candidate `plugin.cfg`.
3. Select a compatible published release. Pin that selected release for this project; do not encode one timeless GUT version for all future projects.
4. Include the version and primary release URL in the approval plan.
5. After download approval, fetch the release archive and extract only the required `addons/gut` content.
6. Enable the GUT editor plugin in `project.godot` while preserving all other enabled plugins.
7. Verify the installed version from vendored metadata and run `just test tests/test_gut_setup.gd`.

Do not use a search snippet, a generic latest-release label, or missing narrow documentation as negative compatibility proof.

## Existing installation

- Preserve an identifiable compatible GUT version. Upgrades require approval.
- Offer repair from the same version when known files are missing.
- Treat unknown, modified, or incompatible GUT contents as a hard conflict.
- Treat an intentionally disabled existing GUT plugin as a conflict.
- Preserve other enabled editor plugins.
- Treat another established test framework as a user decision: retain it and add GUT, retain it under an explicitly reduced setup without GUT, or migrate.

Do not use GUI or browser automation to install GUT. Vendored `addons/gut` content remains version-controlled. The vendored metadata is the durable version record; do not generate a separate testing-policy document.
