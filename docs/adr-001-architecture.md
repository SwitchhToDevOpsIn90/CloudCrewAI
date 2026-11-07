# ADR-001: CloudCrewAI Architecture — Beyond Prompts and Role Skills

Status: accepted. Date: 2026-11-07.

## Context

Role-skill repositories for coding agents (for example GStack, a set of slash commands that make one agent act as a software team) show the value of giving an agent a team's roles. For cloud operations the risks are different: real money, real data, real access, and mistakes that are hard to undo. Prompts and role descriptions alone cannot make an agent reliable there. The goal of this project is a virtual cloud engineering team that is as close to error-free as possible with minimal human involvement (see vision.md and reliability-protocol.md).

## Decision

CloudCrewAI is built as seven layers. Each layer fixes a failure that the layer above it cannot fix by itself.

| # | Layer | Purpose | Status |
|---|---|---|---|
| 1 | Playbooks | Knowledge proven in real sessions, with cited commits | Built (26) |
| 2 | Role skills | Slash-command interface and a chained workflow (`/crew-sprint`) | Built, v0.1 untested |
| 3 | Tools | Deterministic scripts for checks that must not depend on the agent's judgment (secret scan, teardown sweep) | Started (tools/) |
| 4 | Policy enforcement | Hooks that block guardrail actions mechanically (for example apply without a plan, delete without approval, spend above the ceiling) | Planned |
| 5 | Project ledger | A per-project record of decisions, cost ceiling, every resource created, and every human intervention, so work can be resumed and torn down from facts | Template started (templates/resource-ledger.md) |
| 6 | Independent verifier | A separate reviewer role, run in a fresh context, that checks high-impact work without having produced it | Planned |
| 7 | Evaluation harness | Realistic scenarios with scoring, run against multiple AI models, producing a measured pass rate | v0 started (evals/: 8 blind paper scenarios, baseline recorded) |

The multi-agent orchestration repository remains a separate project, built after Session 90 on top of these layers.

## What makes this different from a role-skill repository

- **Evidence over opinion.** Playbooks come from real, committed sessions, including failures and what was only inferred.
- **Enforcement over instruction.** Guardrails are meant to be backed by tools and hooks, not only text an agent may skip.
- **Memory of what exists.** The ledger makes teardown and cost control a checklist of recorded facts.
- **Independent checking.** The producer does not grade its own work.
- **Measured reliability.** Accuracy is a number from the harness, not a claim.
- **Cloud-specific stages.** Discover, Cost and Teardown are first-class stages.

## Consequences

- More to maintain than a prompt library. Mitigation: keep skills thin, keep playbooks the single source of truth, and add a layer only when a real session shows the need.
- Scripts must be honest about their status. Commands used in real sessions are marked proven; anything else is marked standard or untested until it has been run.
- Layers 4 to 7 must be proven on real work before the system is offered to a paying client.

## Build Order

1. Tools: secret scan (done, tested on fixtures and both repositories), teardown sweep (written, run it once at the next real teardown), ledger template (done).
2. Run `/crew-sprint` on a small free local project; log every stumble.
3. Policy hooks for the top guardrails.
4. Independent verifier role.
5. Evaluation harness at roughly 30 playbooks.
6. Dry-run project for a fictional client, using only the library; log every human intervention.
7. Multi-agent repository.

## What Would Change This Decision

If the evaluation harness shows the tools and hooks add little over the playbooks alone, simplify. If a layer is never used on real work, remove it.
