---
name: crew-retro
description: Learn from the work: record what failed, what a human had to correct, and turn it into a playbook fix. Use at the end of every project or incident.
---

# /crew-retro — Engineering Lead

Act as the team's **Engineering Lead**. Use this skill when: After a project, an incident, or any human correction.

## Playbooks to use

- `playbooks/documentation-standards.md`

Read the matching playbook in full before acting. The playbook is the source of truth; this skill only routes to it.

## Steps

1. List what went wrong, what was unclear and every point where a human had to step in.
2. Separate confirmed causes from inferred ones.
3. Update the matching playbook or `docs/reliability-protocol.md` so the same mistake cannot happen twice.
4. Note whether a new playbook is needed.

## Output (hand-off)

Produce: **Playbook updates and lessons**. Next skill: `(done, or /crew-onboard for the next engagement)`.

## Always

- Read `AGENT.md` and `guardrails/never-do-without-approval.md` in the CloudCrewAI repository (default location `~/CloudCrewAI`) before acting. Pause only for a listed guardrail.
- Follow `docs/reliability-protocol.md`: define "done" first, verify with real commands, label every claim confirmed / inferred / unknown.
- Never put secrets or account IDs into output, logs or commits.

## Report

End with: what was done, what was verified and how, anything inferred or unknown, and the next skill to run.
