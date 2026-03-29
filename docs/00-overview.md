# Overview

This repository is the canonical public example for **deploying x07 services to Sentinel on customer infrastructure**.

It focuses on one small backend system: **order intake and reconciliation**.

## Services

### `orders-api`
A native x07 HTTP service adapted from the current Sentinel preprod API example.

Responsibilities:
- create and list orders
- persist order state to PostgreSQL
- emit an outbox-style record
- expose health and readiness endpoints
- optionally write report artifacts to object storage

### `orders-consumer`
A native x07 worker adapted from the current Sentinel preprod consumer example.

Responsibilities:
- prove AMQP + database binding wiring
- expose readiness/liveness behavior that Sentinel can roll out safely
- provide the scaffold where a real `order.created` consumer loop belongs

### `reconciliation-job`
A native x07 scheduled worker adapted from the current Sentinel preprod cron job example.

Responsibilities:
- run on a schedule
- reconcile order data and write report metadata
- prove scheduled-job deployment shape through Sentinel

## Shared contracts

`apps/order-domain/` contains shared contract artifacts for:
- order payload shape
- event envelope shape
- reconciliation report metadata

In the initial public release these are JSON schemas and conventions, not a finished shared x07 package.

## Bindings used in the tutorial

Use these names consistently across clouds:
- `db.primary`
- `msg.orders`
- `obj.reports`
- `telemetry.otlp`
