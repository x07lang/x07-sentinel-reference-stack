PROJECT_NAME ?= x07-sentinel-reference-stack
TF_BIN ?= terraform

.PHONY: help terraform-fmt terraform-validate aws-init gcp-init local-up local-down local-smoke

help:
	@echo "Targets:"
	@echo "  terraform-fmt       - run terraform fmt recursively"
	@echo "  terraform-validate  - init -backend=false and validate AWS/GCP examples"
	@echo "  aws-init            - terraform init for AWS minimal stack"
	@echo "  gcp-init            - terraform init for GCP minimal stack"
	@echo "  local-up            - start local deps (docker compose)"
	@echo "  local-down          - stop local deps (docker compose)"
	@echo "  local-smoke         - local E2E smoke (docker)"

terraform-fmt:
	$(TF_BIN) fmt -recursive infra/terraform

terraform-validate:
	bash scripts/ci/terraform-validate.sh

aws-init:
	cd infra/terraform/aws/minimal && $(TF_BIN) init

gcp-init:
	cd infra/terraform/gcp/minimal && $(TF_BIN) init

local-up:
	docker compose -p x07rs -f scripts/local/docker-compose.yml up -d

local-down:
	docker compose -p x07rs -f scripts/local/docker-compose.yml down -v

local-smoke:
	bash scripts/local/smoke.sh
