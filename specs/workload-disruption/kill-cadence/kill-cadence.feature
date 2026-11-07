@domain:workload-disruption @area:kill-cadence @from:chaos-toolbox/chaosbox
Feature: Repeating kills across the window
  Lets an operator choose how often workloads are killed during the experiment, and guarantees the kills stop when the window ends.

  Background:
    Given the target web matches container web_1

  @id:workload-disruption.kill-cadence.001 @rule:workloads.kill.rounds-every-interval-until-window @inferred @source:chaosbox#run_kill
  Scenario Outline: Kills repeat at the chosen interval and stop when the window ends
    Given the Docker socket is mounted, so chaosbox detects kill mode docker
    When the operator runs `chaosbox kill --duration <duration> --target web <every option>`
    Then chaosbox prints "chaosbox: kill mode=docker target='web' every=<interval>s"
    And web_1 is killed once at the start and again every <interval> seconds
    And the final wait is cut short so that nothing runs past <seconds> seconds
    And chaosbox prints "chaosbox: kill finished — <kills> kill(s) over <seconds>s"

    Examples:
      | duration | every option | interval | seconds | kills |
      | 60s      |              | 20       | 60      | 3     |
      | 50s      | --every 20s  | 20       | 50      | 3     |
      | 2m       | --every 1m   | 60       | 120     | 2     |

  @id:workload-disruption.kill-cadence.002 @rule:workloads.kill.no-match-keeps-running @inferred @source:chaosbox#run_kill
  Scenario: Rounds that match nothing are reported and the window still runs to its end
    Given no running workload matches the target web
    When the operator runs `chaosbox kill --duration 60s --target web`
    Then chaosbox prints "chaosbox: no targets matched 'web'" each round
    And chaosbox prints "chaosbox: kill finished — 0 kill(s) over 60s" after 60 seconds

  @id:workload-disruption.kill-cadence.003 @rule:workloads.kill.failed-kill-reported-and-counted @inferred @source:chaosbox#run_kill @questionable
  Scenario: A kill that fails is reported, the experiment carries on, and the attempt is counted
    Given web_1 disappears between being listed and being killed
    When the operator runs `chaosbox kill --duration 60s --target web --every 60s`
    Then chaosbox prints "chaosbox: kill failed for web_1 (already gone?)"
    And the experiment continues to the end of the window
    And chaosbox prints "chaosbox: kill finished — 1 kill(s) over 60s"
