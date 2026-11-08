# Examples

These come from a test run on a ticket named "Prevent a Drop while the claw is above the prize chute" in a Godot game.

## Bad: a form instead of a conversation

The first message said "I've already done step 1", then showed a "Step 2: check the reading" header with a paragraph, and then a "Step 3: your ideas" header with a numbered list of three questions.

The user said: "This is already failing. Why am I viewing a finished step 1 and then you're presenting me with step 2 and 3?"

Fix: show no steps. Say one thing and wait.

## Good: opening

After preparing quietly:

> I read the ticket as: the player can't start a Drop while the claw is over the prize chute, but they can still move the claw there, and the claw still goes back there after each attempt. Is that how you read it too?

User: "Correct."

> How are you picturing solving it?

## Good: reaction to the user's ideas

The user offered three ideas: a vertical Area3D above the chute, a Marker3D, and a calculation of the chute area. The agent said that two of them matched its own options and that its first pick had been the calculation. It gave the strengths and costs of each idea. The area is visible and resizable in the editor, and it fits the existing sensor areas, but it needs a new node and the right collision layers. A marker is only a point, so it is a weaker version of the calculation. Then it recommended the user's area over its own first pick and asked:

> What do you think? Do you see anything I missed?

## Bad: made-up labels

The agent said, "I suggest this: I note the line as a draft rule for our review at the end, and we go on with the run."

The user said: "Okay what? Line, draft rule, speak clearly."

Fix:

> I think that question belongs in bb-grill, so I'll skip it here.

## Bad: a question that belongs to bb-grill

The agent asked, "Which part of the game should refuse the Drop?" The user said it should not appear in bb-pair at all. Ownership and wiring questions are for `bb-grill`.

## Good: handoff shape (shortened)

> SP-182 handoff: Prevent a Drop while the claw is above the prize chute
>
> Agreed reading: ...
>
> Decision 1: How the game knows the claw is over the chute
> - Chosen: a vertical Area3D above the prize chute that detects the claw. (Your idea.)
> - Why it won: ...
> - Costs: ...
> - Rejected: a Marker3D (your idea), because ... Calculating the chute area (your idea, and my first pick), because ...
> - For bb-grill to settle: ...
>
> Decision 2: How the player sees that Drop isn't available
> - ...
>
> Not discussed in this run: ...
>
> Next step: run `bb-grill`.
