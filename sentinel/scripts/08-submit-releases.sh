#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/lib.sh"

for name in CLOUD_API_BASE_URL ACCESS_TOKEN ENVIRONMENT_ID TARGET_ID; do
  require_env "${name}"
done

export ORDERS_API_WORKLOAD_ID="${ORDERS_API_WORKLOAD_ID:-orders_api}"
export ORDERS_CONSUMER_WORKLOAD_ID="${ORDERS_CONSUMER_WORKLOAD_ID:-orders_consumer}"
export RECONCILIATION_JOB_WORKLOAD_ID="${RECONCILIATION_JOB_WORKLOAD_ID:-reconciliation_job}"

export ORDERS_API_PACK_DIGEST="$(cat "${OUT_DIR}/pack/${ORDERS_API_WORKLOAD_ID}/pack.digest")"
export ORDERS_CONSUMER_PACK_DIGEST="$(cat "${OUT_DIR}/pack/${ORDERS_CONSUMER_WORKLOAD_ID}/pack.digest")"
export RECONCILIATION_JOB_PACK_DIGEST="$(cat "${OUT_DIR}/pack/${RECONCILIATION_JOB_WORKLOAD_ID}/pack.digest")"

mkdir -p "${OUT_DIR}/rendered/releases"

submit_one() {
  local template="$1"
  local rendered="${OUT_DIR}/rendered/releases/$(basename "${template%.template.json}.json")"
  render_envsubst "${template}" "${rendered}"
  local response
  response="$(api_post_json "/v1/releases/submit" "$(cat "${rendered}")")"
  echo "${response}" | tee "${rendered%.json}.response.json" >/dev/null
}

for template in "${SENTINEL_DIR}"/payloads/releases/*.template.json; do
  submit_one "${template}"
done

echo "Release submit complete."
