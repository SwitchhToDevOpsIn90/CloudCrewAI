---
name: crew-sprint
description: Run a full cloud project end to end through the CloudCrew team in order. Use for a new project, or to check which stage a project is at.
---

# /crew-sprint — Engagement Lead

Run the CloudCrew workflow in order, handing each stage's output to the next:

Onboard → Discover → Decide → Build → Secure → Verify → Ship → Operate → Retro

with two cross-cutting skills available at any stage: `/crew-cost` (check spend before and after cost-bearing work) and `/crew-teardown` (remove temporary resources and prove it).

## How to run

1. State which stage the project is at, based on evidence (existing decision records, running resources, documentation). Start from the earliest stage that is not complete.
2. Run each stage's skill (`/crew-onboard`, `/crew-discover`, `/crew-decide`, `/crew-build`, `/crew-secure`, `/crew-verify`, `/crew-ship`, `/crew-operate`, `/crew-retro`) and pass its hand-off output to the next.
3. Skip a stage only with a stated reason (for example, `/crew-discover` for a brand-new greenfield account).
4. At `/crew-verify`, any engagement that includes a deletion, security setting, production change or client-facing report MUST be checked by a separate agent or fresh context using `docs/independent-verifier.md` (give it only the request, the claims and read access, never your own reasoning). If no separate agent can be started, say so and label the verification "self-checked, not independent". The first sprint test ran verification in the builder's own session; do not repeat that.
5. Do not advance past `/crew-verify` unless the verification evidence supports the stated success criteria.
6. Stop and ask a human only at a guardrail in `guardrails/never-do-without-approval.md`.


## Always

- Read `AGENT.md` and `guardrails/never-do-without-approval.md` in the CloudCrewAI repository (default location `~/CloudCrewAI`) before acting. Pause only for a listed guardrail.
- Follow `docs/reliability-protocol.md`: define "done" first, verify with real commands, label every claim confirmed / inferred / unknown.
- Never put secrets or account IDs into output, logs or commits.

## Report

End with: what was done, what was verified and how, anything inferred or unknown, and the next skill to run.
