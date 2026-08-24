# Getting Started

## Prerequisites

Docker, or a Kubernetes cluster you are allowed to run ephemeral containers
against. Nothing to install locally — the image is the tool.

Network experiments additionally need `NET_ADMIN` in the target's network
namespace. Stress experiments need no capabilities.

## First experiment — nothing shared, nothing at risk

```sh
docker run --rm fabiocicerchia/chaos-toolbox cpu --duration 10s --workers 1
```

This burns one CPU worker for ten seconds inside its own container and exits.
Use it to confirm the image runs before you point it at anything that matters.

Leave `--duration` off and it refuses. That is the rail, not a bug:

```sh
docker run --rm fabiocicerchia/chaos-toolbox cpu
# chaos: --duration is required (safety rail)
```

## Stress a real workload

The experiment has to land in the *target's* cgroup, which means sharing it:

```sh
kubectl debug -it my-pod --image=fabiocicerchia/chaos-toolbox --target=app \
  -- chaos cpu --duration 2m --load 90
```

Without `--target=app` the ephemeral container gets its own cgroup and the
application never notices. That is the single most common way to run this and
conclude, wrongly, that the service is resilient.

The Docker equivalent shares the cgroup and the netns of a running container:

```sh
docker run --rm --network container:my-app --cgroupns host \
  fabiocicerchia/chaos-toolbox mem --duration 60s --bytes 512M
```

## Network experiments

These need `NET_ADMIN` and the target's network namespace:

```sh
kubectl debug -it my-pod --image=fabiocicerchia/chaos-toolbox --target=app \
  --profile=netadmin -- chaos delay --duration 60s --ms 200 --jitter 50
```

```sh
docker run --rm --network container:my-app --cap-add NET_ADMIN \
  fabiocicerchia/chaos-toolbox loss --duration 30s --pct 10
```

`--profile=netadmin` is what grants the capability to a `kubectl debug`
container; without it the `tc` call fails with `Operation not permitted`.

If the interface is not `eth0` — multus, a second NIC, a host-network pod —
pass `--dev`. Check first with
`kubectl debug ... -- chaos --help` and `ip -brief link` from inside the netns.

## Confirm the cleanup happened

Watch a delay experiment from a second shell in the same namespace:

```sh
tc qdisc show dev eth0     # during:  ... netem delay 200ms 50ms
tc qdisc show dev eth0     # after:   ... pfifo_fast   (or noqueue)
```

If a container was `kill -9`ed and the qdisc is still there, remove it by hand:

```sh
tc qdisc del dev eth0 root
```

## Before you run this against production

- Start with a duration you would be comfortable explaining — 30 seconds, not
  ten minutes. Nothing here ramps or backs off.
- Know which pod you are hitting. `--target` and `--network container:` both
  take a name, and both are silent when you get it wrong in the safe direction.
- `mem` competes with the container's own limit. On a pod with a tight memory
  limit, `--bytes` large enough will get the *application* OOM-killed, which is
  a valid experiment and a surprising one if it was not the intent.

## Development

```sh
make build     # docker build
make lint      # hadolint + shellcheck on `chaos`
make test      # smoke tests: the duration rail, cpu stress, netem apply+cleanup
make release   # multi-arch buildx push
```

`make test` needs a Docker daemon that allows `--cap-add NET_ADMIN`, since the
cleanup assertion is the test worth having.

## Proving what the experiment did

Without a probe an experiment proves it ran, not what it did — which is not
evidence anyone can take to a review. `--probe` samples latency against a
target before injection and again during it:

```sh
chaos delay --duration 60s --ms 300 \
  --probe http://checkout.internal/health \
  --baseline 30s --report experiment.json
```

```
chaos: experiment report — delay for 60s against http://checkout.internal/health
  phase      samples  errors       p50       p90       p99
  baseline        30       0   0.0121s   0.0180s   0.0233s
  fault           59       2   0.3140s   0.3302s   0.3511s
  report written to experiment.json
```

The JSON carries the same figures plus the fault, its parameters and its
duration, so a report says what was done as well as what happened.

Three choices worth knowing:

**The baseline is sampled first, on its own.** A "before" measured while the
fault was already applied is not a before. The fault window is then sampled
*while* the experiment runs, ending a second early so the last probe cannot
land after teardown and read as a recovery.

**Too few samples withholds the percentiles** rather than printing them. A p99
from three requests is a number people quote. Lengthen `--duration` or
`--baseline`, or shorten `--probe-interval`.

**Errors are counted, not timed.** A request that failed has no latency worth
putting in a percentile, so it moves the error column instead of the p99.

The probe is one GET per interval, not a load generator: the point is to
observe the path a real client takes while the fault is applied, and a tool
that saturated the target would be measuring itself.
