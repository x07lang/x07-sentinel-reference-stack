#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

cd "${ROOT_DIR}/apps/order-domain"

x07 pkg lock --project x07.json >/dev/null
x07 verify --coverage --entry order.domain.parse_order_created_doc_v1 --project x07.json --json=pretty
