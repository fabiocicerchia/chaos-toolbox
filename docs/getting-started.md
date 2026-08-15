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

## Degrading one dependency, not the whole host

`delay`, `loss` and `limit` act on an interface, so by default they degrade
everything the host talks to — including the metrics pipeline and the shell
watching the experiment. `--to` narrows them to destination CIDRs:

```sh
chaos delay --duration 60s --ms 200 --to 10.0.3.0/24            # one dependency
chaos loss  --duration 60s --pct 10 --to 10.0.3.7/32,10.0.4.0/24  # several
```

Repeat the flag or comma-separate. Traffic to anything else is untouched, which
is what keeps the experiment observable while it runs.

Under the hood this is a `prio` qdisc whose priomap sends **all** ordinary
traffic to band 1:1 — the default map spreads packets across bands by TOS,
which would drag some unmatched traffic through the impaired band by accident.
Band 1:4 carries the netem/tbf qdisc and is reachable only through an explicit
`u32` destination filter.

Teardown is unchanged: deleting the root qdisc takes the whole tree with it,
filters included, and the duration rail still applies. `test.sh` asserts both
halves — that a gateway inside the CIDR is delayed, and that the same gateway
is *not* delayed when the CIDR does not contain it.
