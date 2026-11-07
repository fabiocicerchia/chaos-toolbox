@domain:workload-disruption @area:kubernetes-pod-kills @from:chaos-toolbox/chaosbox
Feature: Deleting Kubernetes pods
  Lets an operator repeatedly delete matching pods so the controller has to replace them, proving the workload survives pod loss.

  @id:workload-disruption.kubernetes-pod-kills.001 @rule:workloads.k8s.delete-matching-pods-without-waiting @inferred @source:chaosbox#kill_one_k8s
  Scenario: Matching pods are deleted without waiting for them to terminate
    Given chaosbox has a kubeconfig or service account that may delete pods in namespace shop
    And pod web-1 in namespace shop is labelled app=web
    When the operator runs `chaosbox kill --duration 60s --mode k8s --namespace shop --target app=web`
    Then chaosbox prints "chaosbox: killing pod/web-1"
    And pod/web-1 is deleted from namespace shop
    And chaosbox carries on without waiting out the pod's termination grace period

  @id:workload-disruption.kubernetes-pod-kills.002 @rule:workloads.kill.mode-auto-detection @inferred @source:chaosbox#detect_mode @questionable
  Scenario Outline: Without --mode, chaosbox picks Docker or Kubernetes from its surroundings, or refuses
    Given <environment>
    When the operator runs `chaosbox kill --duration 60s --target web` without --mode
    Then <outcome>

    Examples:
      | environment                                                           | outcome                                                                                        |
      | the Docker socket is mounted                                          | chaosbox prints "chaosbox: kill mode=docker target='web' every=20s"                            |
      | chaosbox runs inside a Kubernetes pod and no Docker socket is mounted | chaosbox prints "chaosbox: kill mode=k8s target='web' every=20s"                               |
      | kubectl is installed and no Docker socket is mounted                  | chaosbox prints "chaosbox: kill mode=k8s target='web' every=20s"                               |
      | there is no Docker socket, no Kubernetes service and no kubectl       | chaosbox prints "chaosbox: cannot tell docker from k8s — pass --mode" and exits with status 64 |

  @id:workload-disruption.kubernetes-pod-kills.003 @rule:workloads.k8s.signal-ignored @inferred @source:chaosbox#kill_one_k8s @questionable
  Scenario: The chosen signal has no effect on pod kills
    Given pod web-1 matches the target
    When the operator runs `chaosbox kill --duration 60s --mode k8s --target web-1 --signal SIGTERM`
    Then pod/web-1 is deleted with its normal graceful termination
    And no SIGTERM or other chosen signal is sent
    And a JSON report from the run still records "signal":"SIGTERM"

  @id:workload-disruption.kubernetes-pod-kills.004 @rule:workloads.k8s.lookup-failure-masked @inferred @source:chaosbox#kill_targets_k8s @questionable
  Scenario Outline: A pod lookup the cluster refuses is not reported as a permission error
    Given chaosbox's service account may not list pods in namespace shop
    When the operator runs `chaosbox kill --duration 60s --mode k8s --namespace shop --target <target>`
    Then <outcome>
    And no Kubernetes error message is shown

    Examples:
      | target  | outcome                                                                                      |
      | web     | chaosbox prints "chaosbox: no targets matched 'web'" every round and finishes with 0 kill(s) |
      | app=web | chaosbox stops right after the kill header with a non-zero exit status                       |
