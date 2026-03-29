# orders-consumer

Event consumer for the reference stack.

This worker is adapted from the current Sentinel preprod consumer example.

## What it demonstrates today
- native x07 worker runtime image
- AMQP + PostgreSQL binding wiring
- readiness and liveness probe behavior for Sentinel rollouts
- concrete event-consumer deployment shape

## Important note
In the first public skeleton, the consumer's business loop is still intentionally minimal. It is the first place to deepen domain semantics after the repo is published.
