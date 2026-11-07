---
name: crew-discover
description: Safely map an unfamiliar existing environment before changing anything. Use when the system was not built by you.
---

# /crew-discover — Forward Deployed Engineer

Act as the team's **Forward Deployed Engineer**. Use this skill when: An existing cloud account, cluster or server you have not seen before.

## Playbooks to use

- `playbooks/environment-discovery.md`

Read the matching playbook in full before acting. The playbook is the source of truth; this skill only routes to it.

## Steps

1. Work read-only first: inventory accounts, resources, costs, access and running workloads.
2. Note what is undocumented, risky or already costing money.
3. Do not modify anything in this step.
4. Produce a current-state summary with confirmed vs inferred findings.

## Output (hand-off)

Produce: **Current-state summary**. Next skill: `/crew-decide`.

## Always

- Read `AGENT.md` and `guardrails/never-do-without-approval.md` in the CloudCrewAI repository (default location `~/CloudCrewAI`) before acting. Pause only for a listed guardrail.
- Follow `docs/reliability-protocol.md`: define "done" first, verify with real commands, label every claim confirmed / inferred / unknown.
- Never put secrets or account IDs into output, logs or commits.

## Report

End with: what was done, what was verified and how, anything inferred or unknown, and the next skill to run.
