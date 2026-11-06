# Reliability Protocol — Getting Close to Zero Errors

## Purpose

No agent, human or AI, is 100% accurate. Reliability comes from the system around the work: checking, limiting damage, and learning from every miss. This protocol applies to every task, on top of whichever playbook is used. The aim is that an error is caught before it costs anything, and that no single error can cause serious harm.

## The Seven Rules

### 1. Define "done" before starting
State, in one or two lines, the observable result that proves the task is complete (for example, "the service answers on the load balancer URL and the old instance is gone"). If it cannot be observed, it cannot be claimed.

### 2. Verify with a real command, never from memory or inference
After each meaningful change, run a command that reads the actual state. Do not report success from the fact that a command ran without an error. Settings pages, summary panels and exit codes can all be wrong; read the real resource.

### 3. Check the opposite direction too
For every "this should exist" check, include the "nothing else should exist" check. Provisioning is verified by the resource being present; teardown is verified by a sweep across every resource type, repeated.

### 4. Label every claim by how it is known
Use three levels: **confirmed** (a command output proves it), **inferred** (strongly suggested, not proven), **unknown**. Never present an inferred or unknown item as confirmed, in reports, documentation or client messages.

### 5. Limit the blast radius before acting
Before any real-environment change, confirm: the credentials in use are scoped to the task, a cost ceiling exists, a rollback or teardown path exists, and secrets and account identifiers will be kept out of logs and commits. Prefer a free or local rehearsal first (for example Minikube before EKS, `--dry-run` before apply, `terraform plan` before apply).

### 6. Use an independent check on high-impact work
When the cost of a mistake is high (production changes, security configuration, anything touching client data), have a second pass that did not produce the work: a separate agent, a fresh-context review, or a script that re-reads the state. The producer does not grade its own work.

### 7. Turn every miss into a fix
When something fails or a human has to correct the agent, record what happened and update the matching playbook or this protocol. The same mistake must not be possible twice.

## Report Format

End every task with three short parts: what was done, what was verified and how (with the command or evidence), and anything inferred or unknown. If a human approval was required, state which guardrail triggered it.

## Escalation

If a verification fails, or a result cannot be confirmed after one retry, stop and report, rather than continuing on an unconfirmed assumption. Stopping early is cheaper than a confident error.

## Measuring Reliability

Reliability is a measured number, not a feeling. Track per project: the number of verification failures caught before delivery, the number of errors found after delivery, human interventions and their causes, and unplanned cloud spend (target zero). The planned evaluation harness (see vision.md) will turn these into a pass rate across realistic scenarios.
