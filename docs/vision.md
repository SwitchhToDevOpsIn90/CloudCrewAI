# Vision: A Virtual Cloud Engineering Company

The architecture that implements this vision is recorded in docs/adr-001-architecture.md.

## The Goal

Build a virtual cloud engineering team that can deliver real cloud projects end to end (design, build, secure, deploy, monitor, optimize, document, and operate) with minimal human involvement, so a future one-person company can serve clients that would normally need a whole team.

The team is made of AI agents following proven playbooks. The human is the accountable owner: signs the contracts, owns the client relationship, and approves the few actions that carry real risk.

## Principles

1. **Proven before promised.** A playbook exists only after the pattern was done for real, with a cited session and commit. Foundational team-operating playbooks are the one exception.
2. **Autonomy by default, approval by exception.** The agent acts without asking, except for the short list in guardrails/never-do-without-approval.md.
3. **Safe by construction.** Cost ceilings, least privilege, verified teardown and secret scanning are built into the steps, not left to memory.
4. **Honest by design.** Confirmed results are separated from inferred ones. No overclaiming to clients or in documentation.
5. **A human stays accountable.** The goal is minimal human involvement, not zero. A client contracts with a person or company, and someone must answer for outcomes.
6. **Model-agnostic.** Any capable AI should be able to run the library by reading AGENT.md.

## The Layers

| Layer | What it is | Status |
|---|---|---|
| 1. Playbook library | Single-agent, role-routed playbooks for real cloud work | In progress (25 playbooks, grows with each session) |
| 1b. Role skills | Optional slash-command roles over the playbooks (skills/, v0.1 untested) | Draft |
| 2. Evaluation harness | Scenario tests proving a fresh AI picks and follows the right playbook | v0 started: 8 blind paper scenarios in evals/, baseline 2026-11-07 |
| 3. Safe execution layer | Per-role scoped credentials, approval gates, audit log, cost kill switch, sandboxed environments | Planned |
| 4. Learning loop | Every incident or surprise updates a playbook, so the team improves with use | Partly in practice (playbooks are corrected from real sessions) |
| 5. Multi-agent orchestration | A separate repository: specialist agents coordinated by a lead agent with handoffs and shared state | Planned after Session 90 |
| 6. Client-facing layer | Intake, proposals, status reports, incident communication, always human-approved before sending | Planned |
| 7. Business operations | Pricing, invoicing, contracts, support, marketing, human-gated | Future |

## Team Map: Roles the Virtual Company Needs

| Team | Roles | Coverage today | Coming from the curriculum |
|---|---|---|---|
| Delivery management | Project manager, engagement lead | client-onboarding, project-coordination | Reporting and SLA tracking |
| Architecture | Solution/cloud architect, FDE | architecture-decision-records, environment-discovery | Disaster recovery architecture, multi-cloud |
| Cloud and platform | Cloud engineer, platform engineer | terraform-infrastructure, EKS and Kubernetes playbooks, container playbooks | Helm, autoscaling, load balancing, CDN, serverless |
| DevOps and release | CI/CD, release engineer | gitops-auto-sync, git-branch-protection, release-management | Jenkins, GitHub Actions, ArgoCD |
| Reliability | SRE, on-call | server monitoring, production-incident-response | Prometheus, Grafana, SLOs, tracing |
| Security | Security engineer, DevSecOps | server-hardening, secrets-incident-response | Pipeline security, GuardDuty/WAF, Vault, zero trust |
| Compliance | Governance, risk, compliance | None yet | Data sovereignty and GCC compliance |
| Data | Database engineer, data engineer | ai-sql-chatbot | RDS, backups, replication |
| FinOps | Cost analyst | cloud-cost-optimization, free-tier-verification | Cost automation with Lambda |
| AIOps | Anomaly detection, predictive scaling, auto-remediation | None yet | Sessions on AIOps |
| Quality | QA, test engineer | testing-and-qa | Pipeline test integration |
| Documentation | Technical writer | documentation-standards | Architecture diagrams |
| Support | Helpdesk, escalation | None yet | To be designed |
| Business | Sales, finance, legal | None | Future, human-led |

## Milestones

1. **Library complete for the core stack.** Playbooks for every major capability taught through Session 90.
2. **Evaluation proof.** A set of realistic scenarios, run against more than one AI model, with a recorded pass rate. This is the evidence that the library works.
3. **Dry-run project.** One complete cloud project delivered for a fictional client using only the library, with a human intervening only at guardrails. Every intervention is logged and turned into a playbook improvement.
4. **Safe execution layer.** Scoped credentials, audit log and cost kill switch around the agent before it ever touches a paying client's environment.
5. **Multi-agent repository.** Specialist agents and a coordinator, built on the proven playbooks.
6. **First real engagement.** A small, low-risk client project, human-supervised, with honest reporting.
7. **Company.** Operate as an AI-assisted cloud consultancy with the founder accountable and the virtual team doing the execution.

## Measures of Success

- Share of a project delivered without human intervention (excluding guardrail approvals).
- Number of human interventions per project, and how many became playbook fixes.
- Scenario pass rate across different AI models.
- Real cloud cost incidents: target zero unplanned spend.
- Time from client brief to deployed, monitored, documented system.

## What Will Still Need People

Contractual accountability, client trust and sales, legal and regulatory sign-off, and judgment on genuinely new failures. The design goal is to keep that human role small and focused, not to pretend it does not exist.
