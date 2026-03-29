#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/lib.sh"

require_env X07_TAG
APP_VERSION="${APP_VERSION:-$(date +%Y%m%d%H%M%S)}"
IMAGE_PREFIX="${IMAGE_PREFIX:-local/reference-stack}"

mkdir -p "${OUT_DIR}/images"

docker build -f "${ROOT_DIR}/apps/orders-api/Dockerfile"   --build-arg "X07_TAG=${X07_TAG}"   --build-arg "APP_VERSION=${APP_VERSION}"   -t "${IMAGE_PREFIX}/orders-api:${APP_VERSION}"   "${ROOT_DIR}"

docker build -f "${ROOT_DIR}/apps/orders-consumer/Dockerfile"   --build-arg "X07_TAG=${X07_TAG}"   --build-arg "APP_VERSION=${APP_VERSION}"   -t "${IMAGE_PREFIX}/orders-consumer:${APP_VERSION}"   "${ROOT_DIR}"

docker build -f "${ROOT_DIR}/apps/reconciliation-job/Dockerfile"   --build-arg "X07_TAG=${X07_TAG}"   --build-arg "APP_VERSION=${APP_VERSION}"   -t "${IMAGE_PREFIX}/reconciliation-job:${APP_VERSION}"   "${ROOT_DIR}"

cat >"${OUT_DIR}/images/images.env" <<EOF
export APP_VERSION=${APP_VERSION}
export ORDERS_API_IMAGE=${IMAGE_PREFIX}/orders-api:${APP_VERSION}
export ORDERS_CONSUMER_IMAGE=${IMAGE_PREFIX}/orders-consumer:${APP_VERSION}
export RECONCILIATION_JOB_IMAGE=${IMAGE_PREFIX}/reconciliation-job:${APP_VERSION}
EOF

echo "Wrote ${OUT_DIR}/images/images.env"
