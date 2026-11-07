@domain:experiment-reports @area:percentile-summary @from:chaos-toolbox/chaosbox
Feature: Summarising probe latency per phase
  Gives an operator a baseline-versus-fault latency table they can quote, and withholds numbers that are too thin to trust.

  Background:
    Given the operator passes --probe http://checkout.example.com/healthz

  @id:experiment-reports.percentile-summary.001 @rule:reports.summary.phase-percentiles @inferred @source:chaosbox#percentiles
  Scenario: The report prints samples, errors and p50/p90/p99 for each phase
    Given the baseline phase got 10 successful probes taking 0.1s, 0.2s, … 1.0s and no errors
    When the delay experiment ends
    Then chaosbox prints "chaosbox: experiment report — delay for 60s against http://checkout.example.com/healthz"
    And the table has columns phase, samples, errors, p50, p90, p99
    And the baseline row reads 10 samples, 0 errors, 0.5000s, 0.9000s, 1.0000s
    And a fault row follows in the same format

  @id:experiment-reports.percentile-summary.002 @rule:reports.summary.withheld-below-minimum @inferred @source:chaosbox#report_row
  Scenario: Percentiles are withheld for a phase with fewer than five samples
    Given the baseline phase got 3 probes
    When the operator runs `chaosbox delay --duration 60s --probe http://checkout.example.com/healthz --baseline 3s`
    Then the baseline row shows n/a for p50, p90 and p99
    And chaosbox prints "note: fewer than 5 samples in a phase — percentiles withheld;"
    And chaosbox prints "lengthen --duration/--baseline or shorten --probe-interval."

  @id:experiment-reports.percentile-summary.003 @rule:reports.summary.errors-count-toward-minimum @inferred @source:chaosbox#report_row @questionable
  Scenario: Failed probes count toward the five-sample minimum
    Given the fault phase got 6 probes, 5 of them errors and 1 success taking 2.3s
    When the delay experiment ends
    Then the fault row reads 6 samples and 5 errors
    And p50, p90 and p99 are all shown as 2.3000s
    And no withheld note is printed
