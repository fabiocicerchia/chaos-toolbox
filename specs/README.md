# Specifications of chaos-toolbox

What this code does, one atomic Gherkin scenario per behaviour, read from the code by code-atlas.
Tags: `@verified` a test asserts it · `@inferred` read from the code only · `@gap` an entry point no test covers · `@human` written or amended by a person, never rewritten.

## Developer tooling
The contributor workflow that keeps the project correct and secure.

- **Smoke tests**: [Smoke-testing a built image](developer-tooling/smoke-tests/smoke-tests.feature) (4)

## Documentation
The user-facing reference material for chaos-toolbox.

- **Docs site styling**: [Branded, self-contained documentation site](documentation/docs-site-styling/docs-site-styling.feature) (4)

## Experiment reports
Turns an experiment into evidence by measuring a service's latency before and during the fault.

- **Baseline comparison**: [Comparing a fault against a baseline](experiment-reports/baseline-comparison/baseline-comparison.feature) (2)
- **JSON report export**: [Exporting an experiment report](experiment-reports/json-report/json-report.feature) (3)
- **Latency probing**: [Probing an endpoint during an experiment](experiment-reports/latency-probing/latency-probing.feature) (2)
- **Percentile summary**: [Summarising probe latency per phase](experiment-reports/percentile-summary/percentile-summary.feature) (3)

## Network faults
Degrades network traffic of the container's network namespace to mimic slow, lossy or constrained links.

- **Bandwidth limit**: [Capping bandwidth](network-faults/bandwidth-limit/bandwidth-limit.feature) (1)
- **Destination targeting**: [Degrading one dependency only](network-faults/destination-targeting/destination-targeting.feature) (1)
- **Latency injection**: [Injecting network latency](network-faults/latency-injection/latency-injection.feature) (1)
- **Packet loss**: [Dropping packets](network-faults/packet-loss/packet-loss.feature) (1)

## Packaging and distribution
How chaos-toolbox is built, shipped and installed for users.

- **Container image**: [Shipping the chaos toolbox as one image](packaging-distribution/container-image/container-image.feature) (3)
- **Local install**: [Installing chaosbox on a host](packaging-distribution/local-install/local-install.feature) (3)

## Resource pressure
Time-boxed stress on the host's compute, memory and storage to see how workloads behave when resources run short.

- **CPU stress**: [Loading CPUs](resource-pressure/cpu-stress/cpu-stress.feature) (1)
- **Disk I/O stress**: [Generating disk I/O load](resource-pressure/disk-io-stress/disk-io-stress.feature) (1)
- **Memory stress**: [Putting memory under pressure](resource-pressure/memory-stress/memory-stress.feature) (1)

## Safety rails
Guarantees that every experiment is bounded in time, validated up front, and leaves nothing behind.

- **Automatic cleanup**: [Removing network faults when an experiment ends](safety-rails/automatic-cleanup/automatic-cleanup.feature) (5)
- **Input validation**: [Refusing malformed experiments](safety-rails/input-validation/input-validation.feature) (4)
- **Mandatory duration**: [Time-boxing every experiment](safety-rails/mandatory-duration/mandatory-duration.feature) (2)
- **Usage help**: [Getting the command reference](safety-rails/usage-help/usage-help.feature) (1)

## Workload disruption
Repeatedly kills matching containers or pods during the window to test restart and recovery behaviour.

- **Docker container kills**: [Killing Docker containers](workload-disruption/docker-kills/docker-kills.feature) (1)
- **Dry run**: [Previewing a kill experiment](workload-disruption/dry-run/kill-dry-run.feature) (1)
- **Kill cadence and signals**: [Repeating kills across the window](workload-disruption/kill-cadence/kill-cadence.feature) (3)
- **Kubernetes pod kills**: [Deleting Kubernetes pods](workload-disruption/kubernetes-pod-kills/kubernetes-pod-kills.feature) (4)
- **Target selection**: [Choosing what to kill](workload-disruption/target-selection/kill-target-selection.feature) (2)
