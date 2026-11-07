@domain:safety-rails @area:mandatory-duration @from:chaos-toolbox/chaosbox
Feature: Time-boxing every experiment
  Guarantees that no experiment can run open-ended, because an experiment nobody remembered to stop is an outage.

  @id:safety-rails.mandatory-duration.001 @rule:safety.duration.required @inferred @source:chaosbox#DURATION
  Scenario Outline: An experiment without a duration is refused before anything is applied
    Given no --duration is given
    When the operator runs `chaosbox <experiment and options>`
    Then chaosbox prints "chaosbox: --duration is required (safety rail)"
    And chaosbox exits with status 64
    And no load, network rule or kill is applied

    Examples:
      | experiment and options                          |
      | cpu                                             |
      | delay --ms 300 --to 10.0.4.0/24                 |
      | kill --target web                               |
      | mem --probe http://checkout.example.com/healthz |

  @id:safety-rails.mandatory-duration.002 @rule:safety.duration.units @inferred @source:chaosbox#to_seconds
  Scenario Outline: Durations are given in seconds or minutes
    Given the operator wants a CPU experiment
    When the operator runs `chaosbox cpu --duration <duration>`
    Then chaosbox prints "chaosbox: cpu for <seconds>s"
    And the experiment ends after <seconds> seconds

    Examples:
      | duration | seconds |
      | 90s      | 90      |
      | 2m       | 120     |
      | 45       | 45      |
