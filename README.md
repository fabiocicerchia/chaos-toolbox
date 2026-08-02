# chaos-toolbox

**stress-ng + tc/netem chaos experiments** in one small image — CPU, memory
and I/O pressure, latency, packet loss and bandwidth limits — for lightweight
resilience testing without installing a full Chaos Mesh.

Built-in safety rails: every experiment **requires `--duration`**, and
network rules are **removed automatically on exit** (including Ctrl-C).

## Experiments

```text
chaos cpu   --duration 60s [--workers 2] [--load 80]
chaos mem   --duration 60s [--bytes 256M]
chaos io    --duration 60s [--workers 2]
chaos delay --duration 60s [--ms 200] [--jitter 50]
chaos loss  --duration 60s [--pct 10]
chaos limit --duration 60s [--rate 1mbit]
```

## Usage

Stress an existing pod's CPU (ephemeral container shares the cgroup budget):

```sh
kubectl debug -it my-pod --image=fabiocicerchia/chaos-toolbox --target=app \
  -- chaos cpu --duration 2m --load 90
```

Add 200 ms latency to a pod's traffic (needs `NET_ADMIN`, shares the netns):

```sh
kubectl debug -it my-pod --image=fabiocicerchia/chaos-toolbox --target=app \
  --profile=netadmin -- chaos delay --duration 60s --ms 200
```

Docker Compose resilience testing:

```sh
docker run --rm --network container:my-app --cap-add NET_ADMIN \
  fabiocicerchia/chaos-toolbox loss --duration 30s --pct 15
```

## Status & roadmap

- [x] 6 experiments, duration rail, netem auto-cleanup, tests
- [ ] `chaos kill` (pumba-style container restarts, Docker socket mode)
- [ ] Scoped netem (per-destination CIDR filters, not whole-interface)
- [ ] Experiment report (before/after latency percentiles)

## Development

`make build` / `make lint` / `make test` / `make release`.

## License

MIT — see [LICENSE](LICENSE).
