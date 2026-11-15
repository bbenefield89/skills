---
name: bb-vibe
description: Turns what the user wants a game, app, or website to do or feel like into a build spec, through rounds of questions about the experience only. The user owns the experience; the agent owns every code decision. Run /bb-vibe with what you want to change or add.
disable-model-invocation: true
---

# BB Vibe

The user is the product owner here. They say what they want and how it should feel to use; you own every code decision. This is the opposite of `bb-pair` and `bb-grill`, where the user wants a say in the code. A good session ends with a spec that pins down exactly the experience the user wants, and the user never had to think about code to get there.

Talk in plain conversational English, without the `asd-ste100` skill.

The argument is what the user wants, in their own words: `/bb-vibe I don't like the feel of the current PC movement.` or `/bb-vibe I want to add a jump feature.` With no argument, ask what they want to change or add.

The product can be a game, an app, a website, or anything else people use. Say "the person using it" unless the product has a better word, such as "the player". "Feel" means how something feels to use, and reference examples can come from any product.

## Read first

Before the first round, quietly read what already exists and work out which case you are in:

- **The behavior exists.** Read the code and scenes for the area the argument names, and describe the current behavior in user terms, with numbers where they help: "the jump peaks at about 0.4 s, and you can't steer in the air."
- **The feature is new, but the product exists.** Describe the nearby behavior that limits it: movement speed, the camera, the screen size, the touch controls on mobile.
- **Nothing exists yet.** Skip the read. The first round starts from reference products: "Which game's jump is closest to what you want?"

Also read the existing `GLOSSARY.md` and the product decision records (see Records). A product decision record marks a choice as deliberate, so treat it as settled unless the user reopens it.

Open with your reading of the current behavior in two or three sentences, then go straight into the first round.

## Interview

Call the Skill tool for `grilling`. It owns the design tree, the frontier, the rounds, the numbered questions, and the recommended answer that "yes" accepts. Add only these rules:

- **Experience decisions only.** A decision goes on the tree when the person using it would notice the difference. Everything they would not notice is yours to leave to the builder: code, structure, engines, libraries, data, and tests.
- **Ask in user terms.** Phrase each question as something the user can picture or feel, and anchor it to reference products where you can: "Snappy and precise like Celeste, or floaty and forgiving like Kirby?" Name code only when the user names it first.
- **Dependencies decide the rounds.** For a jump, round one asks "Can you hold the button to jump higher?" and "Can you steer in the air?". "How much higher?" waits for a later round, after the user says holding matters.
- **Facts are yours.** Find the current speed, timing, or layout in the code yourself. Ask the user only for what they want.
- **Turn feel words into checks.** When the user answers "floatier" or "snappier", pin it to something they can check in use: a reference product ("about as long in the air as in Hollow Knight"), a rough number ("the peak takes about half a second"), or a moment ("you can clear a gap of three tiles").

When the user asks about the code, answer in a sentence or two, then go back to the round.

## Records

Call the Skill tool for `domain-modeling`. It adds `GLOSSARY.md` entries as terms settle, such as "hang time" or what a "drop" means in this product.

In place of code ADRs, write **product decision records** in `docs/pdr/`, a sibling of `docs/adr/`. Use the `domain-modeling` ADR format, numbering (`0001-short-title.md`), and placement rules: create files only when the first one is needed, and follow `GLOSSARY-MAP.md` when it exists. When the repository's instructions or documents name a different location or format for decision records, use that instead.

Keep the `domain-modeling` bar: write a record only for a decision that is hard to reverse, surprising without context, and the result of a real trade-off, such as "no steering in the air, on purpose." The code already shows what was built, so most sessions write no record. A record exists so that a later run does not "fix" a deliberate choice.

## Confirm

When the frontier is empty, recap the result as what the person using it will experience: "Here's what you'll feel when you use it…", then ask "Is this what you want?". Keep going until the user says yes.

## Spec

After the user says yes, write the spec in the conversation. It is a one-time handoff to whoever builds it, so it stays in the chat: not in a file, not in a ticket, and not built in this session.

Write it so a builder who missed the conversation can build the right thing. It covers:

- What the person using it will experience, as concrete behaviors.
- How the user will check each behavior in use.
- The reference products that helped, and what each one stands for.
- The nearby behavior that stays as it is.
- The product decision records and glossary entries written.

Every code decision belongs to the builder, so the spec describes only the experience.

## Use loop

End by inviting the user to build it, use it, and tell you what's off. Their next `/bb-vibe` run starts again at Read first, with the code, the glossary, and the product decision records as they are then.
