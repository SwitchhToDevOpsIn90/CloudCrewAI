# Roadmap

The long-term goal and milestones are in docs/vision.md.

This framework grows alongside a public 90-session DevOps learning journey. Each playbook is added once the underlying skill is learned and genuinely proven — not every session produces a new playbook, only those with a genuinely new, reusable pattern. A small number of foundational team-operating playbooks (client onboarding, testing/QA, documentation, release management, production incident response, project coordination, environment discovery) were added directly, representing standard practice for a complete team rather than requiring a specific triggering session.

## Complete — 31 Playbooks

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
23. Kubernetes core and networking — objects, self-healing, services, ingress, Secrets
24. EKS cluster setup — permissions, Free Tier node types, multi-resource teardown verification
25. Kubernetes persistent storage — PVC/PV, StatefulSets, reclaim policy, EBS-aware teardown
26. Helm chart packaging and releases — values overrides, revisions, rollback, automatic rollback on failure, custom templates, checksum rollout, per-environment values, Kustomize comparison, named templates, required, values schema, release inspection
27. Customer communication and post-incident reports — honest drafts, no unverified causes or promises
28. Decommissioning and data deletion — authority, inventory, backup decision, exact-resource approval, ordered deletion
29. Offboarding and identity cleanup — departed engineer IAM user, keys and buckets: contain first, exact-resource approval, verified deletion
30. Jenkins CI setup and security — loopback-only UI, pinned versions, agents with controller at 0 executors, matrix security, polling trigger, backup, no Docker socket
31. Jenkins pipelines as code — Jenkinsfile from Git, labelled agent with Dockerfile toolchain, test gate proven by a deliberate failure, restart recovery

## Planned — Playbooks Mapped to the Curriculum

Each playbook is written only after the matching session is done with real output, so it is labelled proven. Session numbers follow the master plan (v2).

| Sessions | Topic | Planned playbook |
|---|---|---|
| 39-41 | Jenkins setup, pipelines, Docker integration | Setup and security (Session 39) and pipelines as code (Session 40) done. Docker builds in Session 41 |
| 42-44 | GitHub Actions CI and CD, OIDC to AWS | CI/CD with GitHub Actions; keyless AWS deployment |
| 45-49 | Python automation, DeployBot project | Pipeline verification and rollback in CI/CD |
| 50-52 | ArgoCD and GitOps for Kubernetes | Kubernetes GitOps with ArgoCD |
| 53-55 | RDS and databases, microservices | Database operations: backups, restores, migrations |
| 56-58 | Autoscaling, RBAC, load balancer and DNS | Workload reliability, Kubernetes RBAC and NetworkPolicy, ingress and DNS |
| 61-67 | Terraform, multi-cloud DR | Terraform at scale; disaster recovery runbooks |
| 68-71 | Ansible, DR runbooks | Configuration management |
| 72-75 | Prometheus, Grafana, logging, SLOs | Full observability stack |
| 76-80 | DevSecOps, compliance, secrets, zero trust | Security pipeline; secrets management; zero trust |
| 81-85 | AIOps | Anomaly detection and automated remediation |

Standing rule: a playbook that touches deletion, security or production gets a guardrail check and a verifier test before it is called done.

