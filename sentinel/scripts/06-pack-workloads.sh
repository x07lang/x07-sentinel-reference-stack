#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/lib.sh"

source "${OUT_DIR}/images/images.env"

if ! x07 wasm --help >/dev/null 2>&1; then
  echo "missing x07-wasm component; install it with: x07up component add wasm" >&2
  exit 2
fi

pack_service() {
  local app_dir="$1"
  local workload_id="$2"
  local runtime_image="$3"
  local out_dir="${OUT_DIR}/pack/${workload_id}"

  mkdir -p "${out_dir}"
  local tmp_root
  tmp_root="$(mktemp -d)"
  local tmp_app_dir="${tmp_root}/${app_dir}"
  mkdir -p "${tmp_app_dir}"
  cp -R "${ROOT_DIR}/apps/${app_dir}/." "${tmp_app_dir}/"
  cp -R "${ROOT_DIR}/apps/order-domain" "${tmp_root}/order-domain"

  tmp_manifest="$(mktemp)"
  jq --arg workload_id "${workload_id}" '
    .service_id = $workload_id |
    .display_name = $workload_id |
    .domain_pack.id = $workload_id |
    .domain_pack.display_name = $workload_id
  ' "${tmp_app_dir}/arch/service/index.x07service.json" >"${tmp_manifest}"
  mv "${tmp_manifest}" "${tmp_app_dir}/arch/service/index.x07service.json"

  tmp_arch="$(mktemp)"
  jq --arg workload_id "${workload_id}" '.repo.id = $workload_id' "${tmp_app_dir}/arch/manifest.x07arch.json" >"${tmp_arch}"
  mv "${tmp_arch}" "${tmp_app_dir}/arch/manifest.x07arch.json"

  tmp_policy="$(mktemp)"
  jq --arg workload_id "${workload_id}" '.policy_id = $workload_id' "${tmp_app_dir}/policy/run-os.json" >"${tmp_policy}"
  mv "${tmp_policy}" "${tmp_app_dir}/policy/run-os.json"

  (cd "${tmp_app_dir}" &&     x07 wasm workload pack       --project x07.json       --manifest arch/service/index.x07service.json       --out-dir "${out_dir}"       --runtime-image "${runtime_image}"       --container-port 8080       --json pretty       --quiet-json)

  local pack_path="${out_dir}/x07.workload.pack.json"
  local digest
  digest="$(sha256_file "${pack_path}")"
  echo "${digest}" >"${out_dir}/pack.digest"
}

ORDERS_API_WORKLOAD_ID="${ORDERS_API_WORKLOAD_ID:-orders_api}"
ORDERS_CONSUMER_WORKLOAD_ID="${ORDERS_CONSUMER_WORKLOAD_ID:-orders_consumer}"
RECONCILIATION_JOB_WORKLOAD_ID="${RECONCILIATION_JOB_WORKLOAD_ID:-reconciliation_job}"

pack_service "orders-api" "${ORDERS_API_WORKLOAD_ID}" "${ORDERS_API_IMAGE}"
pack_service "orders-consumer" "${ORDERS_CONSUMER_WORKLOAD_ID}" "${ORDERS_CONSUMER_IMAGE}"
pack_service "reconciliation-job" "${RECONCILIATION_JOB_WORKLOAD_ID}" "${RECONCILIATION_JOB_IMAGE}"

echo "Workload packs created under ${OUT_DIR}/pack"
