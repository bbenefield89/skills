# Godot profile

Load this profile when the repository contains `project.godot`, GDScript, Godot scenes/resources, or equivalent explicit Godot guidance.

Apply these rules to changed project-owned Godot code and directly affected interfaces. Exclude vendored dependencies such as GUT.

## Godot standards

Use the repository's `docs/agents/godot-standards.md`, read during preflight. Apply every applicable rule during both Implementation and Standards review. In this workflow, a departure in changed code or a directly affected interface is an actionable finding rather than an optional recommendation.

If the document is absent, state that limit in the completion report. Continue with this profile, other repository guidance, and official Godot documentation for the project's engine version.

## Repository architecture

Read the repository architecture document identified during preflight. Use its vertical-slice placement rules and deep-module contracts during implementation and review. Keep each feature's scenes, scripts, resources, assets, and UI together as the document requires. Put tests where the document requires. Keep test discovery aligned with the document and preserve the configured test framework and public validation commands.

Review changes for clear ownership and simple public methods, signals, and data contracts. Folder moves alone do not establish deep modules. Keep a behavior-preserving migration limited to files and references unless the request separately authorizes changes to state ownership or public contracts.

Update project-specific architecture documentation when an approved change alters a documented contract. Treat the generated universal standard as policy: change it only when the user explicitly authorizes a policy change. Do not rewrite it to match legacy structure or introduce a new convention for one implementation.

## Configuration and scenes

- Apply the core configuration-cohesion and YAGNI rules to custom `Resource` fields, exported properties, nodes, physics processing, and mechanics.
- Do not invent gameplay folders, placeholder scenes, or architecture layers.
- After changing scene dependencies, verify that the project parses the scripts and can load and instantiate every affected scene. Textual inspection alone is insufficient.

## Behavioral ownership

Apply the core cohesion and state-model prompts to Godot responsibilities such as:

- An enum combines encounter, movement, attack, interruption, and reaction concepts that can vary independently.
- A script coordinates several responsibilities across AI decisions, attacks, reactions, presentation, health, timers, and physics.
- Transient runtime state such as knockback, hit-stun, feedback, or timers has no focused owner.
- Character-specific scripts own telegraph styling, strike geometry, collision configuration, or indicators that change for a different reason from character policy.

Move transient state and attack presentation to focused modules or resources when current behavior demonstrates distinct ownership. A reusable reaction seam is justified when multiple real clients, such as NPC and player combatants, require the same policy.

## Tests

Use the repository's configured Godot test framework. Test public behavior and observable scene state; do not expose test-only Godot APIs.

For gameplay refactors, apply the core behavior-preservation rule to relevant contracts such as attack timing, interruption resistance, reactions, collision, pursuit, and presentation transitions. Do not mechanically assert this example list.

For fixtures derived from authored scenes or resources, compare expected values with the current authored source when applying the core fixture-drift rule.

Use progressive Godot feedback during Implementation:

1. Parse changed scripts.
2. Load and instantiate affected scenes, especially after changing exported node references or `.tscn` metadata.
3. Run focused behavior tests.
4. Run the full relevant Godot test suite.

When GUT is configured, use focused GUT tests for the relevant steps. Final Validation still uses the repository's documented aggregate command; the profile does not invent one.
