# Examples

These use a ticket named "Prevent a Drop while the claw is above the prize chute" in a Godot game. The bad turns and the reaction to the user's ideas come from real runs. The code walk and the check-in were written to show the shape, so their code names are illustrative.

## Bad: a form instead of a conversation

The first message said "I've already done step 1", then showed a "Step 2: check the reading" header with a paragraph, and then a "Step 3: your ideas" header with a numbered list of three questions.

The user said: "This is already failing. Why am I viewing a finished step 1 and then you're presenting me with step 2 and 3?"

Fix: show no steps. Say one thing and wait.

## Good: opening

After preparing quietly:

> I read the ticket as: the player can't start a Drop while the claw is over the prize chute, but they can still move the claw there, and the claw still goes back there after each attempt. Is that how you read it too?

User: "Correct."

## Good: a short code walk

> Quick tour of where this lands. `ClawRig` (the node that moves the claw and runs the Drop) starts a Drop from `start_drop()`, and nothing checks the claw's position first. The chute is `PrizeChute` (a scene with a `CollisionShape3D` that catches prizes), and it doesn't know about the claw at all. One surprise: the HUD's Drop button calls `start_drop()` directly, not through the input map. Want me to go deeper on any of that?

## Good: reaction to the user's ideas

The agent asked, "How are you picturing solving it?" The user offered three ideas: a vertical Area3D above the chute, a Marker3D, and a calculation of the chute area. The agent said that two of them matched its own options and that its first pick had been the calculation. It gave the strengths and costs of each idea. The area is visible and resizable in the editor, and it fits the existing sensor areas, but it needs a new node and the right collision layers. A marker is only a point, so it is a weaker version of the calculation. Then it said the user's area beat its own first pick and asked:

> What do you think? Do you see anything I missed?

## Bad: a menu instead of a question

> **Question:** Should the HUD hide the Drop button over the chute?
> - **A** - Hide it.
> - **B** - Disable it and grey it out.
>
> ➡️ **Recommended:** B

The user picked B without thinking about it, and nothing of theirs went into the decision.

Fix: give the tension first and ask for their take.

> When the claw is over the chute, the Drop button can't do anything. What do you want the player to see there?

## Bad: made-up labels

The agent said, "I suggest this: I note the line as a draft rule for our review at the end, and we go on with the run."

The user said: "Okay what? Line, draft rule, speak clearly."

Fix:

> Let's come back to that one later. I've added it to the open points.

## Good: check-in

> Where we are. Still open:
> - What the player sees when Drop isn't available.
> - Whether the claw can start a Drop while it's moving into the chute area.
>
> Decided without asking since last time:
> - `ChuteSensor` uses the `sensors` collision layer, like the other sensor areas.
> - The check lives in `ClawRig.start_drop()`, since `ClawRig` already refuses a Drop during a reset.
>
> Where do you want to go next?

## Good: handoff shape (shortened)

> SP-182 handoff: Prevent a Drop while the claw is above the prize chute
>
> Agreed reading: ...
>
> Decision 1: How the game knows the claw is over the chute
> - Chosen: a vertical Area3D above the prize chute that detects the claw. (Your idea.)
> - Why it won: ...
> - Costs: ...
> - Rejected: a Marker3D (your idea), because ... Calculating the chute area (my first pick), because ...
>
> Decided without asking:
> - ...
>
> Ownership rules: ...
>
> Open risks: ...
>
> Checks: ...
>
> Next step: run `ticket-to-tasks`.
