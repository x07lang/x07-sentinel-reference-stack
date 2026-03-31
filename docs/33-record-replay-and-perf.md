# 33. Record/replay and performance posture

This page explains how the reference stack now connects runtime primitives to the **performance-tuning** guidance.

Read together with:

- <https://x07lang.org/docs/guides/performance-tuning>
- <https://github.com/x07lang/x07/blob/main/docs/guides/x07-service-architecture-v1.md>
- [32-runtime-primitives.md](32-runtime-primitives.md)

## What is covered now

### Record/replay

The first live rr example is in `apps/reconciliation-job/`:

- `arch/rr/index.x07rr.json`
- `arch/rr/policies/report_preview_rr_v1.policy.json`
- `src/app/runtime.x07.json`
- `tests/runtime.x07.json`
- `tests/.x07_rr/.gitignore`

For `run-os` test runs, `x07 test` executes with the manifest directory as the working directory, so the cassette path resolves under `apps/reconciliation-job/tests/.x07_rr/`. The committed `.gitignore` keeps that directory present while ensuring generated `*.rrbin` cassettes are not committed.

The rr roundtrip test does two things in one run:

1. records a preview-pipe cassette
2. replays the same preview-pipe cassette
3. asserts that the replayed payload matches the recorded payload

That gives end users a concrete model for:

- deterministic reproduction
- budgeted replay scopes
- incident-oriented capture/replay of service-adjacent behavior

### Performance posture

This patch does **not** claim the example is fully performance-hardened. Instead, it makes the hot boundaries more explicit so performance tuning can be discussed with real code:

- `orders-api`: budgeted request boundary + typed event emission
- `orders-consumer`: budgeted message boundary + typed projection helper + bounded batch fan-out helper
- `reconciliation-job`: budgeted preview pipe + rr-backed replay harness

This mirrors the official guide's service classes:

- `replicated-http`
- `partitioned-consumer`
- `burst-batch`

## How to use this with the earlier perf harness patch

If you also apply the later perf harness patch set, use the two layers together:

1. this patch for **runtime primitives and typed boundaries**
2. the perf harness patch for **high-load measurements and regression checks**

That split is deliberate:

- this patch makes the runtime boundaries reviewable
- the perf harness measures them under load

## Suggested operator flow

1. Run `make runtime-services`
2. Run the local smoke path
3. Apply the perf harness patch and run its API / consumer / job load targets
4. Use rr roundtrip output and trust artifacts when reviewing changes to the hot paths
