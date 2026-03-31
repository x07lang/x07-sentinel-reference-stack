# Checked-in generated contract artifacts

This directory holds the **committed outputs** of the order-domain contract toolchain.

It exists so reviewers can treat generated contract surfaces as first-class, reviewable artifacts:

- schema-derived boundary modules and tests under `gen/schema/**`
- generated state-machine module and tests under `gen/sm/**`

## Why these files are committed

The previous patch pinned the **inputs**:
- `schemas/*.x07schema.json`
- `arch/sm/specs/*.sm.json`
- `arch/*.lock.json`

This patch makes the generated outputs reviewable too. The workflow is now:

1. regenerate into `gen/`
2. run drift checks in CI
3. review semantic changes alongside the source contracts

## Canonical commands

From repo root:

```sh
make order-domain-contracts
make order-domain-generated-drift
make order-domain-arch-check
```

The underlying x07 commands are:

- `x07 schema derive --input ... --out-dir gen/schema/... --write`
- `x07 schema derive --input ... --out-dir gen/schema/... --check`
- `x07 sm gen --input ... --out gen/sm --write`
- `x07 sm gen --input ... --out gen/sm --check`

## Important note

The files under `gen/` are **derived artifacts**, not hand-authored business logic. Treat edits here as suspicious unless they were produced by the toolchain and reviewed together with their source contracts.

Read alongside:

- `docs/27-order-domain-primitives.md`
- `docs/28-contract-locks-and-review.md`
- `docs/31-generated-artifacts-and-drift.md`
- official schema derive guide: <https://x07lang.org/docs/toolchain/schema-derive>
- official state-machine guide: <https://x07lang.org/docs/toolchain/state-machines>
- official review/trust guide: <https://x07lang.org/docs/toolchain/review-trust>
- service architecture vocabulary: <https://github.com/x07lang/x07/blob/main/docs/guides/x07-service-architecture-v1.md>
