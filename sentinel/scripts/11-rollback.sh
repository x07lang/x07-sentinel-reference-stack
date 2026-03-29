#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/lib.sh"

require_env CLOUD_API_BASE_URL
require_env ACCESS_TOKEN
require_env ROLLBACK_RELEASE_ID

curl -fsS -X POST "${CLOUD_API_BASE_URL}/v1/releases/${ROLLBACK_RELEASE_ID}/rollback"   -H "Authorization: Bearer ${ACCESS_TOKEN}"   -H 'content-type: application/json'   --data '{"reason_code":"operator_requested","notes":"reference stack rollback"}' | tee "${OUT_DIR}/rollback.response.json"
