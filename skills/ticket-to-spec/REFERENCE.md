# Ticket to Spec Reference

This template and its synthesis rules are inherited from the source `to-spec` skill.

## Specification template

```markdown
## Specification

### Problem Statement

The problem that the user is facing, from the user's perspective.

### Solution

The solution to the problem, from the user's perspective.

### User Stories

A LONG, numbered list of user stories. Each user story should be in the format of:

1. As an <actor>, I want a <feature>, so that <benefit>

Example:

1. As a mobile bank customer, I want to see the balance on my accounts, so that I can make better informed decisions about my spending

This list should be extremely extensive and cover all agreed aspects of the feature.

### Implementation Decisions

List the implementation decisions that were made. This can include:

- The modules that will be built or modified
- The interfaces of those modules that will be modified
- Technical clarifications from the developer
- Architectural decisions
- Schema changes
- API contracts
- Specific interactions

Do NOT include specific file paths or code snippets. They may become outdated quickly.

Exception: if a prototype produced a snippet that encodes a decision more precisely than prose can, inline it within the relevant decision and note briefly that it came from a prototype. Trim it to the decision-rich parts.

### Testing Decisions

List the testing decisions that were made. Include:

- A description of what makes a good test: test external behavior, not implementation details
- Which modules will be tested
- Prior art for the tests, such as similar tests in the codebase

### Out of Scope

A description of the things that are out of scope for this specification.

### Further Notes

Any further notes about the feature.
```

## Synthesis rules

- Synthesize what has already been discussed; do not restart discovery through an interview.
- Explore the repository enough to use its current domain and architectural vocabulary.
- Respect relevant ADRs.
- Record decisions, not speculative implementation detail.
- Make ambiguity explicit only when the existing discussion cannot support one interpretation.
- Keep the ticket's original TL;DR as the quick-reading entry point.
