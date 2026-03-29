#!/usr/bin/env bash

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SENTINEL_DIR="${ROOT_DIR}/sentinel"
OUT_DIR="${ROOT_DIR}/out"
mkdir -p "${OUT_DIR}"

require_env() {
  local name="$1"
  if [[ -z "${!name:-}" ]]; then
    echo "missing required env: ${name}" >&2
    exit 2
  fi
}

api_get() {
  local path="$1"
  curl -fsS "${CLOUD_API_BASE_URL}${path}"     -H "Authorization: Bearer ${ACCESS_TOKEN}"
}

api_post_json() {
  local path="$1"
  local data="$2"
  curl -fsS -X POST "${CLOUD_API_BASE_URL}${path}"     -H "Authorization: Bearer ${ACCESS_TOKEN}"     -H 'content-type: application/json'     --data "${data}"
}

api_put_json() {
  local path="$1"
  local data="$2"
  curl -fsS -X PUT "${CLOUD_API_BASE_URL}${path}"     -H "Authorization: Bearer ${ACCESS_TOKEN}"     -H 'content-type: application/json'     --data "${data}"
}

api_put_blob() {
  local sha="$1"
  local file_path="$2"
  curl -fsS -X PUT "${CLOUD_API_BASE_URL}/v1/cas/objects/sha256/${sha}"     -H "Authorization: Bearer ${ACCESS_TOKEN}"     -H 'content-type: application/octet-stream'     -H "x-logical-name: $(basename "${file_path}")"     --data-binary @"${file_path}" >/dev/null
}

render_envsubst() {
  local src="$1"
  local dst="$2"
  mkdir -p "$(dirname "${dst}")"
  envsubst <"${src}" >"${dst}"
}

sha256_file() {
  sha256sum "$1" | awk '{print $1}'
}
