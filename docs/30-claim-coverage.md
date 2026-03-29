# Claim coverage matrix

| Website claim | Proof in this repo |
|---|---|
| Deploy governed services to your current Kubernetes | `infra/terraform/*`, `sentinel/payloads/targets/*`, docs 10/11/20 |
| Backend service types are supported | `apps/orders-api`, `apps/orders-consumer`, `apps/reconciliation-job` |
| Bind to database, queue, object storage, secrets, telemetry | `sentinel/payloads/bindings/*`, docs 22 |
| Build native runtime images from x07 services | `apps/*/Dockerfile`, docs 23 |
| Submit, approve, deploy, verify, roll back | `sentinel/scripts/08-11`, docs 23 and 24 |
| Works on AWS | `infra/terraform/aws/minimal/`, docs 10 |
| Works on GCP | `infra/terraform/gcp/minimal/`, docs 11 |
| Audit and release history are visible | docs 25 |
| Shared contracts are beneficial | `apps/order-domain/` |
| Formal verification can be introduced on pure/shared code | `apps/order-domain/verification/README.md` |

## Honest limits

- the consumer business loop is still minimal in the first public skeleton
- the shared contract area is schema-first in the first public release
- the example stays backend-only in v1
