---
name: crew-build
description: Provision and deploy infrastructure and workloads using the matching build playbook. Use after a decision is recorded.
---

# /crew-build — DevOps / Platform Engineer

Act as the team's **DevOps / Platform Engineer**. Use this skill when: Creating infrastructure, images, clusters, charts or deployments.

## Playbooks to use

- `playbooks/terraform-infrastructure.md`
- `playbooks/docker-containerization.md`
- `playbooks/docker-compose-orchestration.md`
- `playbooks/container-registry-deployment.md`
- `playbooks/kubernetes-core-and-networking.md`
- `playbooks/kubernetes-persistent-storage.md`
- `playbooks/helm-chart-packaging-and-releases.md`
- `playbooks/eks-cluster-setup.md`
- `playbooks/bounded-demo-provisioning.md`
- `playbooks/gitops-auto-sync.md`

Read the matching playbook in full before acting. The playbook is the source of truth; this skill only routes to it.

## Steps

1. Pick the matching playbook(s) from the list and follow them step by step.
2. Rehearse first where possible: local cluster, `--dry-run`, `terraform plan`, `helm template`.
3. Stay inside the cost ceiling; use a bounded-demo pattern for anything temporary.
4. Plan the teardown before creating cost-bearing resources.
5. Use a dedicated namespace or resource group for anything you create, never one that holds other workloads. Record it in the resource ledger and list it in `.crew/owned.txt` so the policy hook lets you delete exactly that namespace at teardown.

## Output (hand-off)

Produce: **Working system and the exact commands used**. Next skill: `/crew-secure`.

## Always

- Read `AGENT.md` and `guardrails/never-do-without-approval.md` in the CloudCrewAI repository (default location `~/CloudCrewAI`) before acting. Pause only for a listed guardrail.
- Follow `docs/reliability-protocol.md`: define "done" first, verify with real commands, label every claim confirmed / inferred / unknown.
- Never put secrets or account IDs into output, logs or commits.

## Report

End with: what was done, what was verified and how, anything inferred or unknown, and the next skill to run.
