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

6. Periodically re-verify that branch protection is genuinely active by attempting the exact action it should block — a real, deliberate direct push attempt to main — rather than trusting the settings page display alone. A protection rule's settings page can display as existing while every actual enforcement checkbox is silently unchecked, appearing correctly configured while providing zero real protection. Only an actual attempted violation confirms the rule is genuinely enforcing anything.

7. Understand and explicitly decide on repository owner bypass behavior, since it is a separate setting from the protection rule's existence. By default, a repository owner can bypass branch protection even when it is fully and correctly configured, unless "Do not allow bypassing the above settings" is separately and explicitly checked. Decide deliberately whether owner-bypass should remain possible (a reasonable tradeoff for some solo-maintainer emergency scenarios) or be explicitly disabled (stronger protection, including against the maintainer's own mistake), rather than leaving this unexamined.

8. Tag meaningful commits as release points once a stable milestone is reached, giving the repository's history clear, referenceable markers beyond just commit hashes.

## Guardrail Check

Never recommend or use a bypass-protection option as a first response to a blocked PR — always diagnose the actual cause first. Never configure approval requirements identically for a solo-maintained repository and a real team repository; the correct configuration genuinely differs, and applying a team-appropriate rule to a solo maintainer creates a self-inflicted lockout rather than genuine safety. Never trust a branch protection rule's settings page display alone as proof it is genuinely enforcing anything — verify periodically with an actual attempted violation, since a rule can silently lose all enforcement while still appearing to exist.

## Reference Implementation

See github.com/SwitchhToDevOpsIn90/devops-journey, Session 27 — a real pull request opened, a genuine GitHub platform constraint discovered when self-approval was attempted and blocked, and a deliberate, reasoned fix (removing the approval requirement while keeping the PR requirement) chosen over the available bypass option, explicitly distinguishing this solo-maintainer pattern from what a real team's fix would be.

See also Session 31 — a genuine, unexplained failure discovered where the branch protection rule still displayed as existing on the settings page, but every actual enforcement checkbox had been silently unchecked, allowing an unprotected direct push to main to succeed without any warning. The root cause was honestly documented as unknown rather than speculated. Re-enabling the rule was verified with a real attempted direct push, which correctly surfaced a GitHub-level violation message — but the push still succeeded regardless, revealing that repository owner bypass was independently still enabled, a separate setting from the protection rule itself. This is the concrete origin of this playbook's Steps 6 and 7.
