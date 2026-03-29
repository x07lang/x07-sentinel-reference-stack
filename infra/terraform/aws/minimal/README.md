# AWS minimal infrastructure

This Terraform stack provisions:
- VPC
- EKS cluster
- one managed node group
- PostgreSQL on RDS
- S3 bucket for reports

Cluster add-ons such as ingress-nginx, cert-manager, RabbitMQ, and OpenTelemetry Collector are installed separately through `infra/kubernetes/bootstrap/`.

## Usage

```sh
cp terraform.tfvars.example terraform.tfvars
export TF_BIN="${TF_BIN:-terraform}" # or: tofu
${TF_BIN} init
${TF_BIN} apply
```

Then:

```sh
aws eks update-kubeconfig   --region "$(${TF_BIN} output -raw aws_region)"   --name "$(${TF_BIN} output -raw cluster_name)"
```
