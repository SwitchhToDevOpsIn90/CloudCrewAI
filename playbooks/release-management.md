# Playbook: Release Management and Rollback

## WHY

Every deployment has succeeded so far in this framework's real sessions — but a real production system will eventually have a deployment that breaks something, and the difference between a minor incident and a serious one is almost entirely how quickly and safely it can be rolled back. A team that has only ever practiced deploying forward is not actually prepared for production, regardless of how many successful forward deployments it has completed.

## WHAT This Playbook Delivers

A clear, consistent versioning scheme, an explicit distinction between staging and production, a genuine rollback procedure that has actually been tested (not merely theorized), and a release checklist ensuring nothing critical is skipped under the time pressure a real incident or deadline creates.

## Prerequisites

An application already using tagged releases (per the Git branch protection playbook) and, ideally, a container registry with retained previous versions (per the container registry deployment playbook) — rollback is only genuinely possible if a known-good previous version still exists somewhere reachable.

## Steps

1. Adopt a consistent versioning scheme (semantic versioning — major.minor.patch — is a common, well-understood default) and apply it to every meaningful release, not only ones that feel significant enough to warrant a version bump.

2. Maintain a genuine distinction between a staging environment and production, with staging serving as the last verification step before anything reaches production — a change should be observable in staging before it is observable to real users.

3. Before any production release, confirm a previous known-good version is genuinely retrievable — a tagged image still present in the registry, a specific commit that can be redeployed — not merely assumed to exist somewhere.

4. Define the actual rollback procedure explicitly, as a runbook (per the documentation standards playbook), before it is needed under pressure — deciding the rollback steps for the first time during an actual incident is slower and more error-prone than executing an already-written procedure.

5. Practice the rollback procedure at least once deliberately, in a non-emergency context, confirming it genuinely works rather than trusting it works because it looks correct on paper — this mirrors the same "prove it, don't assume it" discipline applied to volume persistence in the Docker Compose playbook.

6. Use a release checklist for anything reaching production, covering at minimum: tests passing, a rollback path confirmed available, and any stakeholder notification genuinely required — under time pressure, an unwritten checklist is a checklist items get silently skipped from.

7. After any real rollback, treat it with the same seriousness as a real incident (per the secrets incident response playbook's pattern) — understand what caused the need for rollback, document it, and determine whether a new test (per the testing and QA playbook) should be added to catch the same class of problem earlier next time.

## Guardrail Check

Never treat "we have never needed to roll back" as evidence rollback is unnecessary to prepare for — it is evidence of good fortune or insufficient testing under real conditions, not proof the procedure is unneeded. Never execute a rollback procedure for the first time during a genuine production incident if it has never been practiced beforehand.

## Reference Implementation

This is a foundational team-operating practice rather than a single traced incident, deliberately established before this framework's curriculum reaches its CI/CD and production deployment sessions, so the discipline exists from the first real production release rather than being retrofitted after a first real incident makes the gap obvious.
