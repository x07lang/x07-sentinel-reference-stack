#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
PROJECT_DIR="${ROOT_DIR}/apps/order-domain"

cd "${PROJECT_DIR}"
mkdir -p target/verify/coverage target/verify/prove

x07 pkg lock --project x07.json >/dev/null

x07 verify --coverage   --project x07.json   --entry order.core.missing_projection_count_v1   --json=pretty > target/verify/coverage/report.json

x07 verify --prove   --project x07.json   --entry order.core.missing_projection_count_v1   --emit-proof target/verify/prove/proof.json   --json=pretty > target/verify/prove/report.json

x07 prove check --proof target/verify/prove/proof.json > target/verify/prove/proof-check.json
