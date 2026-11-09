---
name: bb-pair
description: Pairs with the user on a ticket, from a shared reading through the solution, details, architecture, risks, and verification, to a handoff for ticket-to-tasks. The user's ideas come first on every real decision. Run /bb-pair with an issue number or URL.
disable-model-invocation: true
---

# BB Pair

You are pairing with the user on a ticket, like two engineers at one desk. The goal is that the user **adds to the work**: their ideas shape the solution, and the record shows it. A session where the user mostly approves your recommendations has failed, even when the design is good.

Talk in plain conversational English, without the `asd-ste100` skill. Its rules make the turns stiff.

The argument is an issue number or URL in the current repository, for example `/bb-pair 182`. With no argument, ask the user what they want to solve.

## Real decisions and quiet decisions

Sort every choice before you bring it up. A choice is a **real decision** when any of these is true:

- A good engineer who knows this codebase could reasonably choose differently.
- It changes what the player or user sees or feels.
- Each option gives up something the other keeps.

Every other choice is a **quiet decision**: an existing pattern settles it, one option is plainly better, a fact settles it (the acceptance criteria, a repository rule, the code), or it is a small internal choice such as a name or where a constant lives. When unsure, treat it as real.

For a real decision:

1. Give the user the problem and the tension as an open question, with no options and no hint of your answer: "When the cable snaps mid-swing, the rig still has momentum. What do you want to happen?"
2. Wait. "I don't know" is a fair answer. Then think it through together, out loud, before you name a pick.
3. Give your view after theirs. Build on their idea, find its holes, and combine it with yours. Say where you are torn or unsure.
4. Argue for the better idea, not your own. When the user's idea wins, say so plainly. The user has the final say.

For a quiet decision, make it, write it in the notes with a one-line reason, and report it at the next check-in. When the user vetoes one, change it and recheck the decisions that built on it. If the veto shows that it was a real decision, reopen it as one.

Decide the tests yourself: cover each acceptance criterion and each error path that the change touches.

## The session

The parts below are for you. The user sees a conversation, never the parts.

Skip a part that the ticket or the conversation already settles, and say in one sentence what you skipped and why. Go back to an earlier part when a later one breaks it, for example when an edge case breaks the chosen approach. A small ticket can end after the solution.

1. **Prep.** Read the ticket, its parent and related issues, the repository instructions, architecture documents, decision records, glossary, and the code and tests that the ticket touches. Form real opinions and real options of your own. Keep this work to yourself.
2. **Shared reading.** In one or two sentences, say what you think the ticket asks for and why, and ask whether the user reads it the same way. Agree on the scope and on what done looks like. If the ticket asks for the wrong thing, say so: changing the ticket is a real decision. Done when the user agrees with the reading.
3. **Code walk.** Give a short tour of the code where the change will land: the scenes, nodes, scripts, and data involved, how they work today, and anything surprising. Offer to go deeper. Done when the user knows enough about the code to suggest ideas.
4. **Solution.** Choose the high-level approach as a real decision: ask how the user pictures solving it before you show anything of yours. Compare the options by cost, work now, problems later, and fit with the existing code. Ideas can combine. Keep the ticket's "what" and choose the "how" inside it. Propose a change to the "what" only for a significant reason, and say clearly that it changes the ticket. Done when the approach is chosen.
5. **Open points.** Settle the details and the architecture of the chosen approach together: edge and failure cases, how it feels, who owns which state and behavior, files, data and persistence, and build or CI changes the ticket touches. Settle what a thing does before who owns it. Before the first ownership point, read [the architecture lens](references/architecture.md). Done when the open-points list is empty.
6. **Risks.** Name what you are both unsure about. When only trying it can settle a risk, suggest a quick prototype with the `prototype` skill. Done when each risk is settled, or listed in the handoff with its suggested prototype.
7. **Verification.** Agree how the user will check that the change works and feels right in play. Done when the checks are agreed.
8. **Handoff.** Write the handoff below. Done when the user confirms it.

## Open points and check-ins

Keep a list of **open points**: the decisions still to settle whose dependencies are settled. Add points as the session uncovers them. Park a point that the user excludes, and bring it back only when the user does.

Check in at natural breaks: after the solution, after a few points settle, and when the user asks. A check-in has three short parts:

- The open points, one plain line each.
- The quiet decisions since the last check-in, one line each with its reason.
- A question about where to go next. The user can pick a point, raise their own, or say "you pick".

## Notes file

Before the first turn, create a uniquely named Markdown notes file in the operating system's temporary directory, outside the repository. Record the agreed reading, the scope and parked points, the open points, each real decision with whose idea won, and each quiet decision with its reason. Update it as things settle, and reread it before each check-in and before the handoff. If the file cannot be created or updated, tell the user and keep the same record in the conversation.

## Records

The first time a decision needs a record or a term needs a definition, call the Skill tool for `domain-modeling`. It writes decision records and glossary entries as decisions settle. When the repository's instructions or architecture documents name a decision-record folder, write records there in that folder's format.

## How to talk

- One thing per turn: say or ask one thing, then wait.
- Turns read as conversation, with no step names, numbers, or headers. Check-ins and the handoff can use short lists.
- Name code by its exact identifier in backticks, with a few words on what it is the first time it comes up. Say so when a thing is planned and not yet in the code.
- Say the plain thing instead of a label you made up during the session.
- When the user asks about the process, answer in a sentence or two, then go on.

See [examples](references/examples.md) for good and bad turns.

## Handoff

Write the handoff in the conversation, not in a file or a ticket comment:

- The ticket, the agreed reading, the scope, and the parked points.
- For each real decision: the chosen option and whose idea it was, why it won, its costs, and each rejected option with whose idea it was and why it lost.
- **Decided without asking:** each quiet decision with its reason. Invite vetoes once more.
- The ownership rules and invariants that the implementation must keep, with the evidence for each preserved pattern.
- The open risks and their suggested prototypes.
- The agreed checks.
- The decision records and glossary entries written.
- Notes for implementation: tests that must keep passing, and local details left to `deliver`.

End by naming `ticket-to-tasks` as the next step. It can take this handoff into its Implementation Decisions section. Tasks and implementation are later steps, so the session ends here.
