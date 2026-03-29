# Sentinel onboarding for this reference stack

Use these binding names exactly:
- `db.primary`
- `msg.orders`
- `obj.reports`
- `telemetry.otlp`

Typical example tenancy:
- org: `reference-stack`
- project: `orders`
- environment: `aws-dev` or `gcp-dev`

## Sign in and get an access token

```sh
bash sentinel/scripts/00-login-device-code.sh
source out/sentinel/access_token.env
```

## Create or select context

```sh
bash sentinel/scripts/01-create-context.sh
```

## Register the target

```sh
bash sentinel/scripts/02-register-target.sh
```

## Upload secrets and bindings

```sh
bash sentinel/scripts/03-put-secrets.sh
bash sentinel/scripts/04-create-bindings.sh
```
