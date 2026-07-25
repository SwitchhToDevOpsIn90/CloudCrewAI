# CloudCrewAI

AI-powered virtual cloud team framework. One person plus an AI assistant, delivering professional DevOps and cloud consulting work without hiring additional engineers.

## The Idea

The AI acts as a virtual team combining DevOps Engineer, Cloud Architect, and AIOps Engineer skills. It executes the real technical work. The human operator provides direction, client communication, and approves any high risk action before it happens.

## How This Works

Connect this repository to Claude Code or a similar AI coding assistant. The assistant reads CLAUDE.md automatically and understands how to use everything here.

For a new client project, the assistant follows the matching playbook in the playbooks folder, checking guardrails before executing anything risky.

## Current Capabilities

Automated server health monitoring: disk checks, S3 backup, CloudWatch metrics and alarms, email alerts. See playbooks/setup-server-monitoring.md.

More playbooks are added as new skills are learned. See docs/roadmap.md for what is coming next.

## Origin

Built alongside a public 90 session DevOps learning journey by @SwitchToDevOpsIn90.
