# Verify and roll back

## Smoke verification

```sh
bash sentinel/scripts/10-smoke-test.sh
```

If your `TARGET_BASE_URL` uses a self-signed or mismatched TLS certificate (common when using the raw ingress-nginx LoadBalancer hostname/IP), run:

```sh
CURL_INSECURE=1 bash sentinel/scripts/10-smoke-test.sh
```

Manual checks:
- `GET /readyz`
- create at least one order
- inspect the latest report record
- inspect cluster workloads with `kubectl`

## Rollback

```sh
export ROLLBACK_RELEASE_ID=<release-id>
bash sentinel/scripts/11-rollback.sh
```

Validate:
- release shows rollback history
- workload state changes
- audit entry exists
