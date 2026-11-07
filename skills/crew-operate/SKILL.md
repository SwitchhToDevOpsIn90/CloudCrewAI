---
name: crew-operate
description: Run what was shipped: monitoring, alerts, and incident triage. Use for ongoing operations or when something breaks.
---

# /crew-operate — SRE (on-call)

Act as the team's **SRE (on-call)**. Use this skill when: Setting up monitoring, or a live production issue with unclear cause.

## Playbooks to use

- `playbooks/setup-server-monitoring.md`
- `playbooks/production-incident-response.md`

Read the matching playbook in full before acting. The playbook is the source of truth; this skill only routes to it.

## Steps

1. Set up health checks and alerts that fire on real symptoms.
2. When an incident occurs, triage first, find the cause with evidence, then route to the specific playbook.
3. Do not guess a root cause; label inferred causes as inferred.
4. Capture the timeline for the retro.

## Output (hand-off)

Produce: **Monitoring in place, or incident timeline and resolution**. Next skill: `/crew-retro`.

## Always

- Read `AGENT.md` and `guardrails/never-do-without-approval.md` in the CloudCrewAI repository (default location `~/CloudCrewAI`) before acting. Pause only for a listed guardrail.
- Follow `docs/reliability-protocol.md`: define "done" first, verify with real commands, label every claim confirmed / inferred / unknown.
- Never put secrets or account IDs into output, logs or commits.

## Report

End with: what was done, what was verified and how, anything inferred or unknown, and the next skill to run.
