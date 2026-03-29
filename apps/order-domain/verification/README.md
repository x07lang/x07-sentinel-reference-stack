# Verification notes

This directory is where the shared contract area can graduate into a formal pure/shared x07 package.

For the first public release, the repo keeps the verification story honest:
- the backend stack proves deployment, bindings, release control, rollback, and audit
- formal verification examples live alongside this directory:
  - verification project: `apps/order-domain/x07.json`
  - coverage script: `scripts/verify/run-coverage.sh`
