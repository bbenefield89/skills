---
name: code-brief
description: Brief the user on a code change with a one-screen recall infographic of what it introduced (purpose, a short flow of how each main change works, risks, renames, new config, contracts), not a walkthrough. Use when the user asks for a code brief, wants to recall what a branch, PR, commit, or uncommitted work added, or approved a change through agentic review and wants just enough familiarity to recognise it later.
argument-hint: "Optional: changes | staged | unstaged | head | branch [base] | file <path> | system <name>"
---

# Code brief

Turn a code change into a **recall** infographic. The user approved the change largely
through agentic review. They want just enough familiarity to recognise what the change
introduced. When someone mentions it, or an agent proposes a plan that conflicts with it,
the user should think "oh right, we added that." Extract nouns: names, knobs, contracts,
and vocabulary. Show each main change as a short flow of steps, so the user knows how it
works without reading the code. The flow is a whiteboard sketch, not a code tour. Leave
out line-level logic: conditions, loops, error-handling details, and helper methods.
Assume the user may not know the underlying technology.

The infographic is the deliverable. Keep prose out of chat.

## Boundaries

- Read-only. Run only non-mutating Git commands. Stay on the current branch, and leave
  remotes alone (no fetch, no pull). The single write is the HTML copy in step 6.
- Exclude test code from every card and every count: unit and integration tests,
  fixtures, mocks, test helpers, and test infrastructure. Apply this after resolving the
  scope. If only test code remains, say so in one sentence and stop.

## Steps

### 1. Resolve the scope

Read [keyword scopes](references/keywords.md). With no keyword, use `branch main`
against the LOCAL `main` ref. Done when you have the concrete commits or working-tree
layers to extract from, and the top-strip text for that scope. If a guard in that file
fires, reply in one plain sentence and stop. Do not render a widget.

### 2. Extract

