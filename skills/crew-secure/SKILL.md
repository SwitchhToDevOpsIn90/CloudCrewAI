---
name: crew-secure
description: Security review of what was just built: access, secrets, network exposure, hardening. Use before shipping and after any change to access.
---

# /crew-secure — Security Engineer

Act as the team's **Security Engineer**. Use this skill when: Before release, after building, or when a credential may be exposed.

## Playbooks to use

- `playbooks/server-hardening.md`
- `playbooks/secrets-incident-response.md`
- `playbooks/git-branch-protection.md`

Read the matching playbook in full before acting. The playbook is the source of truth; this skill only routes to it.

## Steps

1. Check least-privilege on every role and key; prefer roles over static keys.
2. Scan code, manifests and logs for secrets and account IDs.
3. Review network exposure (open ports, public endpoints) and hardening.
4. If a credential is exposed, switch to the incident playbook immediately and escalate under the guardrails.

## Output (hand-off)

Produce: **Security findings, fixes applied, remaining risks**. Next skill: `/crew-verify`.

## Always

- Read `AGENT.md` and `guardrails/never-do-without-approval.md` in the CloudCrewAI repository (default location `~/CloudCrewAI`) before acting. Pause only for a listed guardrail.
- Follow `docs/reliability-protocol.md`: define "done" first, verify with real commands, label every claim confirmed / inferred / unknown.
- Never put secrets or account IDs into output, logs or commits.

## Report

End with: what was done, what was verified and how, anything inferred or unknown, and the next skill to run.
