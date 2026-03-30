#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/lib.sh"

for name in CLOUD_API_BASE_URL ACCESS_TOKEN TARGET_ID TARGET_DISPLAY_NAME TARGET_BASE_URL CLUSTER_REF NAMESPACE; do
  require_env "${name}"
done

normalize_target_base_url() {
  local url="$1"
  case "${url}" in
    http://127.0.0.1*|http://localhost*)
      printf '%s' "${url}"
      return 0
      ;;
    http://*)
      printf 'https://%s' "${url#http://}"
      return 0
      ;;
    https://*)
      printf '%s' "${url}"
      return 0
      ;;
    *)
      echo "invalid TARGET_BASE_URL (expected http(s)://...): ${url}" >&2
      exit 2
      ;;
  esac
}

TARGET_BASE_URL="$(normalize_target_base_url "${TARGET_BASE_URL}")"
export TARGET_BASE_URL

render_envsubst "${SENTINEL_DIR}/payloads/targets/k8s-target.template.json" "${OUT_DIR}/rendered/target.json"
target_detail_status="$(api_get_status "/v1/targets/${TARGET_ID}")"
if [[ "${target_detail_status}" == "200" ]]; then
  target_patch="$(jq '{display_name, status, profile_json, capabilities_json}' "${OUT_DIR}/rendered/target.json")"
  api_patch_json "/v1/targets/${TARGET_ID}" "${target_patch}" | tee "${OUT_DIR}/target.patch.json" >/dev/null
else
  if [[ "${target_detail_status}" != "404" ]]; then
    echo "unexpected target detail status: ${target_detail_status}" >&2
    exit 2
  fi
  api_post_json "/v1/targets" "$(cat "${OUT_DIR}/rendered/target.json")" | tee "${OUT_DIR}/target.create.json" >/dev/null
fi
curl -fsS -X POST "${CLOUD_API_BASE_URL}/v1/targets/${TARGET_ID}/validate"   -H "Authorization: Bearer ${ACCESS_TOKEN}" | tee "${OUT_DIR}/target.validate.json"
