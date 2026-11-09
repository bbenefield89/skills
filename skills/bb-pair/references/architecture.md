# Architecture lens

Read this before the first ownership point. It decides which choices are architecture points and how you sort them.

## Which choices are architecture points

A choice is an architecture point when it would change responsibility ownership, authority to mutate important state, subsystem dependencies, or how future features must integrate. Consider only the dimensions that the change touches:

- Responsibility and mutable-state ownership.
- Systems permitted to change state, and systems permitted only to observe it.
- Dependency direction and public subsystem interfaces.
- Lifecycle and persistence boundaries.
- Communication between systems, and resolution of competing requests.
- Execution authority, including movement and physics.

Variable names, loops, casts, helper methods, and internal calculations belong to `deliver`, so they stay out of the session. A specific call is a point only when its ownership sets a boundary, such as authority to call `move_and_slide()`.

## Sorting architecture points

- An existing pattern that is clear, consistent, and fits the behavior makes a **quiet decision**. Record the pattern, its evidence as `file:line` links, and the rule it gives. One convenient implementation is not a pattern.
- A conflict between the code, documented decisions, and the agreed behavior, a missing pattern, a new boundary, or a transfer of responsibility is a **real decision**.

Raise future integration only for agreed requirements or concrete existing collaborators. Favor the smallest design that makes ownership explicit. Suggest an interface, event bus, manager, or other abstraction only for a concrete requirement.

When you give your view on an architecture point, say for each option who owns what, what that does to the boundary, and cite the evidence as `file:line` links.

If the work stays within existing boundaries, there is nothing to discuss: report the ownership rules and their evidence as quiet decisions at the next check-in.
