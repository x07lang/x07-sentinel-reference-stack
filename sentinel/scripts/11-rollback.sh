#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/lib.sh"

require_env CLOUD_API_BASE_URL
require_env ACCESS_TOKEN
require_env ROLLBACK_RELEASE_ID

api_post_json "/v1/releases/${ROLLBACK_RELEASE_ID}/rollback" '{"reason_code":"operator_requested","notes":"reference stack rollback"}' | tee "${OUT_DIR}/rollback.response.json"
