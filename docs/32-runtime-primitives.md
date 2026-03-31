# 32. Runtime primitives in the reference stack

This patch moves the reference stack closer to the **"one whole system"** story described by the x07 guides.

Read this page together with:

- the official performance guide: <https://x07lang.org/docs/guides/performance-tuning>
- the official service-architecture guide: <https://github.com/x07lang/x07/blob/main/docs/guides/x07-service-architecture-v1.md>
- the broader guide map in [29-x07-guide-map.md](29-x07-guide-map.md)

## Why this patch exists

The earlier patches made `apps/order-domain/` a strong pure-core and contract surface:

- branded bytes and schema derive
- pinned state machines
- PBT and verification
- review / trust artifacts

The runtime services still needed to demonstrate how those contracts show up in real service code.

This patch does that in three places:

## `apps/orders-api/`

The API now emits its `order.created` event through the **generated branded boundary** instead of a handwritten JSON emitter. The hot route path is also wrapped in an **arch-driven budget scope**.

What to look at:

- `apps/orders-api/src/app/runtime.x07.json`
- `apps/orders-api/src/app.x07.json`
- `apps/orders-api/arch/budgets/`
- `apps/orders-api/tests/`

What it teaches:

- branded bytes at a service boundary
- arch-driven budgets on a `replicated-http` path
- a small `task.scope_v1` smoke test for structured concurrency

## `apps/orders-consumer/`

The consumer now has a typed helper that:

1. parses the event payload
2. casts it through the generated `order_created_v1` brand
3. applies the generated order lifecycle state machine
4. returns the projected order id only when the branded boundary and state-machine transition both succeed

What to look at:

- `apps/orders-consumer/src/app/runtime.x07.json`
- `apps/orders-consumer/src/app.x07.json`
- `apps/orders-consumer/arch/budgets/`
- `apps/orders-consumer/tests/`

What it teaches:

- branded bytes on message ingress
- `budget.scope_from_arch_v1` per message
- `task.scope_v1` for bounded batch validation/projection fan-out
- state-machine checks at the consumer edge

This is aligned with the performance guide's advice for `partitioned-consumer`: bound work, make the hot path explicit, and keep retry/idempotency logic reviewable.

## `apps/reconciliation-job/`

The scheduled job now includes a **streaming preview pipeline** and a **record/replay roundtrip harness** for that preview path.

What to look at:

- `apps/reconciliation-job/src/app/runtime.x07.json`
- `apps/reconciliation-job/src/app.x07.json`
- `apps/reconciliation-job/arch/budgets/`
- `apps/reconciliation-job/arch/rr/`
- `apps/reconciliation-job/tests/`

What it teaches:

- `std.stream.pipe_v1` for deterministic, budgeted line processing
- `std.rr.with_policy_v1` for a structured rr cassette scope
- a budgeted batch-job sidecar path that can be replayed deterministically

This is aligned with the performance guide's `burst-batch` guidance: make chunking and restart-safe work reviewable, and make the expensive path measurable.

## How to run the new runtime-surface checks

```sh
make runtime-services
```

That runs:

- `apps/orders-api/tests/tests.json`
- `apps/orders-consumer/tests/tests.json`
- `apps/reconciliation-job/tests/tests.json`

## What is still not done

This patch intentionally stops short of a few larger rewrites:

- the API listener is still not a full structured-concurrency accept loop
- the consumer still uses a temporary RabbitMQ management polling shim
- the reconciliation job still keeps the main persisted report JSON on the existing handwritten emitter because the current generated schema tracks the core report shape, not the object-store key sidecar field

Those are the next runtime-hardening steps, not reasons to skip this patch.
