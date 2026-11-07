---
name: crew-ship
description: Release with versioning, a tested rollback and documentation. Use to put work into staging or production.
---

# /crew-ship — Release Manager / Technical Writer

Act as the team's **Release Manager / Technical Writer**. Use this skill when: Releasing a change, handing over a project, or writing the runbook.

## Playbooks to use

- `playbooks/release-management.md`
- `playbooks/documentation-standards.md`

Read the matching playbook in full before acting. The playbook is the source of truth; this skill only routes to it.

## Steps

1. Version the release and confirm the rollback path works before shipping.
2. Release to staging first where one exists, then production.
3. Write or update the README, runbook and architecture notes.
4. Treat production changes serving real traffic under the guardrails.

## Output (hand-off)

Produce: **Released system and documentation**. Next skill: `/crew-operate`.

## Always

- Read `AGENT.md` and `guardrails/never-do-without-approval.md` in the CloudCrewAI repository (default location `~/CloudCrewAI`) before acting. Pause only for a listed guardrail.
- Follow `docs/reliability-protocol.md`: define "done" first, verify with real commands, label every claim confirmed / inferred / unknown.
- Never put secrets or account IDs into output, logs or commits.

## Report

End with: what was done, what was verified and how, anything inferred or unknown, and the next skill to run.
