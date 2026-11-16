# Research Notes (what the wider field shows, and what we did about it)

Status: secondary sources only (blog posts and news write-ups read on 2026-11-17). Incident details are as reported by those sources and were not independently verified.

## What the sources say

- Reported incidents of AI agents deleting production databases and backups, or rewriting authentication code with no restore point, point to the same three missing controls: a restore point the agent cannot reach, least-privilege credentials, and a human checkpoint before irreversible actions. One write-up's summary: do not rely on the model restricting itself. Sources: [dev.to postmortems](https://dev.to/sahil_kat/ai-agent-disaster-postmortems-the-3-structural-guardrails-4a1b), [Mondoo lessons](https://mondoo.com/blog/5-lessons-from-9-seconds-ai-agent-deleted-production-database).
- Reviews of public DevOps skill collections find many documentation wrappers, little Kubernetes plan review, and no project-specific GitHub Actions rules (OIDC, secrets hygiene). Strong skills have explicit refusal patterns and verification steps; weak ones read like persona files. Source: [orangebot.ai review](https://orangebot.ai/blog/best-claude-code-skills-for-devops).

## What CloudCrewAI did about it

| Finding | Response | Status |
|---|---|---|
| Restore point before irreversible work | New guardrail in `guardrails/never-do-without-approval.md`, recorded through the ledger | Text rule; not enforced by a hook |
| Least privilege and platform-level gates | Policy hook, scoped-credential playbooks, OIDC deploy playbook | Built, tested on samples |
| GitHub Actions rules are missing elsewhere | `tools/check-workflows.py` (rules from sessions 42 to 44), run in this repo's CI | Built, 13 fixture tests |
| Skills read like personas | Playbooks cite commits; `tools/check-repo.sh` fails the build if a playbook lacks a Guardrail Check or Reference Implementation | Built |
| Kubernetes and Terraform plan review is thin | Not built yet: a plan reviewer that flags deletion or replacement of stateful resources from `terraform show -json` output | Planned |

## Next candidates

1. Terraform plan reviewer (read-only, tested on fixture JSON).
2. Kubernetes manifest checker (non-root, limits, probes, digest pins) from the Session 44 manifest.
3. Harder blind verifier tests (cross-file contradictions, missing evidence, fake-looking output).
4. Enforce the restore-point rule in the hook for history rewrites and database drops.
