# Pinned contracts, lock files, and review artifacts

This page is the next step after [27-order-domain-primitives.md](27-order-domain-primitives.md).

The first primitives patch taught the **source inputs**:
- schemas
- state-machine specs
- boundaries
- property tests
- prove / coverage
- trust reports

This patch teaches the **review discipline** that makes those inputs auditable:
- pin contract inputs with `x07 arch check --write-lock`
- keep machine-readable lock files in `arch/`
- re-run `x07 arch check` in CI
- generate semantic review artifacts with `x07 review diff`

## Why this matters

The reference stack is supposed to demonstrate the x07 system model in a way an enterprise team can actually review.
That means a reviewer should not need to trust vague statements like “the generated outputs are probably current.”

Instead, the repo should make these questions answerable:
- Which contract files are pinned?
- Which state-machine specs and boundary indexes are part of the reviewed surface?
- Did CI detect contract drift?
- What changed semantically between two revisions?

## Files added by this patch

```text
apps/order-domain/
  arch/manifest.lock.json
  arch/contracts.lock.json
  ci/pin_contracts.sh
  ci/arch_check.sh
  ci/review.sh
scripts/ci/order-domain-lock-drift.sh
```

## What the lock files mean

### `arch/manifest.lock.json`

Written by:

```sh
x07 arch check --write-lock
```

This pins:
- the manifest digest
- the module scan configuration

### `arch/contracts.lock.json`

Also written/updated by:

```sh
x07 arch check --write-lock
```

This pins the contract inputs referenced by the enabled `contracts_v1` groups in the arch manifest.
In this package, that currently means the state-machine spec/index and the public boundary index.

## Recommended local workflow

From repo root:

```sh
make order-domain-pin
make order-domain-arch-check
make order-domain-test
make order-domain-verify
make order-domain-trust
```

To generate semantic review artifacts against an earlier checkout or exported baseline:

```sh
make order-domain-review BASELINE=/path/to/earlier/order-domain
```

## CI posture

CI should now do two things in sequence:

1. refresh generated contract artifacts + write/update lock files
2. fail if the committed lock files no longer match the source inputs

That keeps “contract drift” visible in pull requests instead of discovering it after a release review.

## Read next in the official docs

These official docs explain the concepts this patch operationalizes:

- x07 architecture check: <https://x07lang.org/docs/toolchain/arch-check>
- x07 schema derive: <https://x07lang.org/docs/toolchain/schema-derive>
- x07 state machines: <https://x07lang.org/docs/toolchain/state-machines>
- x07 testing / PBT: <https://x07lang.org/docs/toolchain/testing>
- x07 formal verification & certification: <https://x07lang.org/docs/toolchain/formal-verification>
- x07 review & trust: <https://x07lang.org/docs/toolchain/review-trust>
- x07 service architecture vocabulary: <https://github.com/x07lang/x07/blob/main/docs/guides/x07-service-architecture-v1.md>


For the wider guide map that explains where these concepts sit in the official documentation set, read [29-x07-guide-map.md](29-x07-guide-map.md).


The follow-up patch that commits generated schema and state-machine outputs is documented in [31-generated-artifacts-and-drift.md](31-generated-artifacts-and-drift.md).
