# GCP tutorial

## What you will create

- VPC + subnet
- GKE cluster + node pool
- Cloud SQL for PostgreSQL
- Cloud Storage bucket
- service account + HMAC key for XML-API style object access
- in-cluster:
  - ingress-nginx
  - cert-manager
  - RabbitMQ
  - OpenTelemetry Collector

## Prerequisites

- GCP credentials for the target project.
  - Terraform uses Application Default Credentials (ADC): `gcloud auth application-default login`
  - `gcloud container clusters get-credentials` uses the gcloud user session: `gcloud auth login`
- Ensure the account used for ADC has permissions to enable services and provision GKE/Cloud SQL/Storage in the selected `project_id`.

## 1. Configure Terraform input

```sh
cd infra/terraform/gcp/minimal
cp terraform.tfvars.example terraform.tfvars
```

Edit at least:
- `project_id`
- `region`
- `project_name`
- `db_password`

## 2. Apply Terraform

```sh
export TF_BIN="${TF_BIN:-terraform}" # or: tofu
${TF_BIN} init
${TF_BIN} apply
```

Capture outputs:
```sh
${TF_BIN} output
${TF_BIN} output -raw cluster_name
${TF_BIN} output -raw cluster_location
${TF_BIN} output -raw bucket_name
${TF_BIN} output -raw object_store_endpoint
${TF_BIN} output -raw postgres_private_ip
${TF_BIN} output -raw postgres_database
${TF_BIN} output -raw postgres_username
${TF_BIN} output -raw postgres_dsn
${TF_BIN} output -raw storage_access_id
${TF_BIN} output -raw storage_secret
```

## 3. Fetch kubeconfig

```sh
gcloud container clusters get-credentials   "$(${TF_BIN} output -raw cluster_name)"   --region "$(${TF_BIN} output -raw cluster_location)"   --project "$(${TF_BIN} output -raw project_id)"
kubectl get nodes
```

## 4. Install common cluster add-ons

```sh
cd ../../kubernetes/bootstrap
export RABBITMQ_PASSWORD='replace-me'
bash install-common-addons.sh
```

## 5. Build binding values

Populate these env values for `sentinel/scripts/03-put-secrets.sh`:

- PostgreSQL DSN: `${TF_BIN} output -raw postgres_dsn`
- AMQP URL: `amqp://x07ref:${RABBITMQ_PASSWORD}@rabbitmq.rabbitmq.svc.cluster.local:5672/%2f`
- Object storage values:
  - endpoint: `${TF_BIN} output -raw object_store_endpoint`
  - bucket: `${TF_BIN} output -raw bucket_name`
  - access key: `${TF_BIN} output -raw storage_access_id`
  - secret key: `${TF_BIN} output -raw storage_secret`
- OTLP endpoint: `http://otel-collector.observability.svc.cluster.local:4318`

## 6. Prepare Sentinel env

```sh
cd ../../../sentinel/examples
cp gcp.env.example .gcp.env
set -a
source .gcp.env
set +a
```

## 7. Create or select Sentinel context

```sh
cd ../scripts
bash 00-login-device-code.sh
source ../../out/sentinel/access_token.env
bash 01-create-context.sh
```

## 8. Register target, secrets, bindings

```sh
bash 02-register-target.sh
bash 03-put-secrets.sh
bash 04-create-bindings.sh
```

## 9. Build, pack, upload, submit, approve

```sh
bash 05-build-images.sh
bash 06-pack-workloads.sh
bash 07-upload-cas.sh
bash 08-submit-releases.sh
bash 09-approve-releases.sh
```

## 10. Verify and roll back

```sh
bash 10-smoke-test.sh
export ROLLBACK_RELEASE_ID=<release-id>
bash 11-rollback.sh
```

## 11. Tear down

```sh
cd ../../infra/terraform/gcp/minimal
export TF_BIN="${TF_BIN:-terraform}" # or: tofu
${TF_BIN} destroy
```
