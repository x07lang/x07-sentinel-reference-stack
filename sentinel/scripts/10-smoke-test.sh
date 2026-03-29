#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/lib.sh"

require_env TARGET_BASE_URL
require_env NAMESPACE

curl -fsS "${TARGET_BASE_URL}/readyz" >/dev/null || {
  echo "API readiness check failed" >&2
  exit 1
}

echo "API readiness OK"

if command -v kubectl >/dev/null 2>&1; then
  kubectl -n "${NAMESPACE}" get deploy,po,svc,ingress,cronjob,job,hpa || true
fi

echo
echo "Manual follow-up:"
echo "  curl -fsS -X POST ${TARGET_BASE_URL}/orders -H 'content-type: application/json' --data '{\"customer_id\":\"cust_42\",\"currency\":\"USD\",\"total_minor\":1299}' | jq ."
echo "  curl -fsS ${TARGET_BASE_URL}/orders | jq ."
echo "  curl -fsS ${TARGET_BASE_URL}/reports/latest | jq ."
