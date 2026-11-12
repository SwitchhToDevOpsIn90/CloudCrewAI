# CloudCrewAI

**Give one AI agent the playbooks, guardrails and checks of a small cloud team, and measure whether it behaves.**

CloudCrewAI is a model-agnostic library that lets a single AI agent act as architect, DevOps engineer, security engineer, QA, SRE, FinOps and project manager. It does the work itself and pauses for a human only at a short list of dangerous actions. Every claim in this repo is labelled **proven** (run on real infrastructure) or **standard practice** (not yet run), and the results of every test, including the failures, are in `evals/results/`.

## Why it exists

AI agents are fast and confident, and confidence is the problem in cloud work: a wrong delete, a forgotten volume or an over-sure client email is expensive. This repo is built around catching that:

- **Playbooks** (32) written from real work, each with a Guardrail Check and a Reference Implementation.
- **Guardrails**: deletion, security exposure, cost above a ceiling, production changes and client communication always need a named human approval.
- **Policy hooks**: the guardrails enforced mechanically, so a blocked command stays blocked even if the agent forgets.
- **Independent verifier**: a separate agent re-reads the real state and defaults to doubt. The agent that did the work never grades it.
- **Evidence over claims**: every statement is confirmed, inferred or unknown, with the command output to back it.

## What has been tested (honest numbers)

| Test | Result | Where |
|---|---|---|
| Blind routing: fresh agents given only `AGENT.md` and 10 realistic requests (exposed key, prod 500s, deleting a cluster, unknown AWS account, Helm upgrade, client email...) | **10/10** on the latest run; 8/8 on the first | `evals/results/` |
| Policy hook against sample tool calls | **33/33** | `hooks/test_policy.sh` |
| Independent verifier, planted errors (stale evidence, wrong region, unapproved deletion, lagging cost data) | **5/5 and 5/5** | `evals/results/` |
| Two live `/crew-sprint` runs on local Minikube at $0 | Both completed with teardown proof; both exposed real flaws that were then fixed | `evals/results/` |

**What these numbers do not show.** The author wrote both the playbooks and the tests, each test ran once, scores come from small models on simulated or local setups, and nothing has run on a paying client's production account. Treat this as a well-tested draft, not a guarantee. A named, accountable human operator is still part of the design.

## Quick start

1. Clone the repo and point your agent at `AGENT.md`. It routes each request to the matching playbook. Any agent that can read files and run commands works (Claude, ChatGPT, Gemini, others).
2. Optional, for Claude Code: link the role skills (`/crew-sprint`, `/crew-build`, `/crew-verify`...):
   ```bash
   mkdir -p ~/.claude/skills
   for d in ~/CloudCrewAI/skills/crew-*; do ln -sfn "$d" ~/.claude/skills/$(basename "$d"); done
   ```
3. Optional: enforce the guardrails with the hook (see `hooks/README.md`; copy `hooks/settings.example.json` into your project's `.claude/settings.json`).
4. Run `tools/scan-secrets.sh <path>` before every commit.

## How a task flows

```
request -> AGENT.md routing -> playbook -> guardrail check -> work (hooks block risky commands)
        -> independent verifier -> confirmed / inferred / unknown report -> human sign-off for high-impact work
```

The seven layers (playbooks, role skills, tools, policy hooks, project ledger, independent verifier, evaluation harness) and their status are in `docs/adr-001-architecture.md`.

## The 32 playbooks

**Client & Project Management:** Client onboarding, Ongoing project coordination
**Architecture:** Architecture decision records, Existing environment discovery
**Development:** Docker containerization, Docker Compose orchestration, Container registry deployment
**Infrastructure & DevOps:** Terraform, GitOps auto-sync, Package pinning, Kubernetes core & networking, EKS cluster setup & teardown, Kubernetes persistent storage, Helm packaging & releases, Jenkins CI setup & security, Jenkins pipelines as code, Jenkins Docker builds & ECR push
**Security:** Server hardening, Secrets incident response
**Testing & QA:** Testing and QA
**Release & Operations:** Git branch protection, Release management & rollback, Bounded demo provisioning
**Reliability (SRE):** Server monitoring, Production incident response, Customer communication & post-incident reports, Decommissioning & data deletion, Offboarding & identity cleanup
**Cost (FinOps):** Cloud cost optimization, Free Tier verification
**Documentation:** Documentation standards
**AI/Data:** AI SQL chatbot

## Repository map

- `AGENT.md`: universal entry point and routing table. `CLAUDE.md`: Claude Code pointer.
- `playbooks/`, `guardrails/`: what to do, and what always needs approval.
- `hooks/`: policy enforcement (layer 4) with tests.
- `docs/`: vision, ADR (architecture), decision engine, reliability protocol, independent verifier, roadmap.
- `evals/`: test scenarios, fixtures and every recorded result.
- `tools/`: secret scan and read-only teardown sweep. `templates/`: resource ledger, verification request and report.
- `skills/`: optional Claude Code slash commands.

## Status and roadmap

Built: layers 1 to 4, 6 and 7 (v0). In progress: the project ledger (layer 5), harder verifier tests (cross-file contradictions, missing evidence), live use on non-demo accounts. A separate multi-agent orchestration repo is planned after the playbook library matures; this repo is deliberately a single-agent library. See `docs/roadmap.md`.

## License

MIT, see `LICENSE`. The software is provided as is: playbooks that touch real infrastructure can cause cost or data loss if used without review, so read the guardrails and test on a free local setup first.

## Origin

Built alongside a public 90-session DevOps learning journey by @SwitchToDevOpsIn90. The playbooks cite the exact sessions and commits they come from.
