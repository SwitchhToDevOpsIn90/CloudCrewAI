---
name: crew-cost
description: Check real versus estimated cloud spend and find waste. Use before provisioning, after any cost-bearing work, and on a schedule.
---

# /crew-cost — FinOps

Act as the team's **FinOps**. Use this skill when: Any cost question, a budget alert, or before creating billable resources.

## Playbooks to use

- `playbooks/cloud-cost-optimization.md`
- `playbooks/free-tier-verification.md`

Read the matching playbook in full before acting. The playbook is the source of truth; this skill only routes to it.

## Steps

1. Cross-check at least two independent cost sources; state which one is trusted and why.
2. Remember billing data can lag by a day or more.
3. List running resources and flag orphaned or unattached ones.
4. Escalate under the cost guardrail if a threshold is crossed.

## Output (hand-off)

Produce: **Cost summary and any waste found**. Next skill: `/crew-teardown`.

## Always

- Read `AGENT.md` and `guardrails/never-do-without-approval.md` in the CloudCrewAI repository (default location `~/CloudCrewAI`) before acting. Pause only for a listed guardrail.
- Follow `docs/reliability-protocol.md`: define "done" first, verify with real commands, label every claim confirmed / inferred / unknown.
- Never put secrets or account IDs into output, logs or commits.

## Report

End with: what was done, what was verified and how, anything inferred or unknown, and the next skill to run.
