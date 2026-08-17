# Roadmap

This framework grows alongside a public 90-session DevOps learning journey. Each playbook is added once the underlying skill is learned and genuinely proven — not every session produces a new playbook, only those with a genuinely new, reusable pattern. A small number of foundational team-operating playbooks (client onboarding, testing/QA, documentation, release management, production incident response, project coordination, environment discovery) were added directly, representing standard practice for a complete team rather than requiring a specific triggering session.

## Complete — 22 Playbooks

1. Client onboarding — starting a real engagement
2. Project coordination — ongoing status, scope-change handling
3. Architecture decision records — structured technical decision-making
4. Environment discovery — safely engaging an unfamiliar existing system (FDE-readiness)
5. Server monitoring — health checks, alerts, dashboards
6. GitOps auto-sync — automatic deployment on new commits
7. Server hardening — SSH, firewall, brute-force protection
8. Terraform infrastructure — safe, plan-reviewed provisioning
9. Docker containerization — secure, cache-optimized builds
10. Docker Compose orchestration — multi-service, tested persistence and healthchecks
11. Container registry deployment — ECR, cross-machine deployment, architecture mismatches
12. Cloud cost optimization — anomaly detection, rightsizing, known escalation traps
13. Free Tier and cost verification — cross-checking real vs. estimated spend
14. Secrets incident response — the general pattern for any exposed credential
15. Package pinning & safe upgrades — protecting critical versions, safe reboots
16. Git branch protection — PR workflow, solo vs. team configuration
17. Bounded demo provisioning — safe, cost-capped temporary cloud demos
18. Testing and QA — unit, integration, end-to-end, coverage discipline
19. Documentation standards — README, runbooks, architecture docs, changelogs
20. Release management & rollback — versioning, staging, practiced rollback
21. Production incident response — triage and diagnosis, routing to the right specific playbook
22. AI SQL chatbot — natural language to SQL, safely read-only scoped

## Planned — More Playbooks From Upcoming Sessions

Kubernetes orchestration and deployment patterns.

CI/CD pipelines — Jenkins and GitHub Actions.

Configuration management with Ansible.

Full observability stack — Prometheus and Grafana.

ArgoCD-based GitOps for Kubernetes specifically.

Secrets management with HashiCorp Vault.

Multi-cloud disaster recovery patterns.

Zero trust network security architecture.

AIOps — anomaly detection, predictive scaling, automated remediation.

Database operations — backups, migrations, replication (from the AWS RDS session).

Network/VPC design (from the networking and load balancer sessions).

## The Future Multi-Agent Repository

A separate, genuinely distinct repository is planned once this repository and the full 90-session curriculum are complete: a true multi-agent orchestration system, with multiple coordinating AI agents rather than a single agent consulting a playbook library. This requires real orchestration software, not additional documentation, and is deliberately scoped as its own project — built on top of this repository's mature, real-world-tested playbooks as its knowledge foundation, rather than started prematurely.

## Framework Evolution

Version 2 made the framework model-agnostic via AGENT.md, rewrote guardrails as an autonomy-first exception list, and added the decision-engine document. A later update added AGENT.md's role-based task routing table, explicitly framing the single AI as simulating each relevant team role per task — the realistic middle step toward eventual true multi-agent orchestration.
