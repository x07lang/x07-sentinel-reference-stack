#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
PROJECT_DIR="${ROOT_DIR}/apps/order-domain"

cd "${PROJECT_DIR}"
mkdir -p target/arch

bash ci/generate_contracts.sh

x07 arch check \
  --manifest arch/manifest.x07arch.json \
  --lock arch/manifest.lock.json \
  --format json \
  --out target/arch/arch-check.json
