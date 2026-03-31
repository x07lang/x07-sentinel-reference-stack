#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/lib.sh"

require_env X07_TAG
APP_VERSION="${APP_VERSION:-$(date +%Y%m%d%H%M%S)}"
IMAGE_PREFIX="${IMAGE_PREFIX:-local/reference-stack}"
default_platform="linux/amd64"
case "$(uname -m 2>/dev/null || true)" in
  arm64|aarch64) default_platform="linux/arm64" ;;
esac
DOCKER_PLATFORM="${DOCKER_PLATFORM:-${default_platform}}"
PUSH="${PUSH:-0}"
K3D_IMPORT="${K3D_IMPORT:-0}"

mkdir -p "${OUT_DIR}/images"

orders_api_image="${IMAGE_PREFIX}/orders-api:${APP_VERSION}"
orders_consumer_image="${IMAGE_PREFIX}/orders-consumer:${APP_VERSION}"
reconciliation_job_image="${IMAGE_PREFIX}/reconciliation-job:${APP_VERSION}"

docker build -f "${ROOT_DIR}/apps/orders-api/Dockerfile"   --platform "${DOCKER_PLATFORM}"   --build-arg "X07_TAG=${X07_TAG}"   --build-arg "APP_VERSION=${APP_VERSION}"   -t "${orders_api_image}"   "${ROOT_DIR}"

docker build -f "${ROOT_DIR}/apps/orders-consumer/Dockerfile"   --platform "${DOCKER_PLATFORM}"   --build-arg "X07_TAG=${X07_TAG}"   --build-arg "APP_VERSION=${APP_VERSION}"   -t "${orders_consumer_image}"   "${ROOT_DIR}"

docker build -f "${ROOT_DIR}/apps/reconciliation-job/Dockerfile"   --platform "${DOCKER_PLATFORM}"   --build-arg "X07_TAG=${X07_TAG}"   --build-arg "APP_VERSION=${APP_VERSION}"   -t "${reconciliation_job_image}"   "${ROOT_DIR}"

if [[ "${PUSH}" == "1" ]]; then
  docker push "${orders_api_image}"
  docker push "${orders_consumer_image}"
  docker push "${reconciliation_job_image}"
fi

cat >"${OUT_DIR}/images/images.env" <<EOF
export APP_VERSION=${APP_VERSION}
export ORDERS_API_IMAGE=${orders_api_image}
export ORDERS_CONSUMER_IMAGE=${orders_consumer_image}
export RECONCILIATION_JOB_IMAGE=${reconciliation_job_image}
EOF

if [[ "${K3D_IMPORT}" == "1" ]]; then
  require_env CLUSTER_REF
  command -v k3d >/dev/null 2>&1 || {
    echo "K3D_IMPORT=1 requires k3d to be installed" >&2
    exit 2
  }
  cluster_name="${CLUSTER_REF}"
  if [[ "${cluster_name}" == k3d-* ]]; then
    cluster_name="${cluster_name#k3d-}"
  fi
  if [[ -z "${cluster_name}" ]]; then
    echo "invalid CLUSTER_REF for k3d import: ${CLUSTER_REF}" >&2
    exit 2
  fi
  k3d image import -c "${cluster_name}" \
    "${orders_api_image}" \
    "${orders_consumer_image}" \
    "${reconciliation_job_image}"
fi

echo "Wrote ${OUT_DIR}/images/images.env"
