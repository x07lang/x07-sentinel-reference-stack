#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "usage: $0 <baseline-path>" >&2
  exit 2
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
PROJECT_DIR="${ROOT_DIR}/apps/order-domain"
BASELINE_PATH="$1"

cd "${PROJECT_DIR}"
mkdir -p target/review

x07 review diff \
  --from "${BASELINE_PATH}" \
  --to . \
  --mode project \
  --json-out target/review/order-domain.diff.json \
  --html-out target/review/order-domain.diff.html
