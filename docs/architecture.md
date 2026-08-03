# Architecture

One Alpine image, one bash script, no daemon and no control plane. That is the
whole design, and it is the point: a chaos experiment you cannot fully read in
one sitting is one you will not run against production.

```
chaos <experiment> --duration Nn
        │
        ├── cpu / mem / io  ──► stress-ng   (this container's cgroup)
        │                        exec'd, so stress-ng owns PID 1 and its own timeout
        │
        └── delay / loss / limit ──► tc qdisc on $DEV  (this container's netns)
                                     trap EXIT INT TERM ──► tc qdisc del
```

## Two families, two blast radii

They look alike on the command line and behave nothing alike.

**Stress experiments (`cpu`, `mem`, `io`)** are `exec`d, so `stress-ng` becomes
PID 1 and enforces its own `--timeout`. They affect whatever cgroup the
container is in — which is why `kubectl debug --target=app` matters: an
ephemeral container without `--target` gets its own cgroup, and the experiment
stresses nothing the application can feel.

**Network experiments (`delay`, `loss`, `limit`) mutate kernel state that
outlives the process.** A `tc qdisc` stays on the interface after the container
exits. That is the failure mode this image exists to avoid, and the reason the
network branch is *not* `exec`d: the script has to survive in order to clean up.

## The two safety rails

**`--duration` is mandatory.** There is no default and no way to omit it. An
experiment with no end is not an experiment; it is an incident with better
paperwork. `test.sh` asserts that a missing `--duration` is rejected.

**The qdisc is removed on any exit.** `trap netem_cleanup EXIT INT TERM` — so a
`Ctrl-C`, a `docker stop` (SIGTERM), or the script finishing normally all end
with `tc qdisc del dev $DEV root`. `test.sh` asserts both halves: that netem is
actually applied while running, and that it is gone afterwards.

The one case no trap can cover is `SIGKILL`. If a chaos container is `kill -9`ed
mid-experiment the qdisc survives it; remove it with
`tc qdisc del dev eth0 root` from anything sharing that netns.

## Where the experiment lands

`delay`, `loss` and `limit` act on `$DEV` (default `eth0`) **in this
container's network namespace**. That namespace is shared only when you ask for
it:

| How it is run | Whose network is affected |
|---|---|
| `kubectl debug --target=app` | the pod's — containers in a pod share one netns |
| `docker run --network container:app` | that container's |
| `docker run` (plain) | its own, and nothing else — an experiment that measures nothing |

`NET_ADMIN` is required for the `tc` calls and only for those; the stress
experiments need no capabilities at all.

## Adding an experiment

1. A `case` arm in `chaos`, plus its flags in the `while` parser and the
   defaults line.
2. Its usage line in the header comment — `usage()` prints that comment block,
   so the help text cannot drift from the script.
3. If it changes kernel state rather than just this process, it belongs in the
   trapped branch, not the `exec` branch. That is the only structural decision
   in the script, and getting it wrong leaves rules behind on someone's pod.
4. A case in `test.sh`; for a network experiment, an assertion that it cleans
   up, not just that it applied.
