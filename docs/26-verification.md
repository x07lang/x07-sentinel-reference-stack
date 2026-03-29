# Verification (order-domain)

This repo keeps the verification story honest: the distributed system is not formally proved.

The place to run x07 verification is the pure/shared contract package under `apps/order-domain/`.

## Coverage

```sh
bash scripts/verify/run-coverage.sh
```

This runs `x07 verify --coverage` against an `order-domain` entrypoint using the pinned dependencies under `apps/order-domain/verification/`.
This uses the verification project manifest under `apps/order-domain/x07.json`.

