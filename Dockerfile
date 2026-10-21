# chaos-toolbox — stress-ng + tc-based network chaos for lightweight
# experiments without installing a full Chaos Mesh.

# glibc libfaketime for clock-skew targets; this stage only donates the .so.
# Its glibc sets the floor: the library needs GLIBC_2.34 on the target.
FROM debian:bookworm-slim@sha256:7ff6ba31527b9e336162fa061746c366c4b2032f4d2cff2078bea43f78efe3f8 AS faketime-glibc
RUN apt-get update \
 && apt-get install -y --no-install-recommends libfaketime \
 && rm -rf /var/lib/apt/lists/* \
 && mkdir -p /out \
 && cp /usr/lib/*/faketime/libfaketime.so.1 /out/

FROM alpine:3.24@sha256:294b683cb724975bec92580e1e685676bd4b50bda910ddb8c51d4cabeaec77e6
LABEL org.opencontainers.image.title="chaos-toolbox" \
      org.opencontainers.image.description="stress-ng + tc network chaos for lightweight resilience experiments" \
      org.opencontainers.image.licenses="Apache-2.0 AND GPL-2.0-or-later AND GPL-3.0-or-later" \
      org.opencontainers.image.source="https://github.com/fabiocicerchia/chaos-toolbox"
ARG KUBECTL_VERSION=1.33.2
# Fixed paths, copied into a target by an init container: pick the build that
# matches the target's libc (readelf -l shows its ELF interpreter).
RUN apk add --no-cache bash stress-ng iproute2 iputils curl docker-cli binutils libfaketime \
 && mkdir -p /opt/faketime/musl \
 && cp /usr/lib/faketime/libfaketime.so.1 /opt/faketime/musl/
COPY --from=faketime-glibc /out/libfaketime.so.1 /opt/faketime/glibc/libfaketime.so.1
# `chaosbox kill` in k8s mode. Pinned rather than :latest so an experiment run
# next month talks to the same client it was tested against. # VERSION-BUMP
RUN ARCH="$(uname -m)" \
 && case "$ARCH" in x86_64) ARCH=amd64 ;; aarch64) ARCH=arm64 ;; esac \
 && curl -fsSL -o /usr/local/bin/kubectl \
      "https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/${ARCH}/kubectl" \
 && chmod +x /usr/local/bin/kubectl \
 && kubectl version --client=true --output=yaml >/dev/null
COPY NOTICE /NOTICE
COPY chaosbox /usr/local/bin/chaosbox
# Network chaos needs NET_ADMIN in the target's netns; CPU/mem/io stress does not.
ENTRYPOINT ["/usr/local/bin/chaosbox"]
CMD ["--help"]
