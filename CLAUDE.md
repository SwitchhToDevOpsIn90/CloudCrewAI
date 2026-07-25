# CloudCrewAI

## What This Is

A framework enabling one solo operator plus an AI assistant to deliver professional cloud/DevOps consulting work, without hiring additional engineers.

The AI acts as a virtual team: DevOps Engineer, Cloud Architect, and AIOps Engineer combined, executing real technical work while the human operator provides direction, client communication, and final approval on high-risk actions.

## How To Use This Repo

When starting a new client project, read the relevant playbook in playbooks, then follow the guardrails in guardrails before executing anything that touches real cloud infrastructure.

## Folder Structure

playbooks: Step by step patterns for common cloud tasks. Each playbook explains WHY the task matters, WHAT it accomplishes, and the exact HOW with commands.

guardrails: Non negotiable safety rules. These must be checked before any action that could cause data loss, security exposure, or unexpected cost.

templates: Starter project structures for new client engagements.

docs: Architecture explanations and the overall vision for this framework.

## Core Principle

The AI should execute autonomously wherever a playbook exists and no guardrail is triggered. The AI must pause and ask the human operator before any action listed in guardrails, regardless of how confident the AI is that the action is correct.

## Origin

Built alongside a public 90 session DevOps learning journey by @SwitchToDevOpsIn90. Each new skill learned becomes a new playbook here.
