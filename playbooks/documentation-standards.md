# Playbook: Documentation Standards

## WHY

Undocumented infrastructure and processes exist only in the memory of whoever built them. The moment that person is unavailable, on vacation, or has moved to a different project, everyone else is guessing — re-deriving decisions already made, or worse, making a different decision that conflicts silently with what already exists. Documentation is not a nice-to-have written after the real work; it is part of the real work.

## WHAT This Playbook Delivers

A consistent set of documentation types — README, runbooks, architecture overviews, and a changelog — written so someone with zero prior context can genuinely use them, not written for an audience who already understands the system and only needs a reminder.

## Prerequisites

None beyond the system or process actually existing. Documentation should be written alongside the work, not deferred to a separate future session.

## Steps

1. Write a README for every project answering, at minimum: what this does, how to set it up from zero, and how to run it — test this literally by imagining someone with no prior context following the exact steps written, not by assuming reasonable gaps will be obvious.

2. Write a runbook for any operational task likely to be repeated or handed to someone else — deploying, rotating a credential, responding to a specific type of alert — as an ordered, literal sequence of steps, not a general description of the approach.

3. Write a brief architecture overview for any system with more than a couple of moving parts, showing how the pieces connect and why key decisions were made, cross-referencing the relevant Architecture Decision Record where one exists rather than re-explaining the same reasoning in two places.

4. Maintain a changelog recording what changed in each meaningful release, in plain language a non-engineer stakeholder could understand, not just a list of commit messages.

5. Keep documentation next to the code it describes, in the same repository, version-controlled and reviewed the same way code is — a wiki or external document that drifts out of sync with the actual code is worse than no documentation, since it actively misleads.

6. Update documentation as part of the same change that makes it inaccurate, not as a separate follow-up task — a pull request that changes behavior the README describes should update the README in that same pull request.

7. Periodically test documentation by having someone unfamiliar with the specific piece actually follow it, treating any point of confusion as a real documentation bug to fix, not a reader's shortcoming.

## Guardrail Check

Never let documentation reference a real secret value, even as a placeholder that looks realistic enough to invite copy-pasting — use a clearly fake example value. Never publish or reference documentation containing client-specific or personally identifying information without explicit confirmation this is appropriate for the target audience of that document.

## Reference Implementation

This is a foundational team-operating practice rather than a single traced incident. This framework's own README.md, docs/roadmap.md, and docs/decision-engine.md, plus the templates/client-readme-template.md, are themselves working examples of this playbook's principles applied to CloudCrewAI's own documentation.
