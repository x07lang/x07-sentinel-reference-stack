# orders-api

HTTP service for the reference stack.

This service is adapted from the current Sentinel preprod API example so the public repo stays aligned with a known-good deployment shape.

## What it demonstrates today
- native x07 HTTP runtime image
- PostgreSQL-backed API behavior
- health and readiness endpoints
- a concrete API-cell workload for Sentinel

## Binding expectations
- `db.primary` (required)
- `obj.reports` (optional in the current public skeleton)
- `telemetry.otlp` (recommended)
