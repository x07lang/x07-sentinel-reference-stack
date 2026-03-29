#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/lib.sh"

for name in CLOUD_API_BASE_URL ACCESS_TOKEN DB_DSN_SECRET DB_DSN AMQP_URL_SECRET AMQP_URL S3_ENDPOINT_SECRET S3_ENDPOINT S3_BUCKET_SECRET S3_BUCKET S3_ACCESS_KEY_SECRET S3_ACCESS_KEY S3_SECRET_KEY_SECRET S3_SECRET_KEY OTLP_ENDPOINT_SECRET OTLP_ENDPOINT; do
  require_env "${name}"
done

put_secret() {
  local secret_name="$1"
  local secret_value="$2"
  api_put_json "/v1/secrets/${secret_name}" "$(jq -n --arg value "${secret_value}" '{value:$value}')"
}

put_secret "${DB_DSN_SECRET}" "${DB_DSN}" >/dev/null
put_secret "${AMQP_URL_SECRET}" "${AMQP_URL}" >/dev/null
put_secret "${S3_ENDPOINT_SECRET}" "${S3_ENDPOINT}" >/dev/null
put_secret "${S3_BUCKET_SECRET}" "${S3_BUCKET}" >/dev/null
put_secret "${S3_ACCESS_KEY_SECRET}" "${S3_ACCESS_KEY}" >/dev/null
put_secret "${S3_SECRET_KEY_SECRET}" "${S3_SECRET_KEY}" >/dev/null
put_secret "${OTLP_ENDPOINT_SECRET}" "${OTLP_ENDPOINT}" >/dev/null

echo "Secrets uploaded."
