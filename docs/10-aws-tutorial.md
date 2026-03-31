# AWS tutorial

## What you will create

- VPC + subnets
- EKS cluster
- RDS for PostgreSQL
- S3 bucket
- in-cluster:
  - ingress-nginx
  - cert-manager
  - RabbitMQ
  - OpenTelemetry Collector

## Prerequisites

- AWS credentials that can create and tag the required resources (VPC/EKS/RDS/S3/IAM/CloudWatch Logs).
  - This stack creates IAM roles for EKS and an IAM user + access key for the S3 binding.
  - If `tofu apply` fails with `AccessDenied` on `iam:*` or `logs:TagResource`, grant those permissions (or use an admin role) and retry.
- If `tofu apply` fails with `Cannot find version ... for postgres`, update `engine_version` in `infra/terraform/aws/minimal/main.tf` to an engine version available in the selected region.
- Terraform CLI must satisfy the repo constraint: `terraform >= 1.7.0` (see `infra/terraform/aws/minimal/versions.tf`). OpenTofu is also acceptable.

## 1. Configure Terraform input

```sh
cd infra/terraform/aws/minimal
cp terraform.tfvars.example terraform.tfvars
```

Edit at least:
- `aws_region`
- `project_name`
- `environment`
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
${TF_BIN} output -raw aws_region
${TF_BIN} output -raw bucket_name
${TF_BIN} output -raw object_store_endpoint
${TF_BIN} output -raw object_store_access_key
${TF_BIN} output -raw object_store_secret_key
${TF_BIN} output -raw postgres_address
${TF_BIN} output -raw postgres_database
${TF_BIN} output -raw postgres_username
${TF_BIN} output -raw postgres_dsn
```

## 3. Fetch kubeconfig

```sh
TF_BIN="${TF_BIN:-terraform}" # or: tofu
aws eks update-kubeconfig   --region "$(${TF_BIN} output -raw aws_region)"   --name "$(${TF_BIN} output -raw cluster_name)"
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
ingress_host="$(kubectl -n ingress-nginx get svc ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')"
echo "ingress_host=${ingress_host}"
echo "TARGET_BASE_URL=https://${ingress_host}"
```

Notes:

- This tutorial uses `https://` for the target base URL. With the default ingress-nginx install, TLS is typically a default/self-signed certificate, so verification steps may need `CURL_INSECURE=1`.
- For production, attach a real certificate (ACM / cert-manager / managed cert) and use a stable DNS name.

## 5. Build binding values

Populate these env values for `sentinel/scripts/03-put-secrets.sh`:

- PostgreSQL DSN: `${TF_BIN} output -raw postgres_dsn`
- AMQP URL: `amqp://x07ref:${RABBITMQ_PASSWORD}@rabbitmq.rabbitmq.svc.cluster.local:5672/%2f`
- S3 values:
  - endpoint: `${TF_BIN} output -raw object_store_endpoint`
  - bucket: `${TF_BIN} output -raw bucket_name`
  - access key: `${TF_BIN} output -raw object_store_access_key`
  - secret key: `${TF_BIN} output -raw object_store_secret_key`
- OTLP endpoint: `http://otel-collector.observability.svc.cluster.local:4318`

## 6. Prepare Sentinel env

```sh
cd ../../../sentinel/examples
cp aws.env.example .aws.env
${EDITOR:-nano} .aws.env
set -a
source .aws.env
set +a
```

At minimum, set:
- `TARGET_BASE_URL` to `https://...` (or loopback `http://127.0.0.1` / `http://localhost` for local smoke)
- `CLUSTER_REF` to the EKS `cluster_name`
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
X07_TAG=v0.1.107 PUSH=1 bash 05-build-images.sh
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

Before destroying the cloud infrastructure, uninstall the in-cluster add-ons so cloud load balancers and related security groups are cleaned up:

```sh
helm -n ingress-nginx uninstall ingress-nginx || true
helm -n cert-manager uninstall cert-manager || true
helm -n observability uninstall otel-collector || true
kubectl delete ns rabbitmq observability ingress-nginx cert-manager --wait=false || true
```

If you used a `LoadBalancer` Service (ingress-nginx), wait until the Classic ELB disappears before deleting the VPC. If the cluster is destroyed first, the ELB can become orphaned and block subnet deletion.

If `terraform destroy` fails deleting the reports bucket with `BucketNotEmpty`, delete all object versions:

```sh
bucket="$(${TF_BIN} output -raw bucket_name)"
aws s3api list-object-versions --bucket "${bucket}" --output json \
  | jq '{Objects: ([.Versions[]?, .DeleteMarkers[]?] | map({Key:.Key, VersionId:.VersionId})), Quiet: true}' \
  | aws s3api delete-objects --bucket "${bucket}" --delete file:///dev/stdin
```

```sh
cd ../../infra/terraform/aws/minimal
export TF_BIN="${TF_BIN:-terraform}" # or: tofu
${TF_BIN} destroy
```
