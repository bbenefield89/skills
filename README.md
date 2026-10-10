# Skills

This repository packages custom skills in the expected multi-skill layout.
Each installable skill lives in its own directory under `skills/` and must contain a `SKILL.md`.

Use `ticket-to-tasks` to post a clarified ticket's specification behind the scenes and review only the task drafts.
It publishes child tasks after approval. Its specification and task references are included.
Install it with `asd-ste100` for its shared writing guidance.

Use `code-review` for general, language/framework, and repository review tables ranked High, Med, and Low.
Its bundled Godot and C#/.NET profiles combine when both apply.
General review includes SOLID, Clean Code, Clean Architecture, and STE checks for comments and documentation where applicable.
This repository maintains the replacement for the previous installed `code-review` skill.
Install it with `asd-ste100` and `engineering-principles` for shared writing and design guidance.

Use `post-review-findings` after a dry-run `code-review` to post its High, Med, and Low findings to an Azure DevOps PR as anchored threads.
Low threads are marked optional and self-resolvable. Install it with `asd-ste100` for its shared writing guidance.

Example install shape:

```bash
npx skills add <owner>/<repo>
```

This repository is the source of the skills. The installed copies under `C:\Users\bsqua\.agents\skills` come from it through the `skills` CLI. Edit skills here, and update the installed copies with `npx skills`.
