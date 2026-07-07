# Skills

This repository packages custom skills in the expected multi-skill layout:

```text
skills/
  branch-risk-audit/
    SKILL.md
  clarify-with-docs/
    SKILL.md
  goal-prompt/
    SKILL.md
```

Each installable skill lives in its own directory under `skills/` and must contain a `SKILL.md`.

Example install shape:

```bash
npx skills add <owner>/<repo>
```

The original local source skills remain under `C:\Users\bsqua\.agents\skills`. This repo is a packaged copy intended to act as the shareable/installable source for `npx skills add <owner>/skills`.
