#!/usr/bin/env bash
set -euo pipefail

: "${RABBITMQ_PASSWORD:?set RABBITMQ_PASSWORD}"
: "${RABBITMQ_IMAGE_REGISTRY:=}"
: "${RABBITMQ_IMAGE_REPOSITORY:=}"
: "${RABBITMQ_IMAGE_TAG:=}"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx >/dev/null
helm repo add jetstack https://charts.jetstack.io >/dev/null
helm repo add bitnami https://charts.bitnami.com/bitnami >/dev/null
helm repo add open-telemetry https://open-telemetry.github.io/opentelemetry-helm-charts >/dev/null
helm repo update >/dev/null

helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx   --namespace ingress-nginx   --create-namespace   -f "${ROOT_DIR}/ingress-nginx-values.yaml"

helm upgrade --install cert-manager jetstack/cert-manager   --namespace cert-manager   --create-namespace   --set installCRDs=true   -f "${ROOT_DIR}/cert-manager-values.yaml"

rabbitmq_image_args=()
if [[ -n "${RABBITMQ_IMAGE_REGISTRY}" ]]; then
  rabbitmq_image_args+=(--set "image.registry=${RABBITMQ_IMAGE_REGISTRY}")
fi
if [[ -n "${RABBITMQ_IMAGE_REPOSITORY}" ]]; then
  rabbitmq_image_args+=(--set "image.repository=${RABBITMQ_IMAGE_REPOSITORY}")
fi
if [[ -n "${RABBITMQ_IMAGE_TAG}" ]]; then
  rabbitmq_image_args+=(--set "image.tag=${RABBITMQ_IMAGE_TAG}")
fi

helm upgrade --install rabbitmq bitnami/rabbitmq   --namespace rabbitmq   --create-namespace   --set auth.username=x07ref   --set auth.password="${RABBITMQ_PASSWORD}"   "${rabbitmq_image_args[@]}"   -f "${ROOT_DIR}/rabbitmq-values.yaml"

helm upgrade --install otel-collector open-telemetry/opentelemetry-collector   --namespace observability   --create-namespace   -f "${ROOT_DIR}/otel-collector-values.yaml"

kubectl get ns ingress-nginx cert-manager rabbitmq observability
