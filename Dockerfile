# syntax=docker/dockerfile:1.7

ARG GO_VERSION=1.26.0
FROM golang:${GO_VERSION}-alpine AS builder

ARG YAGPDB_VERSION=v2.83.1
ARG YAGPDB_COMMIT=7d2a3ba8975a4d0b30c814ada06ca43a969d7348
RUN apk add --no-cache git ca-certificates
WORKDIR /src
RUN git clone https://github.com/botlabs-gg/yagpdb.git . \
    && git checkout "${YAGPDB_COMMIT}" \
    && test "$(git rev-parse HEAD)" = "${YAGPDB_COMMIT}"
WORKDIR /src/cmd/yagpdb
RUN GOEXPERIMENT=jsonv2 CGO_ENABLED=0 GOOS=linux go build \
    -trimpath \
    -ldflags "-s -w -X github.com/botlabs-gg/yagpdb/v2/common.VERSION=${YAGPDB_VERSION}" \
    -o /out/yagpdb .

FROM alpine:3.22
ARG CONTAINER_VERSION=0.1.0
ARG YAGPDB_VERSION=v2.83.1
ARG YAGPDB_COMMIT=7d2a3ba8975a4d0b30c814ada06ca43a969d7348
LABEL org.opencontainers.image.title="YAGPDB container" \
      org.opencontainers.image.description="Production-oriented self-hosted YAGPDB OCI image" \
      org.opencontainers.image.source="https://github.com/Ploos-AS/yagpdb" \
      org.opencontainers.image.documentation="https://github.com/Ploos-AS/yagpdb#readme" \
      org.opencontainers.image.vendor="Ploos AS" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.version="${CONTAINER_VERSION}" \
      org.opencontainers.image.revision="${YAGPDB_COMMIT}" \
      io.ploos.yagpdb.upstream.version="${YAGPDB_VERSION}"

RUN apk add --no-cache ca-certificates ffmpeg tzdata busybox-extras \
    && addgroup -g 1000 yagpdb \
    && adduser -D -H -u 1000 -G yagpdb yagpdb \
    && install -d -o yagpdb -g yagpdb /data /data/soundboard
COPY --from=builder /out/yagpdb /usr/local/bin/yagpdb
COPY rootfs/usr/local/bin/healthcheck /usr/local/bin/healthcheck
RUN chmod 0755 /usr/local/bin/yagpdb /usr/local/bin/healthcheck

WORKDIR /data
VOLUME ["/data/soundboard"]
EXPOSE 5000
USER 1000:1000
HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 CMD ["healthcheck"]
ENTRYPOINT ["/usr/local/bin/yagpdb"]
CMD ["-all", "-pa", "-https=false", "-exthttps=true"]
