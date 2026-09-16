---
name: asd-ste100
description: Applies ASD-STE100 Simplified Technical English guidance to replies and written artifacts. Use when a user requests ASD-STE100 or STE-aligned output, or another skill requires this writing guidance.
---

# ASD-STE100

Use this shared skill for the language of replies and written artifacts.
The calling skill or user controls the output structure, scope, and level of detail.

## Apply the writing rules

1. Read and apply [the ASD-STE100 Issue 9 writing profile](references/asd-ste100-profile.md) before you produce output.
2. Resolve project terminology:
   - If the repository has multiple `CONTEXT.md` files, read `CONTEXT-MAP.md` first to find the applicable file.
   - Use domain terms from the applicable `CONTEXT.md`.
   - If no terminology file exists, use plain words and established terms from the supplied material or current context.
3. Preserve exact code, commands, identifiers, file paths, quotations, and required domain terms.
4. Apply the profile to natural-language text, including progress updates, questions, reports, instructions, and artifact prose.
5. Apply the profile's precision checks. Name the responsible actor, its action, and the affected item when these details clarify meaning.
6. Run the profile's mandatory output gate after you draft the complete prose.

## Mandatory output gate

After you draft the response or artifact, reopen the profile's
[Final STE review](references/asd-ste100-profile.md#final-ste-review). Complete
its second pass against the finished prose. Rewrite each failed sentence or list
item, and then repeat the review. The output is incomplete until every check
passes. Do not send or save a draft that did not complete this gate.

This skill does not activate a persistent response mode or impose a summary length, heading, or next-step section.
Keep the structure and completeness required by the calling skill or user.

## Use from another skill

Add this instruction where the skill defines its output requirements:

> Before you write user-facing prose, read and apply the `asd-ste100` skill and its writing profile. Keep this skill's required output structure and detail.

## Compliance boundary

Describe the result as STE-aligned. This skill does not include the controlled dictionary and does not prove formal ASD-STE100 compliance.
If formal compliance is required, check the official standard, its dictionary, and the applicable company glossary.
State any remaining verification limits.

## Example

Before: "The configuration should be verified by the operator prior to proceeding with the deployment."

After: "Check the configuration before you deploy the application."
