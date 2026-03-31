#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "${ROOT_DIR}"

changed="$(git status --porcelain --untracked-files=all -- apps/order-domain/gen)"

if [[ -n "${changed}" ]]; then
  echo "order-domain generated contract artifacts drifted; run 'make order-domain-contracts' and commit the updated gen/ files." >&2
  echo >&2
  echo "Changed paths:" >&2
  echo "${changed}" >&2
  echo >&2
  git --no-pager diff -- apps/order-domain/gen || true
  exit 1
fi
