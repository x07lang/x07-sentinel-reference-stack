#!/usr/bin/env bash
set -euo pipefail

: "${RABBITMQ_PASSWORD:?set RABBITMQ_PASSWORD}"
: "${RABBITMQ_IMAGE:=rabbitmq:4.1.3-management}"
export RABBITMQ_IMAGE

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx >/dev/null
helm repo add jetstack https://charts.jetstack.io >/dev/null
helm repo add open-telemetry https://open-telemetry.github.io/opentelemetry-helm-charts >/dev/null
helm repo update >/dev/null

helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx   --namespace ingress-nginx   --create-namespace   -f "${ROOT_DIR}/ingress-nginx-values.yaml"

helm upgrade --install cert-manager jetstack/cert-manager   --namespace cert-manager   --create-namespace   --set installCRDs=true   -f "${ROOT_DIR}/cert-manager-values.yaml"

kubectl get ns rabbitmq >/dev/null 2>&1 || kubectl create ns rabbitmq >/dev/null
kubectl -n rabbitmq create secret generic rabbitmq-auth \
  --from-literal=username=x07ref \
  --from-literal=password="${RABBITMQ_PASSWORD}" \
  --dry-run=client -o yaml | kubectl apply -f - >/dev/null
envsubst < "${ROOT_DIR}/rabbitmq-manifest.yaml" | kubectl apply -f - >/dev/null
kubectl -n rabbitmq rollout status deployment/rabbitmq --timeout=5m

for attempt in {1..30}; do
  if kubectl -n rabbitmq exec deploy/rabbitmq -- sh -lc 'rabbitmqadmin -u "$RABBITMQ_DEFAULT_USER" -p "$RABBITMQ_DEFAULT_PASS" -V / declare queue name=order.created durable=true >/dev/null'; then
    break
  fi
  if [[ "${attempt}" == "30" ]]; then
    echo "failed to declare RabbitMQ queue order.created" >&2
    exit 2
  fi
  sleep 2
done

helm upgrade --install otel-collector open-telemetry/opentelemetry-collector   --namespace observability   --create-namespace   -f "${ROOT_DIR}/otel-collector-values.yaml"

kubectl get ns ingress-nginx cert-manager rabbitmq observability
