# CloudCrewAI — Universal AI Agent Instructions

## What This File Is

This file works with ANY AI assistant capable of reading project files and executing commands — Claude, ChatGPT, Kimi, Gemini, or any future model. If your tool specifically looks for a differently-named file (like CLAUDE.md), that file simply points here. AGENT.md is the single source of truth.

## Mission

CloudCrewAI enables one person plus an AI agent to deliver professional cloud and DevOps consulting work — with the AI executing the overwhelming majority of technical work autonomously, and the human available for review only when genuinely warranted.

## Default Operating Mode: MAXIMUM AUTONOMY

Unless the human operator has explicitly set a more conservative mode, the AI agent should:

- Execute every step in a matching playbook without pausing for confirmation, EXCEPT actions listed in guardrails/never-do-without-approval.md
- Make reasonable technical decisions independently (naming conventions, minor configuration choices, standard defaults) without asking
- Only stop and ask when a guardrail is genuinely triggered, or when no playbook exists for the situation at hand

This is a deliberate design choice: the human operator's time is the scarce resource. Asking permission for routine, reversible, low-risk actions defeats the purpose of this framework.

## Where Human Review Remains Mandatory (see guardrails/)

A small, fixed set of action categories always pause for human review, regardless of autonomy mode: security exposure, irreversible deletion, cost above a threshold, and outbound client communication. This is not a lack of trust in the AI — it reflects that some mistakes are expensive or impossible to undo, and no automation system, human or AI, should skip review for those specifically.

## How To Use This Repository

1. Read this file first, always.
2. For a new task, check playbooks/ for a matching pattern.
3. Before executing anything from a playbook, check guardrails/never-do-without-approval.md — if the task involves any listed action, pause and inform the human operator with the specific action and reason, then wait for explicit confirmation before proceeding with that specific step only (not the entire task).
4. If no playbook exists for the task, propose a plan, execute autonomously by default (per the mode above), and note that a new playbook could be added afterward if this pattern recurs.

## Model-Specific Notes

Different AI tools have different native capabilities (some can execute shell commands directly, some can only suggest commands for a human to run, some have persistent file access and some do not). This framework assumes the AI has some form of command execution or code-writing capability. If your specific tool cannot execute commands directly, treat every "execute" instruction in a playbook as "write out the exact command for the human operator to run and report back the result."

## Origin

Built alongside a public 90-session DevOps learning journey by @SwitchToDevOpsIn90.
