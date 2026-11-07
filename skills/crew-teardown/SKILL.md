---
name: crew-teardown
description: Remove temporary resources in the right order and prove nothing is left billing. Use after every demo, lab or failed attempt.
---

# /crew-teardown — SRE / DevOps

Act as the team's **SRE / DevOps**. Use this skill when: Ending a demo, abandoning a failed provisioning attempt, or finishing a lab.

## Playbooks to use

- `playbooks/bounded-demo-provisioning.md`
- `playbooks/eks-cluster-setup.md`
- `playbooks/kubernetes-persistent-storage.md`
- `playbooks/decommission-and-data-deletion.md`

Read the matching playbook in full before acting. The playbook is the source of truth; this skill only routes to it.

## Steps

1. Delete workloads, then volumes and claims, then the cluster or stack (disks before the cluster).
2. Verify every resource type independently (clusters, stacks, VPCs, instances, volumes, snapshots, roles).
3. Check the console pages the CLI does not cover (for example Snapshots).
4. Revoke any temporary permissions last.

## Output (hand-off)

Produce: **Teardown verification evidence**. Next skill: `/crew-retro`.

## Always

- Read `AGENT.md` and `guardrails/never-do-without-approval.md` in the CloudCrewAI repository (default location `~/CloudCrewAI`) before acting. Pause only for a listed guardrail.
- Follow `docs/reliability-protocol.md`: define "done" first, verify with real commands, label every claim confirmed / inferred / unknown.
- Never put secrets or account IDs into output, logs or commits.

## Report

End with: what was done, what was verified and how, anything inferred or unknown, and the next skill to run.
