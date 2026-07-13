---
name: setup-godot-project
description: Configures or reconciles universal delivery guidance, GUT tests, Just recipes, and validation infrastructure in new or existing Godot projects. Use when a directory containing project.godot needs the standard Godot agent workflow or when $deliver reports missing project guardrails.
---

# Set Up a Godot Project

Configure only universal infrastructure. Do not invent gameplay structure or audit gameplay quality.

## 1. Discover read-only

Require `project.godot`. Read [references/discovery.md](references/discovery.md), inspect every listed prerequisite and repository artifact, and classify missing items, compatible drift, and hard conflicts. Do not write during discovery.

Invoke `$setup-matt-pocock-skills` during discovery and reconciliation so issue tracking, triage-state labels, and domain-document conventions are configured through their owning workflow. Do not substitute project-specific labels for its canonical triage labels.

## 2. Propose and approve

Read [references/reconciliation.md](references/reconciliation.md). Present one complete plan containing every local write, dependency/version choice, exact installation command, conflict, and skipped capability. Wait for explicit approval.

When GitHub is selected, read [references/github-planning-labels.md](references/github-planning-labels.md). Offer the project-planning labels separately from triage labels and record the accepted convention in `docs/agents/issue-tracker.md`. Creating or changing labels on GitHub is an external mutation requiring separate approval.

One approval covers only the proposed non-conflicting local actions. Obtain separate approval for system `PATH`, GitHub/tracker/remotes, downloads, or other external mutations. A newly discovered hard conflict pauses work with evidence and a recommendation.

## 3. Apply

Reconcile from `assets/project-template/`; do not wholesale replace customized files. Install GUT only through [references/gut-installation.md](references/gut-installation.md). Initialize local Git only when approved. Do not create GitHub Actions, placeholder scenes, game folders, commits, pushes, or external resources by default.

## 4. Verify

Verify required adapters, managed-block uniqueness, GUT smoke coverage, and the public recipes `just import`, `just test <test-path>`, `just test-all`, `just runtime`, and `just validate`. With no main scene, runtime must report `NOT_APPLICABLE` successfully; do not create a scene.

Use [references/report-schema.md](references/report-schema.md). A reduced setup must enumerate every missing capability and never claim the standard contract.
