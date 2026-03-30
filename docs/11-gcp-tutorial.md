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
- The selected `project_id` must have **billing enabled**, or GCP will refuse to activate services like `container.googleapis.com` / `compute.googleapis.com`.
- This tutorial uses **Cloud Storage HMAC keys** to keep an S3-style binding model. Some org policies (notably `constraints/iam.disableServiceAccountKeyCreation`) can block HMAC key creation; if enforced, either disable it for the project or use a different project/policy.
- Terraform CLI must satisfy the repo constraint: `terraform >= 1.7.0` (see `infra/terraform/gcp/minimal/versions.tf`). OpenTofu is also acceptable.

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

Wait for the ingress controller to get a public address, then record the base URL you want to use for the target:

```sh
ingress_ip="$(kubectl -n ingress-nginx get svc ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].ip}')"
ingress_host="$(kubectl -n ingress-nginx get svc ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')"
echo "ingress_ip=${ingress_ip}"
echo "ingress_host=${ingress_host}"
echo "TARGET_BASE_URL=https://<use ingress_ip or ingress_host>"
```

Notes:

- This tutorial uses `https://` for the target base URL. With the default ingress-nginx install, TLS is typically a default/self-signed certificate, so verification steps may need `CURL_INSECURE=1`.
- For production, attach a real certificate and use a stable DNS name.

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
${EDITOR:-nano} .gcp.env
set -a
source .gcp.env
set +a
```

At minimum, set:
- `TARGET_BASE_URL` to `https://...` (or loopback `http://127.0.0.1` / `http://localhost` for local smoke)
- `CLUSTER_REF` to the GKE `cluster_name`
- `NAMESPACE` to a fresh namespace (for example `orders-dev`)

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
PUSH=1 bash 05-build-images.sh
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

Before destroying the cloud infrastructure, uninstall the in-cluster add-ons so cloud load balancers are cleaned up:

```sh
helm -n ingress-nginx uninstall ingress-nginx || true
helm -n cert-manager uninstall cert-manager || true
helm -n observability uninstall otel-collector || true
kubectl delete ns rabbitmq observability ingress-nginx cert-manager --wait=false || true
```

If `terraform destroy` fails deleting the reports bucket because it is not empty, delete bucket objects before retrying (or set `force_destroy = true` in the bucket resource for test stacks).

```sh
cd ../../infra/terraform/gcp/minimal
export TF_BIN="${TF_BIN:-terraform}" # or: tofu
${TF_BIN} destroy
```
