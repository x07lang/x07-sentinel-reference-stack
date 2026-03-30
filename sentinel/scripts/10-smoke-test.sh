#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/lib.sh"

require_env TARGET_BASE_URL
require_env NAMESPACE

CURL_INSECURE="${CURL_INSECURE:-0}"
SMOKE_WAIT_SECONDS="${SMOKE_WAIT_SECONDS:-180}"
SMOKE_POLL_SECONDS="${SMOKE_POLL_SECONDS:-3}"
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

echo "Waiting for API readiness"
deadline="$(( $(date +%s) + SMOKE_WAIT_SECONDS ))"
while true; do
  if (( $(date +%s) >= deadline )); then
    echo "timed out waiting for API readiness" >&2
    curl "${curl_args[@]}" "${base_url}/readyz" >&2 || true
    exit 1
  fi
  if curl "${curl_args[@]}" "${base_url}/readyz" >/dev/null 2>&1; then
    break
  fi
  sleep "${SMOKE_POLL_SECONDS}"
done
echo "API readiness OK"

if command -v kubectl >/dev/null 2>&1; then
  kubectl -n "${NAMESPACE}" get deploy,po,svc,ingress,cronjob,job,hpa || true
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "missing jq; cannot run full smoke checks" >&2
  exit 2
fi

echo "Creating an order"
order_resp="$(
  curl "${curl_args[@]}" -X POST "${base_url}/orders" \
    -H 'content-type: application/json' \
    --data '{"customer_id":"cust_smoke","currency":"USD","total_minor":1299}'
)"
order_id="$(jq -r '.id // .order.id // empty' <<<"${order_resp}")"
if [[ -z "${order_id}" || "${order_id}" == "null" ]]; then
  echo "POST /orders did not return an id:" >&2
  echo "${order_resp}" >&2
  exit 1
fi
echo "order_id=${order_id}"

echo "Waiting for consumer projection"
deadline="$(( $(date +%s) + SMOKE_WAIT_SECONDS ))"
while true; do
  if (( $(date +%s) >= deadline )); then
    echo "timed out waiting for consumer projection" >&2
    curl "${curl_args[@]}" "${base_url}/orders/${order_id}" | jq . >&2 || true
    exit 1
  fi
  o="$(curl "${curl_args[@]}" "${base_url}/orders/${order_id}" 2>/dev/null || true)"
  if [[ -n "${o}" ]] && jq -e '.projection.status == "consumed"' >/dev/null 2>&1 <<<"${o}"; then
    break
  fi
  sleep "${SMOKE_POLL_SECONDS}"
done
echo "Consumer projection OK"

if command -v kubectl >/dev/null 2>&1; then
  if kubectl -n "${NAMESPACE}" get cronjob reconciliation-job >/dev/null 2>&1; then
    job_name="reconciliation-smoke-$(date +%s)"
    echo "Starting reconciliation job (${job_name})"
    kubectl -n "${NAMESPACE}" create job --from=cronjob/reconciliation-job "${job_name}" >/dev/null
    if ! kubectl -n "${NAMESPACE}" wait --for=condition=complete "job/${job_name}" --timeout=5m >/dev/null; then
      kubectl -n "${NAMESPACE}" get job "${job_name}" -o wide || true
      kubectl -n "${NAMESPACE}" describe job "${job_name}" || true
      exit 1
    fi
    echo "Reconciliation job OK"
  fi
fi

echo "Fetching latest report"
deadline="$(( $(date +%s) + SMOKE_WAIT_SECONDS ))"
while true; do
  if (( $(date +%s) >= deadline )); then
    echo "timed out waiting for latest report" >&2
    curl "${curl_args[@]}" "${base_url}/reports/latest" | jq . >&2 || true
    exit 1
  fi
  report="$(curl "${curl_args[@]}" "${base_url}/reports/latest" 2>/dev/null || true)"
  if [[ -n "${report}" ]] && jq -e '.ok == true' >/dev/null 2>&1 <<<"${report}"; then
    break
  fi
  sleep "${SMOKE_POLL_SECONDS}"
done
echo "Latest report OK"

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
