# Examples

## No findings

```md
No Critical or High findings.
```

## Findings

```md
Critical - Deletes production records before downstream write is confirmed
File: src/orders/apply_refund.ts
Lines: 118-132
Why this is risky: the branch now removes the source record before the external refund call and audit insert succeed. Any timeout or partial failure leaves the system with neither the original record nor a compensating trail.
Failure mode: a transient API failure causes irreversible data loss and an untraceable refund state.
Suggested fix: move deletion after all side effects succeed or wrap the flow in a transaction with compensating rollback.

High - Authorization check moved after tenant-scoped query
File: app/controllers/projects_controller.rb
Lines: 54-61
Why this is risky: the changed order allows lookup of a project before ownership is verified, which can expose cross-tenant existence and metadata through different error paths.
Failure mode: an authenticated user can probe project identifiers outside their tenant.
Suggested fix: enforce tenant and permission scoping in the query itself before loading the record.
```
