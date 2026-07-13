# GitHub planning labels

These optional labels classify an issue's planning role; they do not represent triage state:

| Label | Meaning |
| --- | --- |
| `phase` | A broad delivery stage containing related epics. |
| `epic` | A substantial outcome composed of multiple tickets or slices. |
| `ticket` | A bounded unit of planned work. |
| `slice` | A vertical, independently verifiable increment through a larger ticket or epic. |

When GitHub is the selected tracker:

1. Ask whether the repository should use these labels; do not assume.
2. Reconcile compatible existing definitions and ask about contradictory meanings.
3. Record the accepted meanings in `docs/agents/issue-tracker.md`.
4. Treat GitHub label creation, edits, colors, and descriptions as separately approved external mutations.

Keep these labels separate from `$setup-matt-pocock-skills` triage-state labels such as `needs-triage` and `ready-for-agent`. An issue may have one planning-role label and one triage-state label.
