@domain:resource-pressure @area:disk-io-stress @from:chaos-toolbox/chaosbox
Feature: Generating disk I/O load
  Lets an operator put sustained I/O load on a host or container for a fixed window to see how a workload copes with slow disks.

  @id:resource-pressure.disk-io-stress.001 @rule:resources.io.sync-workers-plus-disk-writer @inferred @source:chaosbox#run_experiment
  Scenario Outline: I/O stress runs the chosen I/O workers plus one disk writer for the window
    Given the operator runs chaosbox where the I/O load should land
    When the operator runs `chaosbox io --duration 60s <options>`
    Then <workers> I/O workers run for 60 seconds
    And exactly one disk-writing worker runs alongside them, whatever --workers says

    Examples:
      | options     | workers |
      |             | 2       |
      | --workers 6 | 6       |
