# order-domain primitives path

This doc is the fastest way to understand how the Sentinel reference stack now teaches the **x07 “one whole system”** model, not just deploy steps.

## Why `apps/order-domain/` exists

The runtime services prove the Sentinel story:
- targets
- bindings
- release submit / approval
- deploy
- verify
- rollback
- audit

But the pure/shared domain pack is where the repo can safely teach:
- pinned contracts
- branded bytes
- generated state machines
- property-based testing
- function contracts + proof
- review-first trust artifacts

In the language of the official service architecture guide:
- `apps/order-domain/` is the **Domain Pack**
- `orders-api`, `orders-consumer`, and `reconciliation-job` are **Operational Cells**

Read the official guide for the vocabulary: <https://github.com/x07lang/x07/blob/main/docs/guides/x07-service-architecture-v1.md>

## What is included

### Branded bytes via `x07 schema derive`

Schema sources live under:

- `apps/order-domain/schemas/order_created_v1.x07schema.json`
- `apps/order-domain/schemas/reconciliation_report_v1.x07schema.json`

Generation writes into:

- `apps/order-domain/.generated/schema/order_created/`
- `apps/order-domain/.generated/schema/reconciliation_report/`

Those generated modules are the repo’s first explicit demonstration of:
- typed document boundaries
- canonical validators
- `bytes_view@brand` surfaces
- deterministic generated tests

### State machine via `x07 sm gen`

The source-of-truth lifecycle spec lives at:

- `apps/order-domain/arch/sm/specs/order_lifecycle.sm.json`

The current transitions use the minimal `actions.noop_v1` implementation:

- `apps/order-domain/modules/actions.x07.json`

Generation writes into:

- `apps/order-domain/.generated/gen/sm/`

This gives the repo a pinned `step(state,event)` contract instead of hand-written transition code.

### PBT + function contracts

The certifiable pure core lives at:

- `apps/order-domain/modules/order/core.x07.json`

The current proving target is:

- `order.core.missing_projection_count_v1`

It is intentionally small:
- pure arithmetic
- explicit `requires` / `ensures`
- easy replayable proof object
- easy PBT equation

Tests live under:

- `apps/order-domain/tests/`

### Trust-first review artifacts

The current flow stops at:
- `x07 trust profile check`
- `x07 trust report`

That is deliberate. It teaches the review workflow early without overstating the assurance level of the whole distributed system.

## Recommended reading path

These official guides pair well with this package.

### Getting started

- Agent quickstart: <https://x07lang.org/docs/getting-started/agent-quickstart>
- Agent initial prompt: <https://x07lang.org/docs/getting-started/agent-initial-prompt>

### Guides that explain why the repo is shaped this way

- Provider-agnostic services: <https://x07lang.org/docs/guides/provider-agnostic-services>
- Messaging: <https://x07lang.org/docs/guides/messaging>
- Scaling / retry / idempotency: <https://x07lang.org/docs/guides/scaling-retry-idempotency>
- Performance tuning: <https://x07lang.org/docs/guides/performance-tuning>
- Service architecture vocabulary: <https://github.com/x07lang/x07/blob/main/docs/guides/x07-service-architecture-v1.md>

## Suggested local sequence

```sh
make order-domain-contracts
make order-domain-test
make order-domain-verify
make order-domain-trust
```

## What comes next

The next step is now documented in [28-contract-locks-and-review.md](28-contract-locks-and-review.md):
- pin arch + contract locks with `x07 arch check --write-lock`
- run `x07 arch check` in CI as a first-class gate
- generate semantic review artifacts with `x07 review diff`

After that, thread these primitives deeper into the runtime services:
- feed schema-derived brands into runtime boundary adapters
- consume the generated lifecycle machine in `orders-consumer`
- add RR fixtures around cross-service deterministic flows
- promote the repo from “teaches the primitives” to “ships certificate-first review artifacts by default”


For a broader map back to the official x07 guides, read [29-x07-guide-map.md](29-x07-guide-map.md).
