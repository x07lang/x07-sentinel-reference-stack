#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
PROJECT_DIR="${ROOT_DIR}/apps/order-domain"

cd "${PROJECT_DIR}"
mkdir -p target/trust

x07 pkg lock --project x07.json >/dev/null

x07 trust profile check   --profile arch/trust/profiles/verified_core_pure_v1.json   --project x07.json   --entry order.core.missing_projection_count_v1 > target/trust/profile-check.json

x07 trust report   --project x07.json   --out target/trust/report.json   --html-out target/trust/report.html   --sbom-format cyclonedx
