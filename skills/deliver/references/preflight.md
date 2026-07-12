# Delivery preflight

Verify before implementation:

- An authoritative implementation source and definition of done exist.
- Repository guidance and delivery contract are readable.
- `docs/agents/workflow-adapters.md` maps every required capability.
- Every selected skill or command adapter is available.
- Required local tools exist.
- `just test` and `just validate` exist.
- The worktree and task starting point can identify the change scope.
- Commit authority is captured; default is false.

Outcomes: **Ready** continues; **Repairable** offers `project_setup`; **Reduced** enumerates every unavailable capability and skipped proof and requires explicit approval; **Blocked** stops without implementation. Never report a reduced run as full delivery.
