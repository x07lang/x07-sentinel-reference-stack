#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
STDLIB_LOCK="${STDLIB_LOCK:-${ROOT_DIR}/apps/order-domain/stdlib.lock}"

if [[ ! -f "${STDLIB_LOCK}" ]]; then
  echo "missing stdlib lock file: ${STDLIB_LOCK}" >&2
  exit 2
fi

echo "x07: $(command -v x07)"
x07 --version

run_service_tests() {
  local service="$1"
  local project_dir="${ROOT_DIR}/apps/${service}"
  cd "${project_dir}"
  mkdir -p target/test
  x07 pkg lock --project x07.json >/dev/null
  x07 test --stdlib-lock "${STDLIB_LOCK}" --all --manifest tests/tests.json > "target/test/runtime.tests.json"
}

run_service_tests orders-api
run_service_tests orders-consumer
run_service_tests reconciliation-job
