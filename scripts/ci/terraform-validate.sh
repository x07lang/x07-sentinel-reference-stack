#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

TF_BIN="${TF_BIN:-}"
if [[ -z "${TF_BIN}" ]]; then
  if command -v terraform >/dev/null 2>&1; then
    TF_BIN="terraform"
  elif command -v tofu >/dev/null 2>&1; then
    TF_BIN="tofu"
  else
    echo "missing terraform/tofu (set TF_BIN=terraform or TF_BIN=tofu)" >&2
    exit 2
  fi
fi

for dir in   "${ROOT_DIR}/infra/terraform/aws/minimal"   "${ROOT_DIR}/infra/terraform/gcp/minimal"
do
  echo "==> validating ${dir}"
  (cd "${dir}" && "${TF_BIN}" init -backend=false -input=false >/dev/null && "${TF_BIN}" validate)
done
