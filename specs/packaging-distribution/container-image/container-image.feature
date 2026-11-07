@domain:packaging-distribution @area:container-image @from:chaos-toolbox/dockerfile
Feature: Shipping the chaos toolbox as one image
  Gives operators a single pinned image that runs chaosbox straight away and carries the clients and clock-skew payloads their experiments rely on.

  Background:
    Given the operator has pulled the chaos-toolbox image

  @id:packaging-distribution.container-image.001 @rule:packaging.image.runs-chaosbox-by-default @inferred @source:Dockerfile#ENTRYPOINT
  Scenario Outline: Running the image runs chaosbox, and shows its help when given no arguments
    When the operator runs the image with <arguments>
    Then chaosbox runs with <arguments> passed to it unchanged
    And the operator sees <outcome>

    Examples:
      | arguments                      | outcome                                         |
      | no arguments                   | the chaosbox usage help                         |
      | cpu --duration 10s --workers 1 | a 10 second CPU stress experiment with 1 worker |

  @id:packaging-distribution.container-image.002 @rule:packaging.image.clock-skew-payload-at-fixed-paths @inferred @source:Dockerfile#faketime-glibc
  Scenario Outline: The image carries a clock-skew library for glibc and for musl targets at fixed paths
    Given a target workload whose binaries are linked against <libc>
    When an init container copies <path> from the image into the target and preloads it with FAKETIME set to +5m
    Then the target's clock reads about 5 minutes ahead

    Examples:
      | libc                | path                                 |
      | glibc 2.34 or later | /opt/faketime/glibc/libfaketime.so.1 |
      | musl (Alpine)       | /opt/faketime/musl/libfaketime.so.1  |

  @id:packaging-distribution.container-image.003 @rule:packaging.image.bundles-workload-kill-clients @inferred @source:Dockerfile#KUBECTL_VERSION
  Scenario: The image includes the Docker and Kubernetes clients that workload kills need
    When the operator runs a workload kill experiment from the image
    Then a docker client and a kubectl client are both available
    And kubectl is version 1.33.2 unless the image was built with a different version
