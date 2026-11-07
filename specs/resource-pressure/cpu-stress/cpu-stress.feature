@domain:resource-pressure @area:cpu-stress @from:chaos-toolbox/chaosbox
Feature: Loading CPUs
  Lets an operator put a known CPU load on a host or container for a fixed window to see how a workload copes with contention.

  @id:resource-pressure.cpu-stress.001 @rule:resources.cpu.workers-at-target-load @inferred @source:chaosbox#run_experiment
  Scenario Outline: CPU stress runs the chosen workers at the target load for the window
    Given the operator runs chaosbox where the CPU load should land
    When the operator runs `chaosbox cpu --duration <duration> <options>`
    Then chaosbox prints "chaosbox: cpu for <seconds>s"
    And <workers> CPU workers run at <load>% load
    And the load stops after <seconds> seconds and a brief metrics summary is printed

    Examples:
      | duration | options               | workers | load | seconds |
      | 60s      |                       | 2       | 80   | 60      |
      | 2m       | --workers 4 --load 95 | 4       | 95   | 120     |
