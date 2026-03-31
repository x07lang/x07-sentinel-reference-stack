#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
PROJECT_DIR="${ROOT_DIR}/apps/order-domain"

cd "${PROJECT_DIR}"
mkdir -p gen/schema/order_created gen/schema/reconciliation_report gen/sm target/reports

x07 schema derive   --input schemas/order_created_v1.x07schema.json   --out-dir gen/schema/order_created   --write   --json=pretty > target/reports/schema-order_created.report.json

x07 schema derive   --input schemas/reconciliation_report_v1.x07schema.json   --out-dir gen/schema/reconciliation_report   --write   --json=pretty > target/reports/schema-reconciliation_report.report.json

x07 sm gen   --input arch/sm/specs/order_lifecycle.sm.json   --out gen/sm   --write   --json=pretty > target/reports/sm-order_lifecycle.report.json

x07 schema derive   --input schemas/order_created_v1.x07schema.json   --out-dir gen/schema/order_created   --check >/dev/null

x07 schema derive   --input schemas/reconciliation_report_v1.x07schema.json   --out-dir gen/schema/reconciliation_report   --check >/dev/null

x07 sm gen   --input arch/sm/specs/order_lifecycle.sm.json   --out gen/sm   --check >/dev/null
