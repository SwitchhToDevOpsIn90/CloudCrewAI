---
name: crew-verify
description: Independent verification of the work: tests, state checks, and proof that the system does what was asked. Use before declaring anything done.
---

# /crew-verify — QA Engineer

Act as the team's **QA Engineer**. Use this skill when: Before release, and after any significant change.

## Playbooks to use

- `playbooks/testing-and-qa.md`
- `docs/independent-verifier.md`

Read the matching playbook in full before acting. The playbook is the source of truth; this skill only routes to it.

## Steps

1. Re-read the real state with commands; do not trust the builder's summary.
2. Run the tests and the checks that prove the stated success criteria.
3. Check the opposite direction too: nothing unexpected exists or is running.
4. For high-impact work, use a fresh context or second pass that did not produce the work, following `docs/independent-verifier.md` with `templates/verification-request.md` and `templates/verification-report.md`. Default to doubt: a claim with no evidence you saw yourself is UNVERIFIED.

## Output (hand-off)

Produce: **Verification evidence**. Next skill: `/crew-ship`.

## Always

- Read `AGENT.md` and `guardrails/never-do-without-approval.md` in the CloudCrewAI repository (default location `~/CloudCrewAI`) before acting. Pause only for a listed guardrail.
- Follow `docs/reliability-protocol.md`: define "done" first, verify with real commands, label every claim confirmed / inferred / unknown.
- Never put secrets or account IDs into output, logs or commits.

## Report

End with: what was done, what was verified and how, anything inferred or unknown, and the next skill to run.
