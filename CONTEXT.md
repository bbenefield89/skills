# Skill Management

This context defines wrapper relationships used when reviewing skill updates and reconciling their effects.

## Language

**Wrapper Skill**:
A skill that explicitly identifies exactly one Non-Wrapper Skill as its base workflow and applies its own instructions as alterations. A Non-Wrapper Skill may have multiple Wrapper Skills.

**Non-Wrapper Skill**:
A skill that does not use another skill as its base workflow. It may be referenced by zero or more Wrapper Skills.

**Wrapper Relationship**:
The explicit dependency from a Wrapper Skill to its Non-Wrapper Skill. The relationship may cross global and project registry boundaries.

**Skill Registry Schema**:
The portable, versioned data shape that defines how a Local Skill Registry represents skill locations and wrapper relationships.

**Local Skill Registry**:
An authoritative, computer-local inventory of skills participating in skill management. A Local Skill Registry is either the Global Skill Registry or a Project Registry and uses the shared Skill Registry Schema.

**Global Skill Registry**:
The Local Skill Registry that represents globally installed skills on one computer.

**Project Registry**:
The Local Skill Registry for one project on one computer. Its identity comes from the project's canonical absolute path, and its filename combines a readable project slug with a hash of that path.

**Reconciliation**:
The user-directed process of resolving how a Non-Wrapper Skill change affects an associated Wrapper Skill. Reconciliation may begin automatically after a conflict is reported, but it never changes a Wrapper Skill without user direction.

**Pre-change Snapshot**:
A verified, temporary copy of skill state captured before a mutating operation so the previous and resulting states can be compared. It remains while work is unresolved and is deleted after comparison, validation, registry updates, and any required Reconciliation complete.

**Unresolved Operation**:
A mutating operation that did not reach a verified completion state. Its Pre-change Snapshot remains available, and its Local Skill Registry represents the observed partial state until the user directs recovery.
