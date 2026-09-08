# Completion report

Report the delivery as a single line:

```markdown
**<ticket or task id> — <Outcome>.** <What changed, one sentence.> <Exact validation command> <result>.
```

Add a second line only when something is unresolved, breaking, assumed, or deliberately skipped. Never more than one extra line, and never a section.

Every user-facing reference to a file **MUST** be a descriptive masked Markdown link to that exact file. Use the natural-language name as the link text and the resolved absolute file path as the target, for example: `Open the [Sky Bun prize scene](C:/path/to/sky_bun.tscn)`. Never leave the reader to infer a filename or location from phrases such as “the Sky Bun prize scene.”

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

Write the plan for a designer or QA tester. Assume that the tester can use only normal product, engine, or editor interfaces. Valid actions include:

- Open a scene or resource in the editor.
- Change a property that the editor exposes for designers.
- Run the full product or an isolated scene.
- Use visible controls and examine visible or audible results.

Keep developer tools out of the plan. Do not require the tester to:

- Open, read, or edit source code.
- Add a breakpoint or use a debugger.
- Use a terminal, command line, developer console, test framework, or CI system.
- Add temporary logging, instrumentation, or test-only behavior.
- Edit serialized files or other internal data outside the normal editor interface.

Apply these rules to each valid plan:

- Plain English only. No jargon, bare file paths, function names, test-framework references, or CI references. When a step refers to a file, use the required descriptive masked link to its exact absolute path.
- One sentence per step. Use as many steps as the change honestly needs and no more.
- Use concrete values a person can actually type, not placeholders.
- Cover the behavior the request asked for, including the case that was previously broken.
- Do not describe the automated tests; those already ran.
- Omit the section entirely for Blocked, or for Failed where there is nothing working to check.

If the change has no result that the tester can observe through an allowed interface, omit the test plan. Use the permitted second report line to state: `Manual test unavailable: <plain-English reason>.` Do not replace it with a developer-only procedure. Do not add test-only product behavior only to make a manual test possible.

Do not print changed-file lists, review transcripts, acceptance-criteria walkthroughs, commit status, or commentary on the pipeline itself. Reviews still run in full and still gate the outcome; their output is available on request, not by default.
