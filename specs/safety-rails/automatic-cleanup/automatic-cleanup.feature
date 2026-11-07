@domain:safety-rails @area:automatic-cleanup @from:chaos-toolbox/chaosbox
Feature: Removing network faults when an experiment ends
  Guarantees that an injected network fault never outlives its experiment, however the experiment ends.

  Background:
    Given chaosbox shares the network namespace of the workload under test
    And chaosbox has been granted NET_ADMIN

  @id:safety-rails.automatic-cleanup.001 @rule:safety.cleanup.removed-at-window-end @inferred @source:chaosbox#netem_cleanup
  Scenario Outline: Network faults are removed when the window ends
    Given no other traffic shaping is installed on eth0
    When the operator runs `chaosbox <experiment> --duration 60s <scope>`
    Then the fault is in place for 60 seconds
    And chaosbox prints "chaosbox: network rules cleaned up"
    And eth0 carries traffic with no delay, loss or rate cap

    Examples:
      | experiment | scope            |
      | delay      |                  |
      | loss       |                  |
      | limit      |                  |
      | delay      | --to 10.0.4.0/24 |

  @id:safety-rails.automatic-cleanup.002 @rule:safety.cleanup.removed-on-interrupt @inferred @source:chaosbox#netem_cleanup
  Scenario: Pressing Ctrl-C removes the network fault at once
    Given a delay experiment with --duration 10m is running in an interactive terminal
    When the operator presses Ctrl-C
    Then the delay is removed straight away, not at the end of the window
    And chaosbox prints "chaosbox: network rules cleaned up"

  @id:safety-rails.automatic-cleanup.003 @rule:safety.cleanup.terminate-deferred-until-window-end @inferred @source:chaosbox#run_experiment @questionable
  Scenario: A termination request leaves the network fault in place until the window ends
    Given a delay experiment with --duration 10m runs as a sidecar sharing the workload's network
    When the platform stops the chaosbox container 30 seconds in
    Then the delay stays on the shared interface after the stop request
    And if the platform force-kills chaosbox before the 10 minutes are up, the delay is never removed
    And the workload keeps its delayed traffic after chaosbox is gone

  @id:safety-rails.automatic-cleanup.004 @rule:safety.cleanup.removed-on-error @inferred @source:chaosbox#apply_netem
  Scenario: A fault that fails partway through setup is removed again
    Given the scoped delay's root rule installs but a destination filter is rejected
    When the operator runs `chaosbox delay --duration 60s --to 10.0.4.0/24`
    Then chaosbox prints the tc error
    And chaosbox prints "chaosbox: network rules cleaned up"
    And no partial rule is left on eth0
    And chaosbox exits with a non-zero status

  @id:safety-rails.automatic-cleanup.005 @rule:safety.cleanup.removes-foreign-root-shaping @inferred @source:chaosbox#netem_cleanup @questionable
  Scenario: Cleanup also removes traffic shaping that chaosbox did not install
    Given eth0 already has a non-default root rule, for example from another running chaosbox delay
    When the operator runs `chaosbox loss --duration 60s`
    Then the loss experiment fails to install its rule
    And chaosbox prints "chaosbox: network rules cleaned up"
    And the existing rule on eth0 is removed, ending the other experiment early
