# Implementation status

This repo is intentionally published as a **canonical skeleton** first.

## Already concrete

- three service folders with real x07 source trees adapted from preprod
- a pure/shared `apps/order-domain/` x07 package (contracts + helpers)
- service manifests for API, event-consumer, and scheduled-job shapes
- cloud Terraform directories for AWS and GCP
- cluster add-on bootstrap script
- Sentinel payload templates and automation scripts
- tutorial docs from onboarding through rollback
- claim coverage matrix

## First expansion after publication

- add validated screenshots and console captures under `docs/screenshots/`
- add CI for image build smoke and Sentinel script dry-runs
- expand cloud tutorials with real “fresh clone” validation notes and common failure modes

## Known issues / follow-ups

- Postgres TLS verification against RDS / Cloud SQL CAs can fail at runtime. Current workaround in the example images sets `X07_OS_DB_NET_REQUIRE_VERIFY=false` (disables certificate verification). Proper fix: support providing a CA bundle / platform-managed roots for managed Postgres.
- Remote Kubernetes targets currently require `https://` base URLs (non-loopback). When using the raw ingress-nginx LoadBalancer hostname/IP, TLS is often self-signed; smoke checks may require `CURL_INSECURE=1`. Proper fix: use a real certificate (ACM/managed cert) or improve target transport configuration.
- Creating custom `amqp` / `otlp` bindings without an explicit `binding_id` can collide with environment defaults (`primary-bus`, `telemetry-otlp`). The example templates set explicit `binding_id`s for these bindings.
- RabbitMQ user/password in the AMQP URL can contain percent-encoded bytes. When these credentials are reused for RabbitMQ management API auth, the user/pass must be URL-decoded before Basic auth is built (otherwise the management API returns 401 and the consumer never becomes ready).
- `order.created` queue creation is not guaranteed by the RabbitMQ Helm chart defaults. The bootstrap path currently creates the queue explicitly after RabbitMQ starts; a more robust solution would be chart-native definitions or a small init job.
- The OpenTelemetry Collector Helm chart treats empty YAML maps as “unset”. Values must use explicit empty maps (`http: {}`, `grpc: {}`, `batch: {}`), otherwise the generated config can reference `batch` while omitting it and crash-loop.
- AWS teardown can leave orphaned Classic ELB resources if the cluster is destroyed before the LoadBalancer Service is deleted. Teardown should uninstall add-ons (or at least delete `ingress-nginx-controller`) and wait for the ELB + security group to disappear before deleting the VPC.
- AWS S3 buckets used for reports can accumulate versioned objects. Terraform destroy can fail with `BucketNotEmpty` unless all object versions are deleted (or the bucket is created with `force_destroy = true`).
- GCP Terraform requires project billing to be enabled to activate services like `container.googleapis.com` and `compute.googleapis.com`, and some org policies (notably `constraints/iam.disableServiceAccountKeyCreation`) can block creation of the HMAC keys used for S3-compat storage bindings.
