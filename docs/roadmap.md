# Roadmap

This framework grows alongside a public 90-session DevOps learning journey. Each playbook is added once the underlying skill is learned and genuinely proven — not every session produces a new playbook, only those with a genuinely new, reusable pattern.

## Complete — 8 Playbooks

1. Server monitoring — disk checks, S3 backup, CloudWatch metrics, alarms, email alerts
2. GitOps auto-sync — automatic deployment on new commits
3. Server hardening — SSH key-only auth, firewall, brute-force protection
4. Terraform infrastructure — safe, plan-reviewed provisioning
5. Docker containerization — secure, cache-optimized builds
6. Cloud cost optimization — anomaly detection, rightsizing, scheduled shutdowns
7. AI SQL chatbot — natural language to SQL, read-only scoped
8. Free Tier and cost verification — cross-checking real vs. estimated spend

## Planned

Kubernetes orchestration and deployment patterns.

CI/CD pipelines — Jenkins and GitHub Actions.

Configuration management with Ansible.

Full observability stack — Prometheus and Grafana.

ArgoCD-based GitOps for Kubernetes specifically.

Secrets management with HashiCorp Vault.

Multi-cloud disaster recovery patterns.

Zero trust network security architecture.

AIOps — anomaly detection, predictive scaling, automated remediation.

## Framework Evolution

Version 2 (current) made the framework model-agnostic via AGENT.md, rewrote guardrails as an autonomy-first exception list rather than a permission list, and added the decision-engine document formalizing exactly how an AI agent should reason through any task.
