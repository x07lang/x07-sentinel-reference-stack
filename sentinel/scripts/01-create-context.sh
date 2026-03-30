#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/lib.sh"

require_env CLOUD_API_BASE_URL
require_env ACCESS_TOKEN

ORG_SLUG="${ORG_SLUG:-reference-stack}"
PROJECT_SLUG="${PROJECT_SLUG:-orders}"
ENVIRONMENT_SLUG="${ENVIRONMENT_SLUG:-dev}"

if [[ -z "${ORG_ID:-}" ]]; then
  org_list="$(api_get "/v1/orgs")"
  ORG_ID="$(jq -r --arg slug "${ORG_SLUG}" '.result.items[]? | select(.org_slug == $slug) | .org_id' <<<"${org_list}" | head -n 1)"
  if [[ -z "${ORG_ID}" || "${ORG_ID}" == "null" ]]; then
    org_json="$(api_post_json "/v1/orgs" "$(jq -n --arg org_slug "${ORG_SLUG}" --arg display_name "${ORG_SLUG}" '{org_slug:$org_slug, display_name:$display_name}')")"
    ORG_ID="$(jq -r --arg slug "${ORG_SLUG}" '.result.items[]? | select(.org_slug == $slug) | .org_id' <<<"${org_json}" | head -n 1)"
  fi
fi

if [[ -z "${PROJECT_ID:-}" ]]; then
  if [[ -z "${ORG_ID:-}" || "${ORG_ID}" == "null" ]]; then
    echo "missing ORG_ID; set ORG_ID or ORG_SLUG" >&2
    exit 2
  fi

  project_list="$(api_get "/v1/projects?org_id=${ORG_ID}")"
  PROJECT_ID="$(jq -r --arg slug "${PROJECT_SLUG}" '.result.items[]? | select(.project_slug == $slug) | .project_id' <<<"${project_list}" | head -n 1)"
  if [[ -z "${PROJECT_ID}" || "${PROJECT_ID}" == "null" ]]; then
    project_json="$(api_post_json "/v1/projects" "$(jq -n --arg org_id "${ORG_ID}" --arg project_slug "${PROJECT_SLUG}" --arg display_name "${PROJECT_SLUG}" '{org_id:$org_id, project_slug:$project_slug, display_name:$display_name}')")"
    PROJECT_ID="$(jq -r --arg slug "${PROJECT_SLUG}" '.result.items[]? | select(.project_slug == $slug) | .project_id' <<<"${project_json}" | head -n 1)"
  fi
fi

if [[ -z "${ENVIRONMENT_ID:-}" ]]; then
  if [[ -z "${PROJECT_ID:-}" || "${PROJECT_ID}" == "null" ]]; then
    echo "missing PROJECT_ID; set PROJECT_ID or PROJECT_SLUG" >&2
    exit 2
  fi

  env_list="$(api_get "/v1/environments?project_id=${PROJECT_ID}")"
  ENVIRONMENT_ID="$(jq -r --arg slug "${ENVIRONMENT_SLUG}" '.result.items[]? | select(.environment_slug == $slug) | .environment_id' <<<"${env_list}" | head -n 1)"
  if [[ -z "${ENVIRONMENT_ID}" || "${ENVIRONMENT_ID}" == "null" ]]; then
    env_json="$(api_post_json "/v1/environments" "$(jq -n --arg project_id "${PROJECT_ID}" --arg environment_slug "${ENVIRONMENT_SLUG}" --arg display_name "${ENVIRONMENT_SLUG}" '{project_id:$project_id, environment_slug:$environment_slug, display_name:$display_name}')")"
    ENVIRONMENT_ID="$(jq -r --arg slug "${ENVIRONMENT_SLUG}" '.result.items[]? | select(.environment_slug == $slug) | .environment_id' <<<"${env_json}" | head -n 1)"
  fi
fi

api_post_json "/v1/context/select" "$(jq -n --arg org_id "${ORG_ID}" --arg project_id "${PROJECT_ID}" --arg environment_id "${ENVIRONMENT_ID}" '{org_id:$org_id, project_id:$project_id, environment_id:$environment_id}')" >/dev/null

echo "ORG_ID=${ORG_ID}"
echo "PROJECT_ID=${PROJECT_ID}"
echo "ENVIRONMENT_ID=${ENVIRONMENT_ID}"
