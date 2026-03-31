#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
PROJECT_DIR="${ROOT_DIR}/apps/order-domain"

cd "${PROJECT_DIR}"
mkdir -p target/test

x07 pkg lock --project x07.json >/dev/null

dep_module_roots=()
while IFS= read -r dep_root; do
  dep_module_roots+=(--module-root "${dep_root}")
done < <(jq -r '.dependencies[] | "\(.path)/\(.module_root)"' x07.lock.json)

x07 test --all --manifest tests/tests.json > target/test/order-domain.tests.json
x07 test --manifest .generated/schema/order_created/tests/tests.json --module-root .generated/schema/order_created/modules "${dep_module_roots[@]}" > target/test/order-created.derived.tests.json
x07 test --manifest .generated/schema/reconciliation_report/tests/tests.json --module-root .generated/schema/reconciliation_report/modules "${dep_module_roots[@]}" > target/test/reconciliation-report.derived.tests.json
x07 test --manifest .generated/gen/sm/tests.manifest.json --module-root .generated --module-root modules "${dep_module_roots[@]}" > target/test/order-lifecycle.sm.tests.json
