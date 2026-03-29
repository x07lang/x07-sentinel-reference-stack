#!/usr/bin/env bash
set -euo pipefail

: "${RABBITMQ_PASSWORD:?set RABBITMQ_PASSWORD}"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx >/dev/null
helm repo add jetstack https://charts.jetstack.io >/dev/null
helm repo add bitnami https://charts.bitnami.com/bitnami >/dev/null
helm repo add open-telemetry https://open-telemetry.github.io/opentelemetry-helm-charts >/dev/null
helm repo update >/dev/null

helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx   --namespace ingress-nginx   --create-namespace   -f "${ROOT_DIR}/ingress-nginx-values.yaml"

helm upgrade --install cert-manager jetstack/cert-manager   --namespace cert-manager   --create-namespace   --set installCRDs=true   -f "${ROOT_DIR}/cert-manager-values.yaml"

helm upgrade --install rabbitmq bitnami/rabbitmq   --namespace rabbitmq   --create-namespace   --set auth.username=x07ref   --set auth.password="${RABBITMQ_PASSWORD}"   -f "${ROOT_DIR}/rabbitmq-values.yaml"

helm upgrade --install otel-collector open-telemetry/opentelemetry-collector   --namespace observability   --create-namespace   -f "${ROOT_DIR}/otel-collector-values.yaml"

kubectl get ns ingress-nginx cert-manager rabbitmq observability
