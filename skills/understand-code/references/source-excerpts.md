# Source excerpts

Build working knowledge quickly by doing the code-reading work for the user.
Show the relevant source in the conversation and explain its role, behavior, and connection to the current concept.
Keep excerpts small enough to support one teaching step, while preserving the context needed to understand them.
The user should be able to answer comprehension questions from the explanation and excerpt without opening a file.
Use links for optional verification or deeper exploration. Do not assign file-reading homework or substitute “start with this file” for teaching.

## Label every repository excerpt

Immediately above each code block taken from the repository, place a bold source label containing a masked Markdown link.
The visible link text must identify the file and exact source line span. Use a language tag on the code fence.
Link to the first excerpted line using the host's supported source-link format.
For desktop local files, use an absolute path with a `:line` suffix; put the full line span in the label.
Place the explanation directly below the excerpt.

Read the selected source version and verify the lines before quoting. Preserve source text exactly.
For separated source ranges, use separate labeled blocks instead of presenting omitted lines as one continuous excerpt.
For committed or staged scopes, name the source version when it differs from the working tree.
Use a verified revision-specific link when available. If only a local link is available, disclose any version mismatch.
Never imply that a working-tree link shows the quoted historical or staged version when it does not.

Label invented code as **Illustrative example**, without attributing it to the repository.
Label modified source as **Adapted example**, link its source, and describe the modification. Keep it distinct from exact excerpts.

## Presentation pattern

The following is an illustrative formatting template. Replace its placeholder path and lines with verified source information.

**Source: [path/to/file.ext, lines 20–24](/absolute/path/to/file.ext:20)**

```text
Exact source excerpt goes here.
```

Explain what this code does, why it matters, and how it connects to the current teaching step.
Then ask the step's focused question when enough context has been provided.
