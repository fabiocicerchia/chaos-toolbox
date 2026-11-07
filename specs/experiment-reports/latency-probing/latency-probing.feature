@domain:experiment-reports @area:latency-probing @from:chaos-toolbox/chaosbox
Feature: Probing an endpoint during an experiment
  Lets an operator measure what a fault actually did to a real endpoint, instead of only proving the experiment ran.

  Background:
    Given the operator passes --probe http://checkout.example.com/healthz

  @id:experiment-reports.latency-probing.001 @rule:reports.probe.sample-classification @inferred @source:chaosbox#sample_latency
  Scenario Outline: Only 2xx and 3xx probe responses count as successful samples
    Given the endpoint answers a probe with <response>
    When the operator runs `chaosbox delay --duration 60s --probe http://checkout.example.com/healthz`
    Then that probe is counted as a sample in its phase
    And it is counted as <counted>

    Examples:
      | response                    | counted                             |
      | 200 OK                      | a success, timed in the percentiles |
      | 301 Moved Permanently       | a success, timed in the percentiles |
      | 404 Not Found               | an error, not timed                 |
      | 503 Service Unavailable     | an error, not timed                 |
      | no answer within 10 seconds | an error, not timed                 |
      | connection refused          | an error, not timed                 |

  @id:experiment-reports.latency-probing.002 @rule:reports.probe.samples-throughout-fault-window @inferred @source:chaosbox#sample_latency
  Scenario Outline: The endpoint is probed throughout the fault window but not after teardown
    Given the operator chose --probe-interval <interval>
    When the operator runs `chaosbox delay --duration 60s --probe http://checkout.example.com/healthz --probe-interval <interval>`
    Then a probe is sent, then chaosbox pauses <interval> seconds before the next
    And fault-phase probing stops 1 second before the 60-second window ends
    And no fault-phase sample is taken after the delay has been removed

    Examples:
      | interval |
      | 1        |
      | 5        |
