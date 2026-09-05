# Skills

This repository packages custom skills in the expected multi-skill layout:

```text
skills/
  asd-ste100/
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
  spec-to-tasks/
    SKILL.md
  ticket-to-spec/
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

Example install shape:

```bash
npx skills add <owner>/<repo>
```

The original local source skills remain under `C:\Users\bsqua\.agents\skills`. This repo is a packaged copy intended to act as the shareable/installable source for `npx skills add <owner>/skills`.
