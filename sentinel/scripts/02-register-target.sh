#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/lib.sh"

for name in CLOUD_API_BASE_URL ACCESS_TOKEN TARGET_ID TARGET_DISPLAY_NAME TARGET_BASE_URL CLUSTER_REF NAMESPACE; do
  require_env "${name}"
done

render_envsubst "${SENTINEL_DIR}/payloads/targets/k8s-target.template.json" "${OUT_DIR}/rendered/target.json"
api_post_json "/v1/targets" "$(cat "${OUT_DIR}/rendered/target.json")" | tee "${OUT_DIR}/target.create.json"
curl -fsS -X POST "${CLOUD_API_BASE_URL}/v1/targets/${TARGET_ID}/validate"   -H "Authorization: Bearer ${ACCESS_TOKEN}" | tee "${OUT_DIR}/target.validate.json"
