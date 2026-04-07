# x07-sentinel-reference-stack

Reference backend stack for deploying X07 workloads to x07 Sentinel on customer-managed Kubernetes.

This repo is the public “small but complete” example for the Sentinel backend story. It combines one shared domain pack with three service shapes and the supporting infra, bindings, and rollout walkthroughs needed to move from local smoke to real cloud deployment.

## What This Repo Proves

- X07 services can be packaged into Sentinel-compatible workload artifacts
- the same example topology can be deployed on customer-managed Kubernetes
- the system can be reproduced across AWS and GCP
- the domain layer can stay deterministic and reviewable while the runtime layer grows into a real backend stack

## Main Components

- `orders-api`: HTTP service
- `orders-consumer`: event consumer
- `reconciliation-job`: scheduled job
- `apps/order-domain/`: shared contracts and verification-focused domain pack

## Choose Your Path

### Local smoke

```sh
make local-smoke
```

### AWS or GCP tutorial

Start in:

- [`docs/10-aws-tutorial.md`](docs/10-aws-tutorial.md)
- [`docs/11-gcp-tutorial.md`](docs/11-gcp-tutorial.md)

### Domain-pack and primitives path

If you want the contract and verification side first:

```sh
make order-domain-contracts
make order-domain-test
make order-domain-verify
make order-domain-trust
```

## Repo Layout

- `apps/`: domain pack plus service projects
- `infra/`: Terraform and Kubernetes bootstrap
- `sentinel/`: payloads, scripts, and examples for Sentinel flows
- `docs/`: onboarding, cloud tutorials, Sentinel walkthroughs, and verification notes

## How It Fits The X07 Ecosystem

- [`x07`](https://github.com/x07lang/x07) provides the language and verification tooling
- [`x07-wasm-backend`](https://github.com/x07lang/x07-wasm-backend) produces the workload artifacts
- [`x07-platform`](https://github.com/x07lang/x07-platform) and Sentinel operate the release and rollback loop
- this repo shows what that backend path looks like in a concrete reference system

## License

Apache 2.0
