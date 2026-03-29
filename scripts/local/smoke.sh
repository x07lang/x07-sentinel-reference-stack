#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

COMPOSE_PROJECT_NAME="${COMPOSE_PROJECT_NAME:-x07rs}"
COMPOSE_FILE="${ROOT_DIR}/scripts/local/docker-compose.yml"
NETWORK="${COMPOSE_PROJECT_NAME}_default"

X07_TAG="${X07_TAG:-v0.1.102}"
KEEP="${KEEP:-0}"

cleanup() {
  if [[ "${KEEP}" == "1" ]]; then
    echo "KEEP=1; leaving local stack running (project: ${COMPOSE_PROJECT_NAME})" >&2
    return
  fi
  docker rm -f "${COMPOSE_PROJECT_NAME}-orders-api" "${COMPOSE_PROJECT_NAME}-orders-consumer" >/dev/null 2>&1 || true
  docker compose -p "${COMPOSE_PROJECT_NAME}" -f "${COMPOSE_FILE}" down -v >/dev/null
}
trap cleanup EXIT

echo "Starting local dependencies (project: ${COMPOSE_PROJECT_NAME})"
docker compose -p "${COMPOSE_PROJECT_NAME}" -f "${COMPOSE_FILE}" up -d

echo "Waiting for Postgres"
for _ in $(seq 1 60); do
  if docker compose -p "${COMPOSE_PROJECT_NAME}" -f "${COMPOSE_FILE}" exec -T postgres pg_isready -U orders_app -d orders >/dev/null 2>&1; then
    break
  fi
  sleep 1
done
docker compose -p "${COMPOSE_PROJECT_NAME}" -f "${COMPOSE_FILE}" exec -T postgres pg_isready -U orders_app -d orders >/dev/null

echo "Waiting for RabbitMQ"
for _ in $(seq 1 60); do
  if docker compose -p "${COMPOSE_PROJECT_NAME}" -f "${COMPOSE_FILE}" exec -T rabbitmq rabbitmq-diagnostics -q ping >/dev/null 2>&1; then
    break
  fi
  sleep 1
done
docker compose -p "${COMPOSE_PROJECT_NAME}" -f "${COMPOSE_FILE}" exec -T rabbitmq rabbitmq-diagnostics -q ping >/dev/null

echo "Waiting for RabbitMQ management API"
for _ in $(seq 1 60); do
  if docker run --rm --network "${NETWORK}" curlimages/curl:8.18.0 -fsS -u x07ref:x07ref "http://rabbitmq:15672/api/overview" >/dev/null 2>&1; then
    break
  fi
  sleep 1
done
docker run --rm --network "${NETWORK}" curlimages/curl:8.18.0 -fsS -u x07ref:x07ref "http://rabbitmq:15672/api/overview" >/dev/null

echo "Ensuring RabbitMQ queue exists"
docker run --rm --network "${NETWORK}" curlimages/curl:8.18.0 \
  -fsS -u x07ref:x07ref -X PUT "http://rabbitmq:15672/api/queues/%2f/order.created" \
  -H 'content-type: application/json' \
  --data '{"durable":true}' >/dev/null

echo "Waiting for MinIO"
for _ in $(seq 1 60); do
  if docker run --rm --network "${NETWORK}" curlimages/curl:8.18.0 -fsS "http://minio:9000/minio/health/ready" >/dev/null 2>&1; then
    break
  fi
  sleep 1
done
docker run --rm --network "${NETWORK}" curlimages/curl:8.18.0 -fsS "http://minio:9000/minio/health/ready" >/dev/null

echo "Waiting for OTel Collector"
for _ in $(seq 1 60); do
  if docker run --rm --network "${NETWORK}" curlimages/curl:8.18.0 -fsS "http://otel-collector:13133/" >/dev/null 2>&1; then
    break
  fi
  sleep 1
done
docker run --rm --network "${NETWORK}" curlimages/curl:8.18.0 -fsS "http://otel-collector:13133/" >/dev/null

echo "Building workload images (X07_TAG=${X07_TAG})"
export X07_TAG
bash "${ROOT_DIR}/sentinel/scripts/05-build-images.sh" >/dev/null
source "${ROOT_DIR}/out/images/images.env"

db_dsn="postgres://orders_app:orders@postgres:5432/orders"
amqp_url="amqp://x07ref:x07ref@rabbitmq:5672/%2f"
otlp_endpoint="http://otel-collector:4318"

export_env=(
  -e "APP_VERSION=${APP_VERSION}"
  -e "X07_BINDING_DB_PRIMARY_DSN=${db_dsn}"
  -e "X07_BINDING_MSG_ORDERS_URL=${amqp_url}"
  -e "X07_BINDING_TELEMETRY_OTLP_ENDPOINT=${otlp_endpoint}"
  -e "X07_OS_OBJ_S3_ENDPOINT=http://minio:9000"
  -e "X07_OS_OBJ_S3_BUCKET=reports"
  -e "X07_OS_OBJ_S3_ACCESS_KEY=minio"
  -e "X07_OS_OBJ_S3_SECRET_KEY=minio123"
)

echo "Starting orders-consumer"
docker rm -f "${COMPOSE_PROJECT_NAME}-orders-consumer" >/dev/null 2>&1 || true
docker run -d --name "${COMPOSE_PROJECT_NAME}-orders-consumer" --network "${NETWORK}" \
  -e "X07_EVENT_TOPIC=order.created" \
  -e "X07_EVENT_CONSUMER_GROUP=orders-consumer" \
  "${export_env[@]}" \
  "${ORDERS_CONSUMER_IMAGE}" >/dev/null

echo "Starting orders-api"
docker rm -f "${COMPOSE_PROJECT_NAME}-orders-api" >/dev/null 2>&1 || true
docker run -d --name "${COMPOSE_PROJECT_NAME}-orders-api" --network "${NETWORK}" -p 8080:8080 \
  "${export_env[@]}" \
  "${ORDERS_API_IMAGE}" >/dev/null

echo "Waiting for API readiness"
for _ in $(seq 1 60); do
  if curl -fsS "http://127.0.0.1:8080/readyz" >/dev/null; then
    break
  fi
  sleep 1
done
curl -fsS "http://127.0.0.1:8080/readyz" >/dev/null

echo "Creating an order"
order_resp="$(
  curl -fsS -X POST "http://127.0.0.1:8080/orders" \
    -H 'content-type: application/json' \
    --data '{"customer_id":"cust_local","currency":"USD","total_minor":1000}'
)"
order_id="$(jq -r '.id // .order.id // empty' <<<"${order_resp}")"
if [[ -z "${order_id}" || "${order_id}" == "null" ]]; then
  echo "POST /orders did not return an id:" >&2
  echo "${order_resp}" >&2
  exit 1
fi
echo "order_id=${order_id}"

echo "Waiting for consumer projection"
for _ in $(seq 1 60); do
  o="$(curl -fsS "http://127.0.0.1:8080/orders/${order_id}")" || true
  if jq -e '.projection.status == "consumed"' >/dev/null 2>&1 <<<"${o}"; then
    break
  fi
  sleep 1
done
curl -fsS "http://127.0.0.1:8080/orders/${order_id}" | jq -e '.projection.status == "consumed"' >/dev/null

echo "Running reconciliation-job"
docker run --rm --network "${NETWORK}" \
  "${export_env[@]}" \
  "${RECONCILIATION_JOB_IMAGE}" >/dev/null

echo "Fetching latest report"
curl -fsS "http://127.0.0.1:8080/reports/latest" | jq -e '.ok == true' >/dev/null

echo "Local smoke OK"
