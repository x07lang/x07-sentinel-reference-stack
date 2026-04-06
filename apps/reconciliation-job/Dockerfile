FROM ubuntu:24.04 AS builder

ARG X07_TAG

RUN apt-get update     && apt-get install -y --no-install-recommends ca-certificates curl gcc libc6-dev pkg-config libcurl4-openssl-dev libssl-dev     && rm -rf /var/lib/apt/lists/*

RUN arch="$(uname -m)"     && case "${arch}" in       x86_64|amd64) arch="x86_64" ;;       aarch64|arm64) arch="aarch64" ;;       *) echo "unsupported arch: ${arch}" >&2; exit 2 ;;     esac     && platform="unknown-linux-gnu"     && x07_version="${X07_TAG#v}"     && asset="x07-${x07_version}-${arch}-${platform}.tar.gz"     && url="https://github.com/x07lang/x07/releases/download/${X07_TAG}/${asset}"     && curl --proto '=https' --tlsv1.2 --retry 10 --retry-connrefused --retry-delay 1 --location --silent --show-error --fail-with-body --max-time 300 --output /tmp/x07.tar.gz "${url}"     && mkdir -p /opt/x07     && tar -xzf /tmp/x07.tar.gz -C /opt/x07     && rm -f /tmp/x07.tar.gz

ENV PATH="/opt/x07/bin:${PATH}"

WORKDIR /build
COPY apps/order-domain ./order-domain

WORKDIR /build/reconciliation-job
COPY apps/reconciliation-job/x07.json ./x07.json
COPY apps/reconciliation-job/x07.lock.json ./x07.lock.json
COPY apps/reconciliation-job/arch ./arch
COPY apps/reconciliation-job/policy ./policy
COPY apps/reconciliation-job/src ./src
COPY apps/reconciliation-job/tests ./tests

RUN ln -s ../order-domain order-domain
RUN x07 pkg lock --project x07.json
RUN x07 bundle --project x07.json --profile os --out /out/reconciliation-job

FROM ubuntu:24.04

ARG APP_VERSION

RUN apt-get update     && apt-get install -y --no-install-recommends ca-certificates curl openssl     && rm -rf /var/lib/apt/lists/*

ENV APP_VERSION="${APP_VERSION}"
ENV X07_OS_DB_NET_REQUIRE_VERIFY="false"

COPY --from=builder /out/reconciliation-job /usr/local/bin/reconciliation-job

ENTRYPOINT ["/usr/local/bin/reconciliation-job"]
