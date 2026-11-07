@domain:safety-rails @area:usage-help @from:chaos-toolbox/chaosbox
Feature: Getting the command reference
  Gives an operator the list of experiments and options without leaving the terminal or the container.

  @id:safety-rails.usage-help.001 @rule:safety.help.prints-reference @inferred @source:chaosbox#usage @questionable
  Scenario Outline: Asking for help prints the command reference and exits cleanly
    Given the operator wants the command reference
    When the operator runs `<invocation>`
    Then chaosbox prints the reference lines for cpu, mem, io, delay, loss, limit and kill with their options
    And chaosbox exits with status 0
    And no experiment is started

    Examples:
      | invocation          |
      | chaosbox            |
      | chaosbox --help     |
      | chaosbox -h         |
      | chaosbox cpu --help |
