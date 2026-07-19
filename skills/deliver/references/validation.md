# Validation phase

Run final validation only after both review axes pass.

Use the repository's documented aggregate validation command when one exists. Discover it from repository guidance, task runners, package manifests, build configuration, or established CI commands; do not assume `just` or any technology-specific runner.

Validation must be deterministic and must return a failing process status when its required checks fail. Record the exact command and result.

Outcomes:

- Passing final validation permits a Verified result.
- No adequate final validation command permits an Unverified result; report what proof was available.
- A production or test failure returns to Implementation. Rerun both review axes and validation after the fix.
- Two unsuccessful correction attempts for the same validation failure produce a Failed result with the unresolved output.

Do not invoke or recommend a project-setup skill when discovery fails. Report the missing validation interface and continue according to the outcome rules.
