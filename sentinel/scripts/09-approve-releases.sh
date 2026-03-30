#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/lib.sh"

require_env CLOUD_API_BASE_URL
require_env ACCESS_TOKEN

approve_one() {
  local release_id="$1"
  if [[ -z "${release_id}" || "${release_id}" == "null" ]]; then
    echo "invalid release_id: ${release_id}" >&2
    exit 2
  fi
  api_post_json "/v1/releases/${release_id}/approve" '{"notes":"approve reference stack"}' >/dev/null
  echo "Approved ${release_id}"
}

ids_file="${OUT_DIR}/rendered/releases/last_release_ids.txt"
if [[ -f "${ids_file}" ]]; then
  while IFS= read -r release_id; do
    [[ -n "${release_id}" ]] || continue
    approve_one "${release_id}"
  done <"${ids_file}"
  exit 0
fi

for response in "${OUT_DIR}"/rendered/releases/*.response.json; do
  [[ -f "${response}" ]] || continue
  release_id="$(jq -r '.release_id' "${response}")"
  approve_one "${release_id}"
done
