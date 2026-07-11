# GitHub Project workflow

GitHub Issues is the publication target for phases, epics, specifications, and implementation tickets. The linked GitHub Project visualizes planning and executable work; it does not contain specification issues.

## Artifact contract

- A Phase issue uses `phase` and is the native parent of its Epics.
- An Epic uses `epic`, is the native child of exactly one Phase, and links its specification under `Specification`.
- A specification is a separate issue using `spec`. It has no readiness label, native parent, native children, or Project membership.
- An implementation ticket is created from a specification, references that specification, uses exactly one of `ready-for-agent` or `ready-for-human`, and is the native child of exactly one Epic.

Labels classify artifacts; they do not create hierarchy. An Epic or implementation ticket with the correct label but without the correct native parent is incomplete. Specifications are never parents of implementation tickets.

## Publishing with agent skills

For this repository, these rules override generic skill defaults:

- `to-spec` creates a `spec`-labelled GitHub issue, applies no readiness label, leaves it outside the Project and native hierarchy, and links it from the Epic's `Specification` section.
- `to-tickets` creates implementation issues from the specification, references the specification in every ticket, attaches every ticket natively to the Epic, and applies exactly one readiness label.
- After publishing an Epic or implementation ticket, confirm its native parent and Project membership. After publishing a specification, confirm that it is absent from the Project.
- Publishing tickets must not close or rewrite the Epic.

## Project views and automation

`Current Work` is a flat Status board with Todo, In Progress, and Done. It contains only readiness-labelled implementation tickets and shows Parent issue and Labels.

`Epic Roadmap` is a table filtered to `label:"epic"` and grouped by native Parent issue, so Phase issues appear as group headings. Empty Phases remain absent until they contain an Epic.

Open issues using `phase`, `epic`, `ready-for-agent`, or `ready-for-human` are automatically added. The `spec` label is excluded from auto-add. Added items enter Todo, closed items move to Done, reopened items return to Todo, and movement to In Progress is manual.
