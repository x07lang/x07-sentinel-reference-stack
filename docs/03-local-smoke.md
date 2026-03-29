# Local smoke (no cloud spend)

This repo includes a local, Docker-based smoke path that exercises the same bindings and service shapes without provisioning AWS or GCP.

It brings up:
- PostgreSQL
- RabbitMQ (AMQP)
- MinIO (S3-compatible)
- OpenTelemetry Collector (OTLP HTTP)

Then it runs:
- `orders-api`
- `orders-consumer`
- `reconciliation-job`

## Prerequisites

- `docker` with `docker compose`
- `jq`

## Run

From the repo root:

```sh
make local-smoke
```

On Apple Silicon, you can build native images with:

```sh
DOCKER_PLATFORM=linux/arm64 make local-smoke
```

If you want to inspect the running stack after the smoke completes:

```sh
KEEP=1 bash scripts/local/smoke.sh
```

Then tear down:

```sh
make local-down
```

## What it verifies

- `POST /orders` creates an order row in Postgres
- `orders-consumer` processes the `orders.created` lane and writes a projection row
- `reconciliation-job` writes a report JSON to S3-compatible storage and records metadata
- `GET /reports/latest` returns the newest report
