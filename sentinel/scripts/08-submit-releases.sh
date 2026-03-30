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

ensure_idempotency_run_id
run_dir="${OUT_DIR}/rendered/releases/${IDEMPOTENCY_RUN_ID}"
mkdir -p "${run_dir}"
release_ids=()

submit_one() {
  local template="$1"
  local rendered="${run_dir}/$(basename "${template%.template.json}.json")"
  render_envsubst "${template}" "${rendered}"
  local response
  response="$(api_post_json "/v1/releases/submit" "$(cat "${rendered}")")"
  echo "${response}" | tee "${rendered%.json}.response.json" >/dev/null
  local release_id
  release_id="$(jq -r '.release_id' <<<"${response}")"
  if [[ -z "${release_id}" || "${release_id}" == "null" ]]; then
    echo "missing release_id in submit response for: ${template}" >&2
    exit 2
  fi
  release_ids+=("${release_id}")
}

for template in "${SENTINEL_DIR}"/payloads/releases/*.template.json; do
  submit_one "${template}"
done

printf '%s\n' "${release_ids[@]}" >"${run_dir}/release_ids.txt"
printf '%s\n' "${release_ids[@]}" >"${OUT_DIR}/rendered/releases/last_release_ids.txt"

echo "Release submit complete."
