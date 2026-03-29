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
