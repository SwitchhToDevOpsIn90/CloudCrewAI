# CloudCrewAI

An AI-powered virtual cloud team framework. One person plus an AI agent, delivering professional cloud and DevOps consulting work — with the AI executing the overwhelming majority of technical work autonomously, and the human available for review only when genuinely warranted.

## The Idea

The AI acts as a complete small cloud engineering team — architect, developer, DevOps engineer, security engineer, QA, SRE, FinOps, and project manager — by consulting the right playbook for whatever task is at hand. It executes real technical work autonomously by default. The human operator provides direction and reviews only the small set of genuinely high-risk actions defined in the guardrails.

## Model-Agnostic By Design

This framework works with any AI agent capable of reading project files and executing commands — Claude, ChatGPT, Kimi, Gemini, or future models. Start with AGENT.md, the universal entry point. CLAUDE.md exists only as a compatibility pointer for Claude Code specifically.

## What This Repository Is — and Is Not

This is a playbook library for a **single AI agent** to read and act on, simulating a complete small cloud team by consulting the right specific playbook per task. It is **not** a multi-agent orchestration system with separate coordinating AI instances — that is a deliberately separate, future project (see Roadmap below).

## How This Works

Connect this repository to Claude, ChatGPT, or any capable AI assistant. Point it to AGENT.md. It reads the role-based routing table, checks guardrails, and executes the matching playbook for your task — autonomously, by default.

## Current Capabilities — 22 Playbooks

**Client & Project Management:** Client onboarding, Ongoing project coordination
**Architecture:** Architecture decision records, Existing environment discovery (FDE-readiness)
**Development:** Docker containerization, Docker Compose orchestration, Container registry deployment
**Infrastructure & DevOps:** Terraform infrastructure, GitOps auto-sync, Package pinning & safe upgrades
**Security:** Server hardening, Secrets incident response
**Testing & QA:** Testing and QA
**Release & Operations:** Git branch protection, Release management & rollback, Bounded demo provisioning
**Reliability (SRE):** Server monitoring, Production incident response
**Cost (FinOps):** Cloud cost optimization, Free Tier verification
**Documentation:** Documentation standards
**AI/Data:** AI SQL chatbot

See docs/roadmap.md for what's planned next.

## Repository Structure

- **AGENT.md** — universal AI entry point, read this first (includes role-based task routing table)
- **CLAUDE.md** — Claude Code compatibility pointer
- **docs/decision-engine.md** — the actual autonomous reasoning flow
- **docs/roadmap.md** — what's built, what's planned, the future multi-agent repo plan
- **guardrails/** — the short list of actions requiring human approval
- **playbooks/** — all 22 step-by-step patterns, one per real capability
- **templates/** — reusable starter files referenced by playbooks

## The Bigger Picture — Two Repositories, Two Purposes

**This repository (CloudCrewAI)** is the working, production-ready single-agent playbook library — usable today, growing alongside a real 90-session public DevOps learning journey.

**A second, separate repository is planned** for true multi-agent orchestration — genuinely different architecture involving multiple coordinating AI agents, not just more playbooks. That effort begins only once this repository and the full 90-session curriculum are complete, so the orchestrator is built on a mature, real foundation rather than speculation.

## Origin

Built alongside a public 90-session DevOps learning journey by @SwitchToDevOpsIn90.
