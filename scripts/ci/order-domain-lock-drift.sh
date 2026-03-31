#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "${ROOT_DIR}"

changed="$(git status --porcelain --untracked-files=all -- \
  apps/order-domain/arch/manifest.lock.json \
  apps/order-domain/arch/contracts.lock.json)"

if [[ -n "${changed}" ]]; then
  echo "order-domain contract locks drifted; run 'make order-domain-pin' and commit the updated lock files." >&2
  echo >&2
  echo "Changed paths:" >&2
  echo "${changed}" >&2
  echo >&2
  git --no-pager diff -- apps/order-domain/arch/manifest.lock.json apps/order-domain/arch/contracts.lock.json || true
  exit 1
fi
