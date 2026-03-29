#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/lib.sh"

for name in CLOUD_API_BASE_URL ACCESS_TOKEN; do
  require_env "${name}"
done

upload_pack_dir() {
  local dir="$1"
  local pack_path="${dir}/x07.workload.pack.json"
  local pack_digest
  pack_digest="$(cat "${dir}/pack.digest")"
  local runtime_pack
  runtime_pack="$(cat "${pack_path}")"

  local digests_json
  digests_json="$(jq -c --arg pack_digest "${pack_digest}" '
    {
      digests: (
        [
          $pack_digest,
          (.public_manifest.sha256),
          (.workload.sha256),
          (.binding_requirements.sha256),
          (.topology[]?.sha256),
          (.sources[]?.sha256)
        ] | map(select(. != null)) | unique
      )
    }
  ' <<<"${runtime_pack}")"

  api_post_json "/v1/cas/check" "${digests_json}" >/dev/null
  api_put_blob "${pack_digest}" "${pack_path}"

  jq -r '
    [
      (.public_manifest | [.path, .sha256]),
      (.workload | [.path, .sha256]),
      (.binding_requirements | [.path, .sha256]),
      (.topology[]? | [.path, .sha256]),
      (.sources[]? | [.path, .sha256])
    ][] | @tsv
  ' <<<"${runtime_pack}" | while IFS=$'\t' read -r ref_path ref_sha; do
    api_put_blob "${ref_sha}" "${dir}/${ref_path}"
  done
}

for dir in "${OUT_DIR}"/pack/*; do
  [[ -d "${dir}" ]] || continue
  upload_pack_dir "${dir}"
done

echo "CAS upload complete."
