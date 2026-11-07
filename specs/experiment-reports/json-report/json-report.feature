@domain:experiment-reports @area:json-report @from:chaos-toolbox/chaosbox
Feature: Exporting an experiment report
  Lets an operator keep a machine-readable record of an experiment's parameters and results for later analysis.

  Background:
    Given the operator passes --probe http://checkout.example.com/healthz

  @id:experiment-reports.json-report.001 @rule:reports.json.file-contents @inferred @source:chaosbox#emit_report
  Scenario Outline: The JSON report records the experiment, its parameters, duration, probe and both phases
    Given each phase got at least 5 probes, at least one of them successful
    When the operator runs `chaosbox <command> --duration 60s --probe http://checkout.example.com/healthz --report /tmp/r.json`
    Then chaosbox prints "report written to /tmp/r.json"
    And /tmp/r.json has "experiment": "<experiment>" and "parameters": <parameters>
    And it has "duration_seconds": 60, "probe": "http://checkout.example.com/healthz" and "min_samples": 5
    And its baseline and fault entries each give samples, errors and percentiles p50, p90 and p99

    Examples:
      | command               | experiment | parameters                                            |
      | delay --ms 300        | delay      | {"ms":300,"jitter_ms":50,"dev":"eth0"}                |
      | loss --pct 25         | loss       | {"pct":25,"dev":"eth0"}                               |
      | limit                 | limit      | {"rate":"1mbit","dev":"eth0"}                         |
      | cpu --load 90         | cpu        | {"workers":2,"load":90}                               |
      | mem                   | mem        | {"workers":2,"bytes":"256M"}                          |
      | io                    | io         | {"workers":2}                                         |
      | kill --target app=web | kill       | {"target":"app=web","every":"20s","signal":"SIGKILL"} |

  @id:experiment-reports.json-report.002 @rule:reports.json.withheld-phase-null @inferred @source:chaosbox#phase_json
  Scenario: A phase too thin to trust is exported without percentiles and with a reason
    Given the baseline phase got 3 probes, 1 of them an error
    When the operator runs `chaosbox delay --duration 60s --probe http://checkout.example.com/healthz --baseline 3s --report /tmp/r.json`
    Then the baseline entry in /tmp/r.json reads {"samples":3,"errors":1,"percentiles":null,"reason":"fewer than 5 samples"}

  @id:experiment-reports.json-report.003 @rule:reports.json.ignored-without-probe @inferred @source:chaosbox#emit_report @questionable
  Scenario: Asking for a report without a probe writes nothing and says nothing
    Given the operator does not pass --probe
    When the operator runs `chaosbox cpu --duration 60s --report /tmp/r.json`
    Then the CPU experiment runs for 60 seconds
    And no file is written to /tmp/r.json
    And no warning is printed
