#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/lib.sh"

require_env CLOUD_API_BASE_URL
CLIENT_ID="${CLIENT_ID:-x07lp-cli}"
LOGIN_HINT="${LOGIN_HINT:-reference-stack@example.com}"
OUT_ENV_PATH="${OUT_ENV_PATH:-${OUT_DIR}/sentinel/access_token.env}"
PRINT_TOKEN="${PRINT_TOKEN:-0}"

tmp_device="$(mktemp)"
device_http="$(
  curl -sS -o "${tmp_device}" -w '%{http_code}' -X POST "${CLOUD_API_BASE_URL}/oauth/device/code" \
    -H 'content-type: application/x-www-form-urlencoded' \
    --data-urlencode "client_id=${CLIENT_ID}" \
    --data-urlencode "login_hint=${LOGIN_HINT}"
)"
device_json="$(cat "${tmp_device}")"
rm -f "${tmp_device}"

if [[ "${device_http}" != "200" ]]; then
  echo "device-code request failed (http ${device_http}): ${device_json}" >&2
  exit 2
fi

device_code="$(jq -r '.device_code // empty' <<<"${device_json}")"
user_code="$(jq -r '.user_code // empty' <<<"${device_json}")"
verification_uri="$(jq -r '.verification_uri // empty' <<<"${device_json}")"
verification_uri_complete="$(jq -r '.verification_uri_complete // empty' <<<"${device_json}")"
interval="$(jq -r '.interval // 5' <<<"${device_json}")"
expires_in="$(jq -r '.expires_in // 600' <<<"${device_json}")"

if [[ -z "${device_code}" || -z "${user_code}" || -z "${verification_uri}" ]]; then
  echo "unexpected device-code response: ${device_json}" >&2
  exit 2
fi

if [[ -z "${verification_uri_complete}" || "${verification_uri_complete}" == "null" ]]; then
  verification_uri_complete="${verification_uri}"
fi

echo "Complete sign-in:" >&2
echo "  ${verification_uri_complete}" >&2
echo "User code:" >&2
echo "  ${user_code}" >&2

deadline="$(( $(date +%s) + expires_in ))"
sleep_s="${interval}"

while true; do
  if (( $(date +%s) >= deadline )); then
    echo "timed out waiting for device-code approval" >&2
    exit 2
  fi

  tmp_token="$(mktemp)"
  token_http="$(
    curl -sS -o "${tmp_token}" -w '%{http_code}' -X POST "${CLOUD_API_BASE_URL}/oauth/token" \
      -H 'content-type: application/x-www-form-urlencoded' \
      --data-urlencode 'grant_type=urn:ietf:params:oauth:grant-type:device_code' \
      --data-urlencode "device_code=${device_code}" \
      --data-urlencode "client_id=${CLIENT_ID}"
  )"
  token_json="$(cat "${tmp_token}")"
  rm -f "${tmp_token}"

  access_token="$(jq -r '.access_token // empty' <<<"${token_json}")"
  if [[ -n "${access_token}" && "${access_token}" != "null" ]]; then
    umask 077
    mkdir -p "$(dirname "${OUT_ENV_PATH}")"
    printf 'export ACCESS_TOKEN=%q\n' "${access_token}" >"${OUT_ENV_PATH}"
    if [[ "${PRINT_TOKEN}" == "1" ]]; then
      echo "ACCESS_TOKEN=${access_token}" >&2
    fi
    echo "Wrote ${OUT_ENV_PATH}" >&2
    echo "Next:" >&2
    echo "  source ${OUT_ENV_PATH}" >&2
    exit 0
  fi

  err="$(jq -r '.error // empty' <<<"${token_json}")"
  case "${err}" in
    ""|authorization_pending)
      ;;
    slow_down)
      sleep_s="$(( sleep_s + 5 ))"
      ;;
    access_denied)
      echo "device-code authorization denied" >&2
      exit 2
      ;;
    expired_token)
      echo "device-code expired; re-run this script" >&2
      exit 2
      ;;
    *)
      if [[ "${token_http}" == "200" ]]; then
        echo "unexpected token response: ${token_json}" >&2
      else
        echo "token request failed (http ${token_http}): ${token_json}" >&2
      fi
      exit 2
      ;;
  esac

  sleep "${sleep_s}"
done
