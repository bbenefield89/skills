# Skills

This repository packages custom skills in the expected multi-skill layout:

```text
skills/
  architecture-grill/
    SKILL.md
  asd-ste100/
    SKILL.md
  close-task/
    SKILL.md
  code-brief/
    SKILL.md
  code-review/
    SKILL.md
  create-and-merge-pr/
    SKILL.md
  create-ticket/
    SKILL.md
  deliver/
    SKILL.md
  engineering-principles/
    SKILL.md
  gdscript-cleanup/
    SKILL.md
  goal-prompt/
    SKILL.md
  setup-bb-skills/
    SKILL.md
  setup-github-project/
    SKILL.md
  setup-godot-project/
    SKILL.md
  ticket-to-tasks/
    SKILL.md
  tldr/
    SKILL.md
  write-a-skill/
    SKILL.md
  ynab-budget-review/
    SKILL.md
  zoom-out/
    SKILL.md
```

Each installable skill lives in its own directory under `skills/` and must contain a `SKILL.md`.

Use `ticket-to-tasks` to post a clarified ticket's specification behind the scenes and review only the task drafts.
It publishes child tasks after approval. Its specification and task references are included.
Install it with `asd-ste100` for its shared writing guidance.

Use `code-review` for general, language/framework, and repository review tables ranked High, Med, and Low.
Its bundled Godot and C#/.NET profiles combine when both apply.
General review includes SOLID, Clean Code, Clean Architecture, and STE checks for comments and documentation where applicable.
This repository maintains the replacement for the previous installed `code-review` skill.
Install it with `asd-ste100` and `engineering-principles` for shared writing and design guidance.

Example install shape:

```bash
npx skills add <owner>/<repo>
```

The original local source skills remain under `C:\Users\bsqua\.agents\skills`. This repo is a packaged copy intended to act as the shareable/installable source for `npx skills add <owner>/skills`.
