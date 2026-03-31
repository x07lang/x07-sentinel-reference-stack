#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

echo "x07: $(command -v x07)"
x07 --version

run_service_tests() {
  local service="$1"
  local project_dir="${ROOT_DIR}/apps/${service}"
  cd "${project_dir}"
  mkdir -p target/test
  x07 pkg lock --project x07.json >/dev/null
  x07 test --all --manifest tests/tests.json > "target/test/runtime.tests.json"
}

run_service_tests orders-api
run_service_tests orders-consumer
run_service_tests reconciliation-job
