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
5. Complete the profile's final STE review before you send or save the output.

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
