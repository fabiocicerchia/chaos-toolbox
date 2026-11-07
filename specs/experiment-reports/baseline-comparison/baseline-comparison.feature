@domain:experiment-reports @area:baseline-comparison @from:chaos-toolbox/chaosbox
Feature: Comparing a fault against a baseline
  Lets an operator compare an endpoint's latency under a fault with its latency just before, so the report shows the fault's effect.

  Background:
    Given the operator passes --probe http://checkout.example.com/healthz

  @id:experiment-reports.baseline-comparison.001 @rule:reports.baseline.measured-before-injection @inferred @source:chaosbox#sample_latency
  Scenario Outline: The baseline is measured before the fault is injected
    Given the endpoint is healthy
    When the operator runs `chaosbox delay --duration 60s --ms 300 --probe http://checkout.example.com/healthz <baseline option>`
    Then chaosbox prints "chaosbox: sampling baseline for <seconds>s"
    And no delay is applied during those <seconds> seconds
    And the delay is then applied for 60 seconds
    And the report shows a baseline row and a fault row

    Examples:
      | baseline option | seconds |
      |                 | 10      |
      | --baseline 30s  | 30      |
      | --baseline 1m   | 60      |

  @id:experiment-reports.baseline-comparison.002 @rule:reports.baseline.failed-fault-still-reported @inferred @source:chaosbox#emit_report @questionable
  Scenario Outline: A fault that never took effect still produces a report and a clean exit
    Given <situation>
    When the operator runs `chaosbox <experiment> --duration 60s --probe http://checkout.example.com/healthz`
    Then chaosbox prints the experiment's error
    And chaosbox still prints "chaosbox: experiment report — <experiment> for 60s against http://checkout.example.com/healthz" with a fault row
    And chaosbox exits with status 0

    Examples:
      | situation                                 | experiment |
      | chaosbox was not granted NET_ADMIN        | delay      |
      | the operator mistyped the experiment name | burn       |
