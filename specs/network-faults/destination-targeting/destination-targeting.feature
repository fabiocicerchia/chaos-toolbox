@domain:network-faults @area:destination-targeting @from:chaos-toolbox/chaosbox
Feature: Degrading one dependency only
  Lets an operator aim a network fault at chosen destinations, so one dependency is degraded while monitoring and the rest of the host's traffic stay untouched.

  Background:
    Given chaosbox shares the network namespace of the workload under test
    And chaosbox has been granted NET_ADMIN

  @id:network-faults.destination-targeting.001 @rule:network.targeting.only-matching-destinations @inferred @source:chaosbox#apply_netem
  Scenario Outline: A scoped fault degrades only traffic to the named destinations
    Given the workload talks to 10.0.4.0/24, 192.0.2.10 and 198.51.100.0/24, and to a metrics backend outside them
    When the operator runs `chaosbox delay --duration 60s --ms 300 <scope>`
    Then chaosbox prints a "chaosbox: scoped to" line for each of <scoped>
    And traffic to <scoped> is delayed by 300ms
    And traffic to every other destination, the metrics backend included, is not delayed

    Examples:
      | scope                            | scoped                          |
      | --to 10.0.4.0/24                 | 10.0.4.0/24                     |
      | --to 10.0.4.0/24 --to 192.0.2.10 | 10.0.4.0/24 and 192.0.2.10      |
      | --to 10.0.4.0/24,198.51.100.0/24 | 10.0.4.0/24 and 198.51.100.0/24 |
