@domain:developer-tooling @area:smoke-tests @from:chaos-toolbox/test
Feature: Smoke-testing a built image
  Gives contributors and release maintainers one pass/fail check that a built image still keeps chaosbox's safety guarantees before it is pushed.

  Background:
    Given a chaos-toolbox image has been built and tagged locally

  @id:developer-tooling.smoke-tests.001 @rule:devtooling.smoke-tests.image-tag-required @inferred @source:test.sh#IMAGE
  Scenario: The smoke tests refuse to run without an image to test
    Given no image tag is supplied
    When the contributor runs the smoke tests
    Then the run stops before any container is started
    And the contributor sees "usage: test.sh <image:tag>"
    And the run exits with a failure status

  @id:developer-tooling.smoke-tests.002 @rule:devtooling.smoke-tests.healthy-image-passes @inferred @source:test.sh#IMAGE
  Scenario: An image that keeps every safety guarantee passes the smoke tests
    Given the image refuses experiments without --duration, kill without --target, and malformed --to CIDRs
    And network rules it applies are gone when the experiment ends
    And a destination-scoped delay slows only traffic inside the named CIDR
    And a kill dry run lists matching workloads and kills none
    When the contributor runs the smoke tests against the image
    Then the run prints "PASS"
    And the run exits with a success status

  @id:developer-tooling.smoke-tests.003 @rule:devtooling.smoke-tests.broken-guarantee-fails-run @inferred @source:test.sh#IMAGE
  Scenario Outline: A broken safety guarantee fails the smoke tests and names what broke
    Given the image breaks the guarantee <guarantee>
    When the contributor runs the smoke tests against the image
    Then the contributor sees "<message>"
    And "PASS" is not printed
    And the run exits with a failure status

    Examples:
      | guarantee                                                           | message                                                |
      | an experiment without --duration is refused                         | FAIL: missing --duration was accepted                  |
      | delay rules are removed when the experiment ends                    | netem not cleaned                                      |
      | a scoped delay leaves other destinations untouched                  | out-of-scope traffic was delayed (base 1ms, got 301ms) |
      | scoped rules are removed when the experiment ends                   | scoped rules not cleaned                               |
      | a malformed --to CIDR is refused                                    | FAIL: invalid --to was accepted                        |
      | kill without --target is refused                                    | FAIL: kill without --target was accepted               |
      | kill without --duration is refused                                  | FAIL: kill without --duration was accepted             |
      | a kill dry run kills nothing                                        | dry-run killed something                               |
      | kubectl and docker ship in the image                                | FAIL: kill mode tooling missing from the image         |
      | the musl libfaketime build shifts the clock by the requested offset | musl skew was 0s                                       |

  @id:developer-tooling.smoke-tests.004 @rule:devtooling.smoke-tests.report-check-falls-back @inferred @source:test.sh#IMAGE @questionable
  Scenario: When the full report check cannot pass, the smoke tests settle for the withheld-percentiles check
    Given the image has no python3 to serve a local probe target
    When the contributor runs the smoke tests against the image
    Then the JSON report contents (fault name, parameters, duration) are not verified
    And the run instead requires a probe against an unreachable URL to print "percentiles withheld"
    And the run continues to the kill checks once "percentiles withheld" appears
