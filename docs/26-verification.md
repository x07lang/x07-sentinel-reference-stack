# Verification (order-domain)

This repo keeps the verification story honest: the distributed system is not formally proved.

The place to run x07 verification is the pure/shared contract package under `apps/order-domain/`.

## What is covered now

`apps/order-domain/` now demonstrates the first serious x07 assurance surface in the repo:

- schema-derived branded boundary documents
- a generated order lifecycle state machine
- deterministic tests + property-based tests
- `x07 verify --coverage`
- `x07 verify --prove`
- `x07 prove check`
- `x07 trust profile check`
- `x07 trust report`

The operational entry currently under formal review is:

- `order.core.missing_projection_count_v1`

That keeps the proof boundary small and reviewable while the runtime services stay focused on Sentinel deployment and operations.

## Commands

Generate schema/state-machine artifacts:

```sh
make order-domain-contracts
```

Run deterministic tests and PBT:

```sh
make order-domain-test
```

Run coverage/prove + replay:

```sh
make order-domain-verify
```

Run trust profile check + trust report:

```sh
make order-domain-trust
```

Run everything together:

```sh
make order-domain-ci
```

## Artifact locations

All local artifacts land under `apps/order-domain/target/`:

- `target/reports/` — schema derive + SM generation reports
- `target/test/` — deterministic tests, PBT, and generated-test reports
- `target/verify/coverage/` — coverage/support report
- `target/verify/prove/` — prove report, proof object, proof replay report
- `target/trust/` — trust profile check and trust report (`report.json` + `report.html`)

## Important limitation

This does **not** mean the whole reference stack is formally verified.

The repo still makes a narrower and more honest claim:
- Sentinel deployment story is proved by end-to-end tutorials and runtime smoke checks
- x07 assurance story is demonstrated by the shared `order-domain` kernel and its review artifacts
