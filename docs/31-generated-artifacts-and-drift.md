# Generated artifacts and drift gates

This page is the follow-up to:

- [27-order-domain-primitives.md](27-order-domain-primitives.md)
- [28-contract-locks-and-review.md](28-contract-locks-and-review.md)

Those docs pinned the **source contracts** and the **lock files**.
This patch makes the **generated outputs** first-class too.

## What changed

The order-domain package now commits these generated surfaces under `apps/order-domain/gen/`:

```text
apps/order-domain/gen/
  schema/
    order_created/
    reconciliation_report/
  sm/
    order/
      lifecycle_v1.x07.json
      lifecycle_v1/tests.x07.json
    tests.manifest.json
```

The CI flow now fails if these files drift from the current source contracts.

## Why this matters

A contract-first repository is still hard to review if the derived surface is hidden in a temporary folder.
Committing `gen/` makes these questions answerable in a pull request:

- did a schema-derived boundary module change?
- did the generated state machine change?
- did the generated tests change?
- did the lock files and generated files move together?

That is much closer to the certificate-first review model described in the x07 toolchain docs.

## Canonical workflow

From repo root:

```sh
make order-domain-contracts
make order-domain-generated-drift
make order-domain-pin
make order-domain-arch-check
make order-domain-test
make order-domain-verify
make order-domain-trust
```

## CI gates

There are now two separate drift gates:

1. `scripts/ci/order-domain-generated-drift.sh`
   - fails if `apps/order-domain/gen/` is not up to date
2. `scripts/ci/order-domain-lock-drift.sh`
   - fails if `arch/manifest.lock.json` or `arch/contracts.lock.json` drift

That split is intentional.
One gate protects **derived code/tests**.
The other protects **pinned contract inputs**.

## Relationship to the official x07 docs

Read these alongside this repo:

- schema derive: <https://x07lang.org/docs/toolchain/schema-derive>
- state machines: <https://x07lang.org/docs/toolchain/state-machines>
- testing / PBT: <https://x07lang.org/docs/toolchain/testing>
- formal verification & certification: <https://x07lang.org/docs/toolchain/formal-verification>
- review & trust: <https://x07lang.org/docs/toolchain/review-trust>
- service architecture vocabulary: <https://github.com/x07lang/x07/blob/main/docs/guides/x07-service-architecture-v1.md>

## What this still does **not** claim

This patch improves the review posture of the `order-domain` package.
It does **not** claim that the entire distributed Sentinel reference stack is formally proved.

The current strong assurance surface is still the small pure core around:

- `order.core.missing_projection_count_v1`

The committed `gen/` layout makes the contract surface easier to review and to diff, but it does not magically raise the proof scope beyond what the repo actually verifies.
