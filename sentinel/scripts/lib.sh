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

ensure_idempotency_run_id() {
  if [[ -n "${IDEMPOTENCY_RUN_ID:-}" ]]; then
    return 0
  fi
  if command -v uuidgen >/dev/null 2>&1; then
    IDEMPOTENCY_RUN_ID="$(uuidgen | tr -d '\n' | tr '[:upper:]' '[:lower:]')"
  elif command -v python3 >/dev/null 2>&1; then
    IDEMPOTENCY_RUN_ID="$(
      python3 - <<'PY'
import uuid
print(uuid.uuid4().hex)
PY
    )"
  else
    IDEMPOTENCY_RUN_ID="$(date +%s)"
  fi
  export IDEMPOTENCY_RUN_ID
}

sha256_hex() {
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum | awk '{print $1}'
    return 0
  fi
  if command -v shasum >/dev/null 2>&1; then
    shasum -a 256 | awk '{print $1}'
    return 0
  fi
  if command -v openssl >/dev/null 2>&1; then
    openssl dgst -sha256 | awk '{print $NF}'
    return 0
  fi
  echo "missing sha256 tool: sha256sum/shasum/openssl" >&2
  exit 2
}

idempotency_key() {
  local method="$1"
  local path="$2"
  local data="${3:-}"
  ensure_idempotency_run_id
  local digest
  digest="$(printf '%s' "${method}|${path}|${data}" | sha256_hex)"
  printf 'idem_%s_%s' "${IDEMPOTENCY_RUN_ID}" "${digest}"
}

api_get() {
  local path="$1"
  curl -fsS "${CLOUD_API_BASE_URL}${path}"     -H "Authorization: Bearer ${ACCESS_TOKEN}"
}

api_post_json() {
  local path="$1"
  local data="$2"
  local idem
  idem="$(idempotency_key "POST" "${path}" "${data}")"
  curl -fsS -X POST "${CLOUD_API_BASE_URL}${path}"     -H "Authorization: Bearer ${ACCESS_TOKEN}"     -H "Idempotency-Key: ${idem}"     -H 'content-type: application/json'     --data "${data}"
}

api_put_json() {
  local path="$1"
  local data="$2"
  local idem
  idem="$(idempotency_key "PUT" "${path}" "${data}")"
  curl -fsS -X PUT "${CLOUD_API_BASE_URL}${path}"     -H "Authorization: Bearer ${ACCESS_TOKEN}"     -H "Idempotency-Key: ${idem}"     -H 'content-type: application/json'     --data "${data}"
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
  local path="$1"
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "${path}" | awk '{print $1}'
    return 0
  fi
  if command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "${path}" | awk '{print $1}'
    return 0
  fi
  if command -v openssl >/dev/null 2>&1; then
    openssl dgst -sha256 "${path}" | awk '{print $NF}'
    return 0
  fi
  echo "missing sha256 tool: sha256sum/shasum/openssl" >&2
  exit 2
}
