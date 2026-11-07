@domain:network-faults @area:latency-injection @from:chaos-toolbox/chaosbox
Feature: Injecting network latency
  Lets an operator add delay to a workload's outgoing traffic for a fixed window to test timeouts and retries.

  Background:
    Given chaosbox shares the network namespace of the workload under test
    And chaosbox has been granted NET_ADMIN

  @id:network-faults.latency-injection.001 @rule:network.latency.delay-with-jitter @inferred @source:chaosbox#apply_netem
  Scenario Outline: Delay adds fixed latency with jitter to every outgoing packet on the interface
    Given no destination scope is given
    When the operator runs `chaosbox delay --duration 60s <options>`
    Then every packet leaving <interface> is delayed by <ms>ms with <jitter>ms of jitter
    And traffic to every destination is affected, including whatever is monitoring the experiment
    And the delay is in place for 60 seconds

    Examples:
      | options                        | interface | ms  | jitter |
      |                                | eth0      | 200 | 50     |
      | --ms 300 --jitter 0 --dev eth1 | eth1      | 300 | 0      |
