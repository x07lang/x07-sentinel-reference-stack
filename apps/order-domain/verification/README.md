# Verification notes

This directory is the pure verification entrypoint for the shared contract area.

The main reference services are not claimed as formally proved. Instead, the repo keeps the verification story honest:

- the distributed system proves deployment, bindings, release control, rollback, and audit
- the shared `order-domain` package proves the first certifiable pure kernel
- trust artifacts make the review posture explicit before the repo claims certificate-first evidence

## Commands

Coverage + support posture:

```sh
bash apps/order-domain/ci/verify.sh
```

Trust profile + trust report:

```sh
bash apps/order-domain/ci/trust.sh
```

## Current teaching boundary

The operational entry under review is:

- `order.core.missing_projection_count_v1`

This is intentionally small. It gives the repo one pure, reviewable core while the service examples stay focused on Sentinel runtime behavior.
