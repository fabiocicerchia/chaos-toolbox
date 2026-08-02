# Basic Example

What it shows: 200 ms of injected latency on a real service, and the rules
removing themselves when the experiment's duration runs out.

## Run

Start the target and measure it clean:

```sh
docker compose -f compose.yaml up -d app
curl -o /dev/null -s -w 'clean:   %{time_total}s\n' http://localhost:8080/
```

Start the experiment and measure again:

```sh
docker compose -f compose.yaml up -d chaos
curl -o /dev/null -s -w 'delayed: %{time_total}s\n' http://localhost:8080/
```

Expect roughly `0.001s` then `0.2s` — the round trip picks up the injected
delay once, on the way back.

## Watch it clean up

The experiment ends by itself after 60 seconds. Before then:

```sh
docker compose -f compose.yaml exec chaos tc qdisc show dev eth0
#   qdisc netem 8001: root refcnt 2 limit 1000 delay 200ms 50ms
```

After it exits, latency is back to baseline and the qdisc is gone — the
`trap ... EXIT` in `chaos` removes it whether the run finished, was stopped, or
was interrupted.

```sh
curl -o /dev/null -s -w 'after:   %{time_total}s\n' http://localhost:8080/
docker compose -f compose.yaml down
```

## Vary it

```sh
# 10% packet loss instead of latency
docker compose -f compose.yaml run --rm chaos loss --duration 30s --pct 10

# throttle to 1 mbit
docker compose -f compose.yaml run --rm chaos limit --duration 30s --rate 1mbit
```

Note that `cpu`, `mem` and `io` will *not* do anything useful here: Compose
shares the network namespace, not the cgroup, so a stress experiment would
pressure the chaos container alone. Stressing a real workload needs
`kubectl debug --target=` or `--cgroupns host`; see
[Getting Started](../../docs/getting-started.md).
