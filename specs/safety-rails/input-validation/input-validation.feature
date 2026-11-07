@domain:safety-rails @area:input-validation @from:chaos-toolbox/chaosbox
Feature: Refusing malformed experiments
  Stops a mistyped command or option before it reaches a host's network or workloads, and tells the operator what was wrong.

  @id:safety-rails.input-validation.001 @rule:safety.input.unknown-flag-or-experiment-refused @inferred @source:chaosbox#usage
  Scenario Outline: An unknown option or experiment is refused with the command reference
    Given the operator mistypes a command
    When the operator runs `chaosbox <command line>`
    Then chaosbox prints "<message>" as an error
    And chaosbox prints the built-in command reference
    And chaosbox exits with status 64
    And nothing is applied

    Examples:
      | command line                   | message                             |
      | cpu --duration 60s --wrokers 4 | chaosbox: unknown flag --wrokers    |
      | burn --duration 60s            | chaosbox: unknown experiment 'burn' |

  @id:safety-rails.input-validation.002 @rule:safety.input.malformed-cidr-refused @inferred @source:chaosbox#valid_cidr
  Scenario Outline: A destination that is not an IPv4 CIDR is refused before any rule is installed
    Given chaosbox shares the workload's network namespace with NET_ADMIN
    When the operator runs `chaosbox delay --duration 60s --to <scope>`
    Then chaosbox prints "chaosbox: --to expects a CIDR like 10.0.0.0/24, got '<bad>'"
    And chaosbox exits with status 64
    And no delay is applied to any traffic

    Examples:
      | scope            | bad           |
      | not-a-cidr       | not-a-cidr    |
      | 10.0.0.0/33      | 10.0.0.0/33   |
      | 2001:db8::/32    | 2001:db8::/32 |
      | 10.0.4.0/24,oops | oops          |

  @id:safety-rails.input-validation.003 @rule:safety.input.malformed-duration-not-refused @inferred @source:chaosbox#to_seconds @questionable
  Scenario Outline: A malformed duration is not refused before the experiment starts
    Given the operator gives --duration <duration>
    When the operator runs `chaosbox <experiment> --duration <duration> <options>`
    Then chaosbox prints "chaosbox: <experiment> for <duration>s" instead of a usage error
    And <effect>
    And chaosbox exits with a status other than 64

    Examples:
      | experiment | duration | options      | effect                                                 |
      | delay      | soon     | --ms 300     | the delay is applied to eth0 and removed again at once |
      | kill       | 1h       | --target web | chaosbox stops with a shell arithmetic error           |

  @id:safety-rails.input-validation.004 @rule:safety.input.unsupported-kill-mode @inferred @source:chaosbox#run_kill @questionable
  Scenario: An unsupported kill mode is not refused as a usage error
    Given the operator passes --mode podman
    When the operator runs `chaosbox kill --duration 60s --target web --mode podman`
    Then chaosbox prints "chaosbox: kill mode=podman target='web' every=20s"
    And chaosbox then fails with a 'command not found' error
    And chaosbox exits with status 127, not 64
