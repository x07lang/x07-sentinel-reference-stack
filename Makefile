PROJECT_NAME ?= x07-sentinel-reference-stack
TF_BIN ?= terraform

.PHONY: help terraform-fmt terraform-validate aws-init gcp-init local-up local-down local-smoke order-domain-contracts order-domain-generated-drift order-domain-pin order-domain-arch-check order-domain-review order-domain-test order-domain-verify order-domain-trust order-domain-ci

help:
	@echo "Targets:"
	@echo "  terraform-fmt         - run terraform fmt recursively"
	@echo "  terraform-validate    - init -backend=false and validate AWS/GCP examples"
	@echo "  aws-init              - terraform init for AWS minimal stack"
	@echo "  gcp-init              - terraform init for GCP minimal stack"
	@echo "  local-up              - start local deps (docker compose)"
	@echo "  local-down            - stop local deps (docker compose)"
	@echo "  local-smoke           - local E2E smoke (docker)"
	@echo "  order-domain-contracts - regenerate committed schema/state-machine outputs under apps/order-domain/gen"
	@echo "  order-domain-generated-drift - fail when committed gen/ artifacts drift"
	@echo "  order-domain-pin      - regenerate contract outputs and refresh arch lock files"
	@echo "  order-domain-arch-check - run x07 arch check with the pinned lock files"
	@echo "  order-domain-review BASELINE=/path - emit review diff artifacts for apps/order-domain"
	@echo "  order-domain-test     - run deterministic tests + PBT for apps/order-domain"
	@echo "  order-domain-verify   - run coverage/prove + proof replay for apps/order-domain"
	@echo "  order-domain-trust    - run trust profile check + trust report for apps/order-domain"
	@echo "  order-domain-ci       - run contracts, drift gates, tests, verify, and trust flows together"

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

order-domain-contracts:
	bash apps/order-domain/ci/generate_contracts.sh

order-domain-generated-drift:
	bash scripts/ci/order-domain-generated-drift.sh

order-domain-pin:
	bash apps/order-domain/ci/pin_contracts.sh

order-domain-arch-check:
	bash apps/order-domain/ci/arch_check.sh

order-domain-review:
	@if [ -z "$(BASELINE)" ]; then echo "BASELINE=/path/to/baseline is required" >&2; exit 2; fi
	bash apps/order-domain/ci/review.sh "$(BASELINE)"

order-domain-test: order-domain-contracts
	bash apps/order-domain/ci/test.sh

order-domain-verify:
	bash apps/order-domain/ci/verify.sh

order-domain-trust:
	bash apps/order-domain/ci/trust.sh

order-domain-ci: order-domain-pin order-domain-generated-drift order-domain-arch-check order-domain-test order-domain-verify order-domain-trust
