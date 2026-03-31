# x07 guide map for the Sentinel reference stack

This page maps the Sentinel reference stack back to the official x07 guides so users can learn the concepts in the same order the repo uses them.

The repo teaches two things at once:

1. how to deploy a small x07 system through Sentinel
2. how to reason about that system using x07’s higher-level primitives and contracts

## Start here

Read these first:

- x07 agent quickstart: <https://x07lang.org/docs/getting-started/agent-quickstart>
- x07 agent initial prompt: <https://x07lang.org/docs/getting-started/agent-initial-prompt>
- x07 service architecture vocabulary: <https://github.com/x07lang/x07/blob/main/docs/guides/x07-service-architecture-v1.md>

Those three docs explain the words used throughout this repo:
- Domain Pack
- Operational Cell
- boundaries
- budgets
- deterministic generation and review

## Guides most directly used by this repo

### Provider-agnostic backend system design
- Provider-agnostic services: <https://x07lang.org/docs/guides/provider-agnostic-services>
- Service binding migration: <https://x07lang.org/docs/guides/service-binding-migration>
- Databases: <https://x07lang.org/docs/guides/databases>
- Messaging: <https://x07lang.org/docs/guides/messaging>
- Networking: <https://x07lang.org/docs/guides/networking>
- Scaling / retry / idempotency: <https://x07lang.org/docs/guides/scaling-retry-idempotency>
- Performance tuning: <https://x07lang.org/docs/guides/performance-tuning>

### Pure-core and kernel/shell discipline
- Extract core: <https://x07lang.org/docs/guides/extract-core>
- Kernel / shell production: <https://x07lang.org/docs/guides/kernel-shell-production>
- Data interop: <https://x07lang.org/docs/guides/data-interop>

## Guides that are adjacent, but still useful

These are not the core of this backend reference stack, but they help users understand the wider x07 ecosystem and design vocabulary:

- CLI apps: <https://x07lang.org/docs/guides/cli-apps>
- Crawling: <https://x07lang.org/docs/guides/crawling>
- Web apps: <https://x07lang.org/docs/guides/web-apps>

## How the docs map to this repo

### `apps/order-domain/`
Use this repo path together with:
- Extract core
- Data interop
- Performance tuning
- x07 service architecture vocabulary

### `apps/orders-api/`
Use this repo path together with:
- Provider-agnostic services
- Databases
- Networking
- Scaling / retry / idempotency

### `apps/orders-consumer/`
Use this repo path together with:
- Messaging
- Scaling / retry / idempotency
- Kernel / shell production

### `apps/reconciliation-job/`
Use this repo path together with:
- Provider-agnostic services
- Databases
- Performance tuning

### `sentinel/` and `docs/20-*` onward
Use this repo path together with:
- Provider-agnostic services
- Service binding migration
- x07 service architecture vocabulary

## Suggested reading order for enterprise users

### Developers
1. agent quickstart
2. x07 service architecture vocabulary
3. provider-agnostic services
4. databases
5. messaging
6. scaling / retry / idempotency
7. docs/27-order-domain-primitives.md
8. docs/28-contract-locks-and-review.md

### Platform / DevOps teams
1. x07 service architecture vocabulary
2. provider-agnostic services
3. service binding migration
4. networking
5. performance tuning
6. docs/20-sentinel-onboarding.md through docs/25-audit-and-incidents.md

### Security / review-oriented readers
1. x07 service architecture vocabulary
2. extract core
3. data interop
4. docs/26-verification.md
5. docs/27-order-domain-primitives.md
6. docs/28-contract-locks-and-review.md
