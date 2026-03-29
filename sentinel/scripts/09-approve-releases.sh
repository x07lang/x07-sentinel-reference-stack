#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/lib.sh"

require_env CLOUD_API_BASE_URL
require_env ACCESS_TOKEN

for response in "${OUT_DIR}"/rendered/releases/*.response.json; do
  [[ -f "${response}" ]] || continue
  release_id="$(jq -r '.release_id' "${response}")"
  curl -fsS -X POST "${CLOUD_API_BASE_URL}/v1/releases/${release_id}/approve"     -H "Authorization: Bearer ${ACCESS_TOKEN}"     -H 'content-type: application/json'     --data '{"notes":"approve reference stack"}' >/dev/null
  echo "Approved ${release_id}"
done
