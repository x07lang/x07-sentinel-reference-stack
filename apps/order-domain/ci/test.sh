#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
PROJECT_DIR="${ROOT_DIR}/apps/order-domain"

cd "${PROJECT_DIR}"
mkdir -p target/test

x07 pkg lock --project x07.json >/dev/null
x07 test --all --manifest tests/tests.json > target/test/order-domain.tests.json
x07 test --manifest gen/schema/order_created/tests/tests.json > target/test/order-created.derived.tests.json
x07 test --manifest gen/schema/reconciliation_report/tests/tests.json > target/test/reconciliation-report.derived.tests.json
x07 test --manifest gen/sm/tests.manifest.json > target/test/order-lifecycle.sm.tests.json
