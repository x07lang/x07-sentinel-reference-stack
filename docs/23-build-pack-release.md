# Build, pack, upload, submit

## Prerequisites

- `docker`
- `x07` installed (`x07 --version`)
- `x07-wasm` component installed (required for `x07 wasm workload pack`):

```sh
x07up component add wasm
```

## Build runtime images

```sh
X07_TAG=v0.1.106 bash sentinel/scripts/05-build-images.sh
```

Notes:
- EKS/GKE nodes are typically `linux/amd64`. If you need a different platform, set `DOCKER_PLATFORM` (for example `DOCKER_PLATFORM=linux/arm64`).
- For real cluster deployments, set `IMAGE_PREFIX` to a registry reachable by your Kubernetes nodes (for example `ghcr.io/<org>/<repo>`, ECR, or Artifact Registry) and run with `PUSH=1`.
- For local k3d targets, set `K3D_IMPORT=1` (and ensure `CLUSTER_REF` points at your `k3d-*` kube context) so the images are imported into the cluster without needing a registry.

## Pack workloads

```sh
bash sentinel/scripts/06-pack-workloads.sh
```

Outputs land under:
```text
out/pack/
```

## Upload referenced objects to CAS

```sh
bash sentinel/scripts/07-upload-cas.sh
```

## Submit and approve releases

```sh
bash sentinel/scripts/08-submit-releases.sh
bash sentinel/scripts/09-approve-releases.sh
```

Inspect Changes → Releases in the console for review and rollout state.
