# Completion report

Report the delivery as a single line:

```markdown
**<ticket or task id> — <Outcome>.** <What changed, one sentence.> <Exact validation command> <result>.
```

Add a second line only when something is unresolved, breaking, assumed, or deliberately skipped. Never more than one extra line, and never a section.

- **Unverified:** name the missing validation interface and the focused proof that did run.
- **Failed:** state the unresolved failure.
- **Blocked:** state the decision needed.

## Test plan

Under the report line, give the manual steps a person performs to confirm the change works:

```markdown
**Test it**

1. <One short step, plain English.>
2. <What to do.>
3. <What should happen.>
```

- Plain English only. No jargon, no file paths, no function names, no test-framework or CI references.
- One sentence per step. Use as many steps as the change honestly needs and no more.
- Use concrete values a person can actually type, not placeholders.
- Cover the behavior the request asked for, including the case that was previously broken.
- Do not describe the automated tests; those already ran.
- Omit the section entirely for Blocked, or for Failed where there is nothing working to check.

Do not print changed-file lists, review transcripts, acceptance-criteria walkthroughs, commit status, or commentary on the pipeline itself. Reviews still run in full and still gate the outcome; their output is available on request, not by default.
