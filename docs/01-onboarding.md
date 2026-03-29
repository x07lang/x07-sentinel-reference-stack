# Onboarding to x07 Sentinel

This repo assumes **x07 Sentinel is in closed beta**.

## New users

1. Request access using your work email.
2. Wait for approval and account provisioning.
3. Sign in using the same work identity you requested access with.
4. Open the console and confirm you can reach:
   - Overview
   - Services
   - Changes
   - Infrastructure
   - Governance

Sentinel does **not** issue a separate product password. Authentication is handled through your approved company identity provider.

## Tooling

Install:
- `terraform`
- `kubectl`
- `helm`
- `jq`
- `curl`
- `docker`
- `x07`
- `x07-wasm` component (for `x07 wasm`)

Install the WASM component:

```sh
x07up component add wasm
```

## Recommended Sentinel tenancy shape

Use one clean workspace:
- org: `reference-stack`
- project: `orders`
- environment: `aws-dev` or `gcp-dev`
