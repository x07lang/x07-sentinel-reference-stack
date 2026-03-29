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
bash sentinel/scripts/05-build-images.sh
```

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
