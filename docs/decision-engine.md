# Decision Engine — How the AI Agent Should Think

## Purpose

This document is the actual reasoning flow an AI agent follows on any task, from receiving a request to completing it. Read this after AGENT.md, before starting any real work.

## The Flow

### Step 1: Identify the task category

Does this match an existing playbook in playbooks/? If yes, go to Step 2. If no, go to Step 5.

### Step 2: Load the matching playbook

Read the full playbook. Note every step and its Guardrail Check section specifically.

### Step 3: Cross-check every step against guardrails/never-do-without-approval.md

For each step in the playbook, ask: does this step involve security exposure, data deletion, cost above the threshold, or client communication? 

If NO to all four — execute the step immediately, without asking.
If YES to any — pause, state the specific action and which guardrail it triggers, wait for explicit human confirmation on that one step only, then continue.

### Step 4: Complete the task, report results

Summarize what was done, what (if anything) required human approval and why, and what the end state is. Do not ask "should I continue" for routine follow-up steps within the same playbook — only pause at genuine guardrail triggers.

### Step 5: No matching playbook exists

Propose a short plan (3-5 sentences) of what you intend to do and why. Then execute autonomously by default, applying the same guardrail cross-check from Step 3 to your own proposed plan. Afterward, note to the human operator: "This pattern doesn't have a playbook yet — worth adding one if this comes up again?"

## Handling Ambiguity

If a request is unclear, do not default to asking a clarifying question first. Make the most reasonable assumption, state it in one sentence, and proceed. Only ask a genuine clarifying question if proceeding would clearly waste significant effort or go in a completely wrong direction.

## Handling Multi-Step Tasks Spanning Several Playbooks

Some real client tasks combine multiple playbooks (for example, setting up monitoring AND GitOps auto-sync for the same new server). Execute playbooks in a logical dependency order (infrastructure before monitoring before automation), running the full Step 1-4 flow for each, without re-asking for approvals already granted earlier in the same task for the same guardrail category.

## Model-Agnostic Note

This decision flow does not depend on any single AI model's specific features. Any AI capable of reading these files and following conditional logic can execute it — Claude, ChatGPT, Kimi, or otherwise.
