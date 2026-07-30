# CloudCrewAI

An AI-powered virtual cloud team framework. One person plus an AI agent, delivering professional cloud and DevOps consulting work — with the AI executing the overwhelming majority of technical work autonomously, and the human available for review only when genuinely warranted.

## The Idea

The AI acts as a virtual team combining DevOps Engineer, Cloud Architect, and AIOps Engineer skills. It executes real technical work autonomously by default. The human operator provides direction and reviews only the small set of genuinely high-risk actions defined in the guardrails.

## Model-Agnostic By Design

This framework works with any AI agent capable of reading project files and executing commands — Claude, ChatGPT, Kimi, Gemini, or future models. Start with AGENT.md, the universal entry point. CLAUDE.md exists only as a compatibility pointer for Claude Code specifically.

## How This Works

Connect this repository to Claude, ChatGPT, or any capable AI assistant. Point it to AGENT.md. It reads the decision engine, checks guardrails, and executes the matching playbook for your task — autonomously, by default.

## Current Capabilities — 8 Playbooks

- **Server Monitoring** — automated health checks, S3 backup, CloudWatch metrics and alarms, email alerts
- **GitOps Auto-Sync** — cron-scheduled automatic deployment on every new commit
- **Server Hardening** — SSH key-only auth, ufw firewall, fail2ban brute-force protection
- **Terraform Infrastructure** — safe, reviewed infrastructure-as-code provisioning
- **Docker Containerization** — secure, cache-optimized container builds
- **Cloud Cost Optimization** — automated anomaly detection, rightsizing, scheduled shutdowns
- **AI SQL Chatbot** — natural language to SQL, safely scoped to read-only access
- **Free Tier and Cost Verification** — cross-checking real spend across Budget, Cost Explorer, and Billing data

See docs/roadmap.md for what's planned next.

## Repository Structure

- **AGENT.md** — universal AI entry point, read this first
- **CLAUDE.md** — Claude Code compatibility pointer
- **docs/decision-engine.md** — the actual autonomous reasoning flow
- **guardrails/** — the short list of actions requiring human approval
- **playbooks/** — step-by-step patterns for each capability above
- **templates/** — reusable starter files referenced by playbooks

## Origin

Built alongside a public 90-session DevOps learning journey by @SwitchToDevOpsIn90.
