# chaos-toolbox — stress-ng + tc-based network chaos for lightweight
# experiments without installing a full Chaos Mesh.
FROM alpine:3.24
LABEL org.opencontainers.image.title="chaos-toolbox" \
      org.opencontainers.image.description="stress-ng + tc network chaos for lightweight resilience experiments" \
      org.opencontainers.image.licenses="Apache-2.0" \
      org.opencontainers.image.source="https://github.com/fabiocicerchia/chaos-toolbox"
RUN apk add --no-cache bash stress-ng iproute2 iputils curl
COPY chaos /usr/local/bin/chaos
# Network chaos needs NET_ADMIN in the target's netns; CPU/mem/io stress does not.
ENTRYPOINT ["/usr/local/bin/chaos"]
CMD ["--help"]
