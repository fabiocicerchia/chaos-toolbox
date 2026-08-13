# chaos-toolbox — stress-ng + tc-based network chaos for lightweight
# experiments without installing a full Chaos Mesh.
FROM alpine:3.24@sha256:28bd5fe8b56d1bd048e5babf5b10710ebe0bae67db86916198a6eec434943f8b
LABEL org.opencontainers.image.title="chaos-toolbox" \
      org.opencontainers.image.description="stress-ng + tc network chaos for lightweight resilience experiments" \
      org.opencontainers.image.licenses="Apache-2.0 AND GPL-2.0-or-later AND GPL-3.0-or-later" \
      org.opencontainers.image.source="https://github.com/fabiocicerchia/chaos-toolbox"
ARG KUBECTL_VERSION=1.33.2
RUN apk add --no-cache bash stress-ng iproute2 iputils curl docker-cli
# `chaos kill` in k8s mode. Pinned rather than :latest so an experiment run
# next month talks to the same client it was tested against. # VERSION-BUMP
RUN ARCH="$(uname -m)" \
 && case "$ARCH" in x86_64) ARCH=amd64 ;; aarch64) ARCH=arm64 ;; esac \
 && curl -fsSL -o /usr/local/bin/kubectl \
      "https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/${ARCH}/kubectl" \
 && chmod +x /usr/local/bin/kubectl \
 && kubectl version --client=true --output=yaml >/dev/null
COPY NOTICE /NOTICE
COPY chaos /usr/local/bin/chaos
# Network chaos needs NET_ADMIN in the target's netns; CPU/mem/io stress does not.
ENTRYPOINT ["/usr/local/bin/chaos"]
CMD ["--help"]
