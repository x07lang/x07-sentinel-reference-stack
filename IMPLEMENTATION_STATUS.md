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
