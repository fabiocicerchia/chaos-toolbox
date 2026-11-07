@domain:workload-disruption @area:docker-kills @from:chaos-toolbox/chaosbox
Feature: Killing Docker containers
  Lets an operator repeatedly kill matching containers through the Docker socket to check that they restart and that dependants recover.

  Background:
    Given the Docker socket is mounted into chaosbox

  @id:workload-disruption.docker-kills.001 @rule:workloads.docker.signal-matching-containers @inferred @source:chaosbox#kill_one_docker
  Scenario Outline: Matching containers are sent the chosen signal
    Given containers web_1 and web_2 are running
    When the operator runs `chaosbox kill --duration 60s --mode docker --target web_ <signal option>`
    Then chaosbox prints "chaosbox: killing web_1" and "chaosbox: killing web_2"
    And web_1 and web_2 each receive <signal>

    Examples:
      | signal option    | signal  |
      |                  | SIGKILL |
      | --signal SIGTERM | SIGTERM |