From the resolved scope only (for `branch`, the ticket's own commits):

- `--diff-filter=RD --name-status`: renames and removals
- migrations, `*.sql`, `*appsettings*`, `*.env*` files
- added lines matching `GetEnvironmentVariable|IConfiguration|appsettings|FeatureFlag|PackageReference|const string`
- added `[HttpGet|HttpPost|HttpPut|HttpDelete|HttpPatch]` attributes
- added `public`/`internal` `class|record|interface|enum`

Add targeted greps when the stack suggests them. In this step, read individual files only
to name a thing accurately. Step 3 reads the files on each flow's path. For `file` and
`system`, extract the same categories from the current code instead of from added lines.

Done when every non-test file in scope has been checked against each category.

### 3. Trace the flows

Find the entry points in scope: added or changed endpoints, scheduled jobs, message
handlers, background services, and UI event handlers (button clicks, form submits).

Pick at most 2 flows: the ones behind the first purpose sentences. Draft the purpose
order from the changes you found in step 2. Step 4 writes the final sentences.

For each flow, follow the calls from the entry point through the changed files. Stop at
6 steps, at code the change did not touch, or at an external system (a database, blob
storage, a third-party API). Read only the files on the path.

For each step, record:

- what happens, as one plain sentence (for example "The upload job checks whether the
  file is already in storage.")
- the class or method name, for a mono label
- whether the step is new, changed, or unchanged context

When the change alters an existing flow, record the old step that the new one replaced or
skipped. For `file` and `system`, trace the current flow and do not mark steps as new or
changed.

Done when each selected flow runs from its entry point to its stop point. If a flow
cannot reach a stop point, record its name and where it stopped for the output contract.

### 4. Write the purpose

Write full sentences describing what this change does, from the point of view of someone
using the product. Write one sentence per distinct change a user would notice, most
significant first, for a non-technical person who knows the product but not the code.
Edits that serve the same user-visible outcome share one sentence. For `file` and
`system`, describe what the code does for users today.

Done when every user-visible change in scope has its sentence.

Each sentence must:

- name the specific screen, page, pop-up window, button, report, job, or integration,
  using the name a user or teammate would recognise
- say what the user can now do, can no longer do, or now sees differently
- include the condition or reason when there is one ("until you change a field",
  "because these fields are set by the system")
- contain no class names, method names, HTTP codes, or acronyms

To find the specifics, check route paths, page and component file names, UI labels,
headings, button text, validation and permission logic, and commit messages. If a Jira
tool is available and a ticket key is known, read the ticket summary. If you cannot
identify a specific screen or reason, write the sentence anyway and add "(not clear from
the code)" at the point you are unsure. Keep the specific in the sentence. Do not drop it.

| | Example |
|---|---|
| Good | "You cannot click the Save button on the Edit Client page until you change at least one field on that page." |
| Good | "In the Change Role pop-up window, the fields you are not allowed to edit now appear greyed out, so it is clear you cannot change them." |
| Good | "Patient file uploads no longer fill the logs with false 'file already exists' errors." |
| Bad | "Save stays off until you edit." (clipped, not a sentence) |
| Bad | "The Change Role pop-up greys locked fields." (which fields? why locked?) |
| Bad | "Keeps Save off until you change something." (save what? where?) |
| Bad | "Introduces IBlobContainerGuard." (mechanism, jargon) |

### 5. Render the widget

Call the visualization tool's `read_me`, then `show_widget`. The `read_me` output is
large and is often saved to a file. Grep that file for the CSS variables, the Rules
section, and the color palette. Do not read the whole file. Build the layout in
[Layout](#layout). Run the read-aloud check from [Writing standard](#writing-standard) on
every line before you render, including the step sentences in "How it works".

### 6. Save the HTML copy

A rendered widget loses its layout when copied into chat. Write the same infographic as
one self-contained HTML file in the OS temp directory (`$env:TEMP` on Windows, `$TMPDIR`
or `/tmp` elsewhere). Name it `code-brief-<scope-label>-<short-sha>.html`, using the branch
name, keyword, or path slug for the label. The host's CSS variables are not available
outside the widget, so define the same role variables in `:root` with their dark-mode
values and set `color-scheme: dark`. The copy opens dark on every machine, whatever the
OS theme. Inline the icon SVGs. Use no external requests.

## Layout

Top to bottom:

**A. Purpose.** The purpose sentences at the very top, 17px, plain text. With more than
one sentence, put each on its own line with a small check or arrow icon in front. This
is the first thing the user reads.

**B. Top strip.** A thin bordered row, mono 13px, with the scope text from step 1, for
example `<branch> vs local main · merge-base <short-sha> · <k> of <n> commits are this
ticket · <m> files · <primary project or folder>`. The file count excludes test files.
Append `· baseline may be stale` only when [keyword scopes](references/keywords.md)
says to.

**C. How it works.** One row per flow, at most 2, from step 3. Title each row with the
trigger in plain words, for example "When someone uploads a patient file". Each row is a
left-to-right chain of step boxes with an arrow icon between them. Each box has:

- the plain sentence, 13px
- the name in mono, 11px, muted
- a tint: accent tint and the words "New step" for a new step, warning tint and the words
  "Changed step" for a changed step, neutral tint and no label for unchanged context

When a step replaced an old one, show the old sentence struck through under the new box.
For `file` and `system`, title the section "How it works today" and show no step labels.
With more than 2 flows, show the first 2 and add a muted line "+N more flows: <names>".

**D. Most likely to bite you.** Up to 3 cards with the danger role tint. Rank them by
how likely the user is to approve something wrong if they forget the item. Each card has:

- a short plain label
- the name in mono
- **What was wrong:** one full sentence on the problem this solves
- **Don't approve:** one full sentence describing the specific kind of change or plan
  to push back on

For `file` and `system`, title the section "Easy to break by accident" and replace
"What was wrong" with **What it protects:**. Explain jargon inline in a few words the
first time it appears (for example "409 — Azure's 'already exists' error").

**E. Two wide cards side by side.**

- **Renamed or removed**, warning tint. Each entry is `old` → `new`, with the old name
  struck through and a right-arrow icon. Empty state: "Nothing was renamed or removed."
  Omit this card for `file` and `system`, and make the config card full width.
- **New config surface**, accent tint. Each knob in mono, with its default and which
  environments differ on a second line. Empty state: "No new settings, environment
  variables, feature flags, or secrets." For `file` and `system`, title it
  "Config surface".

**F. Four small neutral cards:** Contracts, Data shape, Dependencies, Boundary behavior.
Names in mono, one per line. Under Boundary behavior, write each entry as a short full
sentence. Empty state: "Nothing new here." (For `file` and `system`: "Nothing here.")

### Volume

- At most 2 flows and 6 steps per flow.
- At most 6 entries per card. Show overflow as a muted "+N more <things>", naming the
  things: "+3 more constructors".
- With more than 10 config knobs, group them by prefix or subsystem under small sub-labels.
- Fit everything without scrolling inside the widget. To make room, shrink section F (the
  four small cards) first, then section E. Keep every purpose sentence and every step box.

### Style

- CSS role variables only (`--bg-danger`, `--border-warning`, `--text-accent`,
  `--text-secondary`, and so on), so the widget works in light and dark mode.
- Tabler outline icons. Flat fills: no emoji, gradients, or shadows.
- Sentence case. Font weights 400 and 500 only. Names in mono, at normal weight.
- Write every qualifier in plain words. Never invent an unexplained marker such as
  "inherited".

## Writing standard

Applies to every plain-English line in the widget and the HTML copy.

- Write complete, natural sentences with a subject, a verb, and an object. Write the
  way a person explains something to a coworker out loud.
- Use simple, everyday words. Short sentences are fine. Clipped fragments are not.
- Name UI elements fully: "the Save button", "the Change Role pop-up window", not
  "Save" or "the pop-up".
- Say what the user can or cannot do, see, or click. Prefer "You cannot click the Save
  button until..." over abstract state descriptions.
- Every noun must answer "which one?" and every verb must answer "how?" without a
  follow-up question. When you mention locked or disabled fields, name the fields and
  say why they are locked.
- These shorthand patterns caused real failures, so do not use them: "stays off",
  "greys", "is gated", "no-ops", "surfaces", "short-circuits".
- **Read-aloud check:** before rendering, read each line as if speaking to a coworker.
  If no person would say it that way, rewrite it.

## Output contract

The widget is the answer. Outside it, write at most three short lines, plus one more line when a flow was not fully traced:

- the path of the saved HTML copy
- anything you could not determine, or marked "(not clear from the code)"
- when a flow could not be traced end to end: its name and where it stopped
- when the baseline may be stale: "Run `git pull` on local main and re-run code-brief for a
  cleaner baseline."

Do not write a brief, a walkthrough, or a recap of the widget's contents.
