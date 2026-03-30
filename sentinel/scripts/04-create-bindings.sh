#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/lib.sh"

mkdir -p "${OUT_DIR}/rendered/bindings"

find_binding_id_by_name_kind() {
  local binding_name="$1"
  local binding_kind="$2"
  local list_json
  list_json="$(api_get "/v1/bindings")"
  local matches
  matches="$(jq -r --arg name "${binding_name}" --arg kind "${binding_kind}" '.items[] | select(.name == $name and .kind == $kind) | .binding_id' <<<"${list_json}")"
  if [[ -z "${matches}" || "${matches}" == "null" ]]; then
    return 1
  fi
  local count
  count="$(wc -l <<<"${matches}" | tr -d ' ')"
  if [[ "${count}" != "1" ]]; then
    echo "multiple bindings match name=${binding_name} kind=${binding_kind}; delete extras and retry" >&2
    printf '%s\n' "${matches}" >&2
    exit 2
  fi
  printf '%s' "${matches}"
}

for template in "${SENTINEL_DIR}"/payloads/bindings/*.template.json; do
  out="${OUT_DIR}/rendered/bindings/$(basename "${template%.template.json}.json")"
  render_envsubst "${template}" "${out}"
  binding_name="$(jq -r '.name' "${out}")"
  binding_kind="$(jq -r '.kind' "${out}")"
  binding_id="$(jq -r '.binding_id // empty' "${out}")"

  if [[ -n "${binding_id}" && "${binding_id}" != "null" ]]; then
    binding_detail_status="$(api_get_status "/v1/bindings/${binding_id}")"
    if [[ "${binding_detail_status}" == "200" ]]; then
      binding_patch="$(jq '{provider_kind, config_summary, secret_ref_json, status, message}' "${out}")"
      api_patch_json "/v1/bindings/${binding_id}" "${binding_patch}" | tee "${out%.json}.patch.response.json" >/dev/null
      continue
    fi
    if [[ "${binding_detail_status}" != "404" ]]; then
      echo "unexpected binding detail status for ${binding_id}: ${binding_detail_status}" >&2
      exit 2
    fi
    api_post_json "/v1/bindings" "$(cat "${out}")" | tee "${out%.json}.create.response.json" >/dev/null
    continue
  fi

  existing_binding_id=""
  if existing_binding_id="$(find_binding_id_by_name_kind "${binding_name}" "${binding_kind}")"; then
    binding_patch="$(jq '{provider_kind, config_summary, secret_ref_json, status, message}' "${out}")"
    api_patch_json "/v1/bindings/${existing_binding_id}" "${binding_patch}" | tee "${out%.json}.patch.response.json" >/dev/null
    continue
  fi

  api_post_json "/v1/bindings" "$(cat "${out}")" | tee "${out%.json}.create.response.json" >/dev/null
done

echo "Bindings created."
