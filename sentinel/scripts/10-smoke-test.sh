#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/lib.sh"

require_env TARGET_BASE_URL
require_env NAMESPACE

CURL_INSECURE="${CURL_INSECURE:-0}"
curl_args=(-fsS)
if [[ "${CURL_INSECURE}" == "1" ]]; then
  curl_args+=(-k)
fi

base_url="${TARGET_BASE_URL%/}"
if command -v kubectl >/dev/null 2>&1 && command -v jq >/dev/null 2>&1; then
  ingress_json="$(kubectl -n "${NAMESPACE}" get ingress -o json 2>/dev/null || true)"
  ingress_path="$(jq -r '
    (
      [.items[] | select(.metadata.name | test("orders-api"))][0].spec.rules[0].http.paths[0].path
      // .items[0].spec.rules[0].http.paths[0].path
      // empty
    )
  ' <<<"${ingress_json}")"
  if [[ -n "${ingress_path}" && "${ingress_path}" != "null" && "${ingress_path}" != "/" ]]; then
    base_url="${base_url}${ingress_path%/}"
  fi
fi

curl "${curl_args[@]}" "${base_url}/readyz" >/dev/null || {
  echo "API readiness check failed" >&2
  exit 1
}

echo "API readiness OK"

if command -v kubectl >/dev/null 2>&1; then
  kubectl -n "${NAMESPACE}" get deploy,po,svc,ingress,cronjob,job,hpa || true
fi

echo
echo "Manual follow-up:"
if [[ "${CURL_INSECURE}" == "1" ]]; then
  echo "  curl -k -fsS -X POST ${base_url}/orders -H 'content-type: application/json' --data '{\"customer_id\":\"cust_42\",\"currency\":\"USD\",\"total_minor\":1299}' | jq ."
  echo "  curl -k -fsS ${base_url}/orders | jq ."
  echo "  curl -k -fsS ${base_url}/reports/latest | jq ."
else
  echo "  curl -fsS -X POST ${base_url}/orders -H 'content-type: application/json' --data '{\"customer_id\":\"cust_42\",\"currency\":\"USD\",\"total_minor\":1299}' | jq ."
  echo "  curl -fsS ${base_url}/orders | jq ."
  echo "  curl -fsS ${base_url}/reports/latest | jq ."
fi
