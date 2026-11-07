@domain:workload-disruption @area:dry-run @from:chaos-toolbox/chaosbox
Feature: Previewing a kill experiment
  Lets an operator see exactly which workloads a kill experiment would hit before running it for real.

  @id:workload-disruption.dry-run.001 @rule:workloads.dryrun.lists-without-killing @inferred @source:chaosbox#run_kill
  Scenario: A dry run names every workload it would kill and kills none
    Given pod web-1 is labelled app=web
    When the operator runs `chaosbox kill --duration 2s --every 1s --mode k8s --target app=web --dry-run`
    Then chaosbox prints "chaosbox: kill mode=k8s target='app=web' every=1s (dry run)"
    And chaosbox prints "chaosbox: would kill pod/web-1" each round
    And chaosbox prints "chaosbox: kill finished — 0 kill(s) over 2s"
    And pod/web-1 is still running
