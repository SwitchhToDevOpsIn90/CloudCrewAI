# Playbook: Git Branch Protection and PR Workflow Setup

## WHY

A repository where anyone can push directly to main has no gate preventing broken or unreviewed code from reaching the branch everything else depends on. This is fine for solo experimentation, but any real client engagement — even a solo-maintained one — benefits from a structural rule enforced by the platform itself, not merely a convention people are trusted to follow.

## WHAT This Playbook Delivers

A main branch that cannot be pushed to directly, requiring every change to go through a pull request, with the review requirement correctly configured for the actual team size — a genuine approval gate for a real team, or an honest, limited "PR required, no approval gate" pattern for a solo maintainer, never a workaround that bypasses the protection entirely.

## Prerequisites

Admin access to the GitHub repository. A clear, honest answer to whether this repository has more than one real contributor, since the correct configuration genuinely differs between the two cases.

## Steps

1. Create a feature branch for any new work rather than committing directly to main, regardless of team size — this habit matters independent of what branch protection is configured.

2. Open a pull request for the change, even for a solo repository, rather than merging a feature branch directly without one.

3. Enable branch protection on main with, at minimum, "Require a pull request before merging" checked — this alone prevents any direct push to main, the most fundamental protection.

4. Determine team size honestly before configuring the approval requirement. For a genuine multi-person team, require at least one approving review from someone other than the PR author, and add real reviewers. For a solo-maintained repository, do not require approval — GitHub enforces at the platform level that PR authors cannot approve their own pull requests, a hard constraint no repo setting can override, meaning a solo maintainer requiring approval would permanently lock themselves out of merging anything.

5. If a PR ever becomes blocked and merging seems impossible, verify precisely why before reaching for a bypass option. Confirm whether the block is a genuine reviewable requirement (fixable by getting a real review) or the self-approval constraint specifically (fixable only by adjusting the approval requirement itself, appropriate for solo maintainers). Never use a bypass or "merge without waiting for requirements" option as the default fix — normalizing bypassing a configured security control teaches the wrong instinct, even when technically available.

6. Tag meaningful commits as release points once a stable milestone is reached, giving the repository's history clear, referenceable markers beyond just commit hashes.

## Guardrail Check

Never recommend or use a bypass-protection option as a first response to a blocked PR — always diagnose the actual cause first. Never configure approval requirements identically for a solo-maintained repository and a real team repository; the correct configuration genuinely differs, and applying a team-appropriate rule to a solo maintainer creates a self-inflicted lockout rather than genuine safety.

## Reference Implementation

See github.com/SwitchhToDevOpsIn90/devops-journey, Session 27 — a real pull request opened, a genuine GitHub platform constraint discovered when self-approval was attempted and blocked, and a deliberate, reasoned fix (removing the approval requirement while keeping the PR requirement) chosen over the available bypass option, explicitly distinguishing this solo-maintainer pattern from what a real team's fix would be.
