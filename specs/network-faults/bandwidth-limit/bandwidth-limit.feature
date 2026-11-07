@domain:network-faults @area:bandwidth-limit @from:chaos-toolbox/chaosbox
Feature: Capping bandwidth
  Lets an operator throttle a workload's outgoing throughput for a fixed window to test behaviour on a slow link.

  Background:
    Given chaosbox shares the network namespace of the workload under test
    And chaosbox has been granted NET_ADMIN

  @id:network-faults.bandwidth-limit.001 @rule:network.bandwidth.rate-cap @inferred @source:chaosbox#run_experiment
  Scenario Outline: Limit caps outgoing throughput at the chosen rate
    Given no destination scope is given
    When the operator runs `chaosbox limit --duration 60s <options>`
    Then outgoing throughput on eth0 is capped at <rate>
    And packets that would wait in the queue longer than 400ms are dropped
    And the cap is in place for 60 seconds

    Examples:
      | options        | rate    |
      |                | 1mbit   |
      | --rate 256kbit | 256kbit |
