# chaos-toolbox

[![CI](https://github.com/fabiocicerchia/chaos-toolbox/actions/workflows/ci.yml/badge.svg)](https://github.com/fabiocicerchia/chaos-toolbox/actions/workflows/ci.yml)
[![Code Quality](https://github.com/fabiocicerchia/chaos-toolbox/actions/workflows/code-quality.yml/badge.svg)](https://github.com/fabiocicerchia/chaos-toolbox/actions/workflows/code-quality.yml)
[![Security](https://github.com/fabiocicerchia/chaos-toolbox/actions/workflows/security.yml/badge.svg)](https://github.com/fabiocicerchia/chaos-toolbox/actions/workflows/security.yml)
[![License](https://img.shields.io/badge/license-Apache_2.0-blue.svg)](LICENSE)
[![OpenSSF Scorecard](https://api.securityscorecards.dev/projects/github.com/fabiocicerchia/chaos-toolbox/badge)](https://securityscorecards.dev/viewer/?uri=github.com/fabiocicerchia/chaos-toolbox)
[![CI carbon](https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/fabiocicerchia/chaos-toolbox/gh-pages/badge.json)](.github/workflows/carbon-badge.yml)

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
chaos delay --duration 60s [--ms 200] [--jitter 50] [--to CIDR]
chaos loss  --duration 60s [--pct 10]
chaos limit --duration 60s [--rate 1mbit]
chaos kill  --duration 60s --target <pattern> [--every 20s]
            [--mode docker|k8s] [--namespace ns] [--signal SIGKILL] [--dry-run]
```

### `chaos kill`

Restarts matching workloads repeatedly for the window, then stops — the
"does anything actually notice a pod dying?" experiment.

```sh
# Kubernetes: label selector, one pod deleted every 20s for 5 minutes
chaos kill --duration 5m --target app=checkout --namespace prod

# Docker: name pattern, SIGTERM instead of SIGKILL
chaos kill --duration 2m --target 'web_' --mode docker --signal SIGTERM

# See what it would hit first — always worth one run
chaos kill --duration 30s --target app=checkout --dry-run
```

The runtime is auto-detected (Docker socket present → `docker`, otherwise
`kubectl`); `--mode` overrides it. **`--target` has no default and never will**
— the blast radius of a typo should be one workload, not a cluster. In k8s mode
a target containing `=` is a label selector, anything else is a name pattern;
pods are deleted with `--wait=false`, because the experiment is watching the
controller replace them, not waiting on graceful shutdown.

Docker mode needs the socket mounted (`-v /var/run/docker.sock:/var/run/docker.sock`);
k8s mode needs a service account that can `list` and `delete` pods.

## Install

```sh
make build                       # builds ghcr.io/fabiocicerchia/chaos-toolbox:1.0.0 locally
docker pull ghcr.io/fabiocicerchia/chaos-toolbox:1.0.0
```

## Usage

Stress an existing pod's CPU (ephemeral container shares the cgroup budget):

```sh
kubectl debug -it my-pod --image=ghcr.io/fabiocicerchia/chaos-toolbox --target=app \
  -- chaos cpu --duration 2m --load 90
```

Add 200 ms latency to a pod's traffic (needs `NET_ADMIN`, shares the netns):

```sh
kubectl debug -it my-pod --image=ghcr.io/fabiocicerchia/chaos-toolbox --target=app \
  --profile=netadmin -- chaos delay --duration 60s --ms 200
```

Docker Compose resilience testing:

```sh
docker run --rm --network container:my-app --cap-add NET_ADMIN \
  ghcr.io/fabiocicerchia/chaos-toolbox loss --duration 30s --pct 15
```

## Development

`make build` / `make lint` / `make test` / `make release`.

## Documentation

Full docs live in [`docs/`](docs/). Runnable examples live in [`examples/`](examples/).

## License

Apache-2.0 — see [LICENSE](LICENSE).
