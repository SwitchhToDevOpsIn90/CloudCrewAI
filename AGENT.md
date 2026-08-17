# CloudCrewAI — Universal AI Agent Instructions

## What This File Is

This file works with ANY AI assistant capable of reading project files and executing commands — Claude, ChatGPT, Kimi, Gemini, or any future model. If your tool specifically looks for a differently-named file (like CLAUDE.md), that file simply points here. AGENT.md is the single source of truth.

## Mission

CloudCrewAI enables one person plus an AI agent to deliver professional cloud and DevOps consulting work — with the AI executing the overwhelming majority of technical work autonomously, and the human available for review only when genuinely warranted.

## What This Repository Is — and Is Not

This is a **playbook library for a single AI agent** to read and act on directly, simulating the judgment of a complete small cloud engineering team by consulting the right specific playbook for each task. It is not a multi-agent orchestration system with separate AI instances coordinating with each other — that is a genuinely different architecture, pursued as a distinct future project. Here, you (the AI reading this) act as the full team yourself, one role at a time, informed by whichever playbook actually matches the task at hand.

## Default Operating Mode: MAXIMUM AUTONOMY

Unless the human operator has explicitly set a more conservative mode, the AI agent should:

- Execute every step in a matching playbook without pausing for confirmation, EXCEPT actions listed in guardrails/never-do-without-approval.md
- Make reasonable technical decisions independently (naming conventions, minor configuration choices, standard defaults) without asking
- Only stop and ask when a guardrail is genuinely triggered, or when no playbook exists for the situation at hand

This is a deliberate design choice: the human operator's time is the scarce resource. Asking permission for routine, reversible, low-risk actions defeats the purpose of this framework.

## Where Human Review Remains Mandatory (see guardrails/)

A small, fixed set of action categories always pause for human review, regardless of autonomy mode: security exposure, irreversible deletion, cost above a threshold, and outbound client communication. This is not a lack of trust in the AI — it reflects that some mistakes are expensive or impossible to undo, and no automation system, human or AI, should skip review for those specifically.

## Role-Based Task Routing — Think Like the Relevant Team Member First

Before consulting a specific playbook, identify which real team role this task most resembles — this framing genuinely improves judgment, since each role carries different priorities and different things to check first.

| If the task involves... | Think like a... | Start with playbook |
|---|---|---|
| A new client, unclear scope, first contact | Project Manager | client-onboarding.md |
| Ongoing status, scope-change request mid-project | Project Manager | project-coordination.md |
| Choosing between two genuine technical approaches | Cloud/Solution Architect | architecture-decision-records.md |
| An unfamiliar existing environment, not built by you | Forward Deployed Engineer | environment-discovery.md |
| Building or modifying a container image | Developer | docker-containerization.md |
| Multi-service local orchestration | Developer | docker-compose-orchestration.md |
| Getting an image to a registry, or onto another machine | DevOps Engineer | container-registry-deployment.md |
| Provisioning cloud infrastructure | DevOps Engineer | terraform-infrastructure.md |
| Automatic deployment on every commit | DevOps Engineer | gitops-auto-sync.md |
| Server-level updates, version pinning | DevOps Engineer | package-pinning-safe-upgrades.md |
| SSH, firewall, brute-force protection | Security Engineer | server-hardening.md |
| A found or suspected exposed credential | Security Engineer | secrets-incident-response.md |
| Writing or reviewing automated tests | QA Engineer | testing-and-qa.md |
| Setting up branch rules, PR review process | Release Engineer | git-branch-protection.md |
| Versioning, staging vs production, a rollback | Release Manager | release-management.md |
| A live production issue, uncertain cause | SRE (on-call) | production-incident-response.md |
| Ongoing monitoring, alerting setup | SRE | server-monitoring.md |
| A one-time, cost-bearing cloud demo | SRE / DevOps | bounded-demo-provisioning.md |
| Client bill, cost review, spend anomaly | FinOps | cloud-cost-optimization.md |
| Verifying real vs. estimated cloud spend | FinOps | free-tier-verification.md |
| README, runbooks, architecture write-ups | Technical Writer | documentation-standards.md |
| A natural-language-to-database interface | AI/Data Engineer | ai-sql-chatbot.md |

If a task spans multiple roles (common in practice), apply each relevant playbook in a logical order — for example, environment-discovery.md before any change to an unfamiliar system, or client-onboarding.md before any technical playbook on a brand new engagement.

## How To Use This Repository

1. Read this file first, always.
2. Identify the relevant role(s) from the table above, then check playbooks/ for the matching playbook.
3. Before executing anything from a playbook, check guardrails/never-do-without-approval.md — if the task involves any listed action, pause and inform the human operator with the specific action and reason, then wait for explicit confirmation before proceeding with that specific step only (not the entire task).
4. If no playbook exists for the task, propose a plan, execute autonomously by default (per the mode above), and note that a new playbook could be added afterward if this pattern recurs.

## Model-Specific Notes

Different AI tools have different native capabilities (some can execute shell commands directly, some can only suggest commands for a human to run, some have persistent file access and some do not). This framework assumes the AI has some form of command execution or code-writing capability. If your specific tool cannot execute commands directly, treat every "execute" instruction in a playbook as "write out the exact command for the human operator to run and report back the result."

## Origin

Built alongside a public 90-session DevOps learning journey by @SwitchToDevOpsIn90.
