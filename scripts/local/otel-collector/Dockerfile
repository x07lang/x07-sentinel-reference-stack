FROM ubuntu:24.04

ARG OTEL_VERSION

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl \
    && rm -rf /var/lib/apt/lists/*

RUN arch="$(uname -m)" \
    && case "${arch}" in \
      x86_64|amd64) arch="amd64" ;; \
      aarch64|arm64) arch="arm64" ;; \
      *) echo "unsupported arch: ${arch}" >&2; exit 2 ;; \
    esac \
    && url="https://github.com/open-telemetry/opentelemetry-collector-releases/releases/download/v${OTEL_VERSION}/otelcol-contrib_${OTEL_VERSION}_linux_${arch}.tar.gz" \
    && curl -fSL --output /tmp/otelcol-contrib.tgz "${url}" \
    && tar -xzf /tmp/otelcol-contrib.tgz -C /usr/local/bin otelcol-contrib \
    && rm -f /tmp/otelcol-contrib.tgz

ENTRYPOINT ["/usr/local/bin/otelcol-contrib"]
