# Common cluster add-ons

Install the same add-ons on both AWS and GCP to keep the Sentinel side of the tutorial identical.

## Add-ons

- ingress-nginx
- cert-manager
- RabbitMQ
- OpenTelemetry Collector

## Usage

```sh
export RABBITMQ_PASSWORD='replace-me'
bash install-common-addons.sh
```

## Docker Hub fallback

Some clusters cannot pull `docker.io/bitnami/*` images due to egress policy or Docker Hub rate limits.

To override the RabbitMQ image location:

```sh
export RABBITMQ_PASSWORD='replace-me'
export RABBITMQ_IMAGE_REGISTRY='registry.example.com'
export RABBITMQ_IMAGE_REPOSITORY='mirror/bitnami-rabbitmq'
export RABBITMQ_IMAGE_TAG='4.1.3-debian-12-r1'
bash install-common-addons.sh
```
