@domain:network-faults @area:packet-loss @from:chaos-toolbox/chaosbox
Feature: Dropping packets
  Lets an operator drop a share of a workload's outgoing packets for a fixed window to test retransmits and error handling.

  Background:
    Given chaosbox shares the network namespace of the workload under test
    And chaosbox has been granted NET_ADMIN

  @id:network-faults.packet-loss.001 @rule:network.loss.drop-percentage @inferred @source:chaosbox#run_experiment
  Scenario Outline: Loss drops the chosen percentage of outgoing packets
    Given no destination scope is given
    When the operator runs `chaosbox loss --duration 60s <options>`
    Then <pct>% of packets leaving eth0 are dropped
    And the loss is in place for 60 seconds

    Examples:
      | options  | pct |
      |          | 10  |
      | --pct 25 | 25  |
