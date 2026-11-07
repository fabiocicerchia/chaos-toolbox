@domain:resource-pressure @area:memory-stress @from:chaos-toolbox/chaosbox
Feature: Putting memory under pressure
  Lets an operator simulate memory pressure for a fixed window to see whether a workload degrades or gets OOM-killed.

  @id:resource-pressure.memory-stress.001 @rule:resources.mem.bytes-per-worker @inferred @source:chaosbox#run_experiment @questionable
  Scenario Outline: Memory stress churns the chosen amount of memory on each worker
    Given the operator runs chaosbox where the memory pressure should land
    When the operator runs `chaosbox mem --duration 60s <options>`
    Then <workers> memory workers run for 60 seconds
    And each worker allocates and churns <bytes>, <total> in all

    Examples:
      | options                | workers | bytes | total |
      |                        | 2       | 256M  | 512M  |
      | --bytes 1G --workers 1 | 1       | 1G    | 1G    |
