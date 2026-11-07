@domain:workload-disruption @area:target-selection @from:chaos-toolbox/chaosbox
Feature: Choosing what to kill
  Keeps the blast radius of a kill experiment to the workload the operator named, so a typo cannot take out a cluster.

  @id:workload-disruption.target-selection.001 @rule:workloads.kill.target-required @inferred @source:chaosbox#run_kill
  Scenario: A kill experiment without a target is refused
    Given containers and pods are running
    When the operator runs `chaosbox kill --duration 60s` without --target
    Then chaosbox prints "chaosbox: kill requires --target (no default: a typo must not take out a cluster)"
    And chaosbox exits with status 64
    And nothing is killed

  @id:workload-disruption.target-selection.002 @rule:workloads.kill.target-pattern-matching @inferred @source:chaosbox#kill_targets_k8s @questionable
  Scenario Outline: A target pattern matches every workload whose name contains it, or every pod with the label
    Given <workloads> are running
    When the operator runs `chaosbox kill --duration 60s --mode <mode> --target <target>`
    Then the experiment kills <matched>
    And <untouched> keeps running

    Examples:
      | mode   | target  | workloads                                                 | matched                     | untouched |
      | docker | web     | containers web_1, webhook_1 and api_1                     | web_1 and webhook_1         | api_1     |
      | k8s    | web     | pods web-1, webhook-0 and api-1                           | pod/web-1 and pod/webhook-0 | pod/api-1 |
      | k8s    | app=web | pod web-1 labelled app=web and pod api-1 labelled app=api | pod/web-1                   | pod/api-1 |
