# CloudCrew Skills (v0.1, untested)

Optional slash-command layer for tools that support skills (for example Claude Code). Each skill is a thin role wrapper that routes to the real playbooks in `playbooks/`, which stay the single source of truth. Any other AI can ignore this folder and use AGENT.md directly.

## Workflow

Onboard → Discover → Decide → Build → Secure → Verify → Ship → Operate → Retro, with `/crew-cost` and `/crew-teardown` usable at any stage. `/crew-sprint` runs the whole chain.

| Skill | Role | Main playbooks |
|---|---|---|
| /crew-sprint | Engagement lead | the whole chain |
| /crew-onboard | Project manager | client-onboarding, project-coordination |
| /crew-discover | Forward deployed engineer | environment-discovery |
| /crew-decide | Architect | architecture-decision-records, cost checks |
| /crew-build | DevOps / platform | terraform, docker, kubernetes, helm, eks |
| /crew-secure | Security | server-hardening, secrets-incident-response |
| /crew-verify | QA | testing-and-qa |
| /crew-ship | Release / writer | release-management, documentation-standards |
| /crew-operate | SRE | monitoring, production-incident-response |
| /crew-cost | FinOps | cloud-cost-optimization, free-tier-verification |
| /crew-teardown | SRE | bounded-demo-provisioning, teardown steps |
| /crew-retro | Engineering lead | turns misses into playbook fixes |

## Install (Claude Code)

Clone this repository to `~/CloudCrewAI`, then link the skills:

```bash
mkdir -p ~/.claude/skills
for d in ~/CloudCrewAI/skills/crew-*; do ln -sfn "$d" ~/.claude/skills/$(basename "$d"); done
```

Skills expect the repository at `~/CloudCrewAI` (they say so in their text).

## Status

Version 0.1. The skills have not yet been tested against realistic scenarios; that is the job of the planned evaluation harness (see docs/vision.md). Treat every skill as a draft until it has been run on a real project and corrected.
