# GCP minimal infrastructure

This Terraform stack provisions:
- VPC + subnet
- GKE cluster + node pool
- Cloud SQL for PostgreSQL
- Cloud Storage bucket
- service account + HMAC key for XML-API style object access

Cluster add-ons are installed separately through `infra/kubernetes/bootstrap/`.

## Usage

```sh
cp terraform.tfvars.example terraform.tfvars
export TF_BIN="${TF_BIN:-terraform}" # or: tofu
${TF_BIN} init
${TF_BIN} apply
```
