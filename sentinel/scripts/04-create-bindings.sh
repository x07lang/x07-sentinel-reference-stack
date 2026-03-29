#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/lib.sh"

mkdir -p "${OUT_DIR}/rendered/bindings"

for template in "${SENTINEL_DIR}"/payloads/bindings/*.template.json; do
  out="${OUT_DIR}/rendered/bindings/$(basename "${template%.template.json}.json")"
  render_envsubst "${template}" "${out}"
  api_post_json "/v1/bindings" "$(cat "${out}")" | tee "${out%.json}.response.json" >/dev/null
done

echo "Bindings created."
