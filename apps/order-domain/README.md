# order-domain

Shared contract artifacts for the Sentinel reference stack.

This directory is intentionally the first **x07 system-learning surface** in the repo:

- shared pure helpers used by the three runtime services
- schema-derived branded boundary types
- a generated state machine spec
- deterministic tests + property-based tests
- prove/coverage flow for a small certifiable pure core
- trust-profile and trust-report artifacts for review-first workflows

The services prove the Sentinel deployment story. `apps/order-domain/` teaches the x07 contract + assurance story early.

## Layout

```text
contracts/              Legacy JSON Schema contracts used by the reference services today
examples/               Example documents for runtime smoke checks
modules/                Shared x07 modules imported by services
schemas/                x07schema sources for branded bytes + generated validators
arch/                   Trust/boundary/state-machine inputs
tests/                  Deterministic tests + PBT for the pure core
verification/           Pure entrypoint used by x07 verify / trust report
ci/                     Scripts for derive, test, verify, and trust flows
```

## Quick start

Generate schema and state-machine artifacts:

```sh
make order-domain-contracts
```

Run deterministic tests and PBT:

```sh
make order-domain-test
```

Run proof and proof replay:

```sh
make order-domain-verify
```

Pin contract locks and run arch drift checks:

```sh
make order-domain-pin
make order-domain-arch-check
```

Emit review-oriented trust artifacts:

```sh
make order-domain-trust
```

## What this patch teaches early

### 1. Branded bytes from schemas

`schemas/*.x07schema.json` are the source of truth for boundary documents. `x07 schema derive`
turns them into branded `bytes_view@brand` validators, encoders, accessors, and deterministic tests.

### 2. State machine as pinned data

`arch/sm/specs/order_lifecycle.sm.json` is the domain lifecycle contract. `x07 sm gen` turns it into a
stable `step(state,event)` module and a generated test manifest.

### 3. Function contracts + proof

`modules/order/core.x07.json` keeps the first certifiable surface small:
- pure math
- explicit `requires` / `ensures`
- replayable proof object
- machine-readable coverage and trust summaries

### 4. Review-first trust posture

The current patch stops at **trust profile check + trust report**. That is enough to teach the
certificate-first review model without pretending the whole distributed system is already formally proved.

## Read next

These are the best official guides to read alongside this package:

- x07 language docs quickstart: <https://x07lang.org/docs/getting-started/agent-quickstart>
- x07 agent initial prompt: <https://x07lang.org/docs/getting-started/agent-initial-prompt>
- x07 provider-agnostic services guide: <https://x07lang.org/docs/guides/provider-agnostic-services>
- x07 messaging guide: <https://x07lang.org/docs/guides/messaging>
- x07 scaling / retry / idempotency guide: <https://x07lang.org/docs/guides/scaling-retry-idempotency>
- x07 service architecture vocabulary: <https://github.com/x07lang/x07/blob/main/docs/guides/x07-service-architecture-v1.md>


For the follow-up review discipline, also read [../../docs/28-contract-locks-and-review.md](../../docs/28-contract-locks-and-review.md).
