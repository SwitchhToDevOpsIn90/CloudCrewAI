# Playbook: Secrets Incident Response

## WHY

A hardcoded secret being discovered is not a hypothetical risk exercise — it is one of the most common real incidents any cloud engagement will face, and the specific secret type will differ every single time. This playbook exists because the exact fix always varies, but the reasoning process to get there does not.

## WHAT This Playbook Delivers

A repeatable four-step process for responding to ANY discovered secret — regardless of whether it is an AWS key, a database password, a third-party API token, or an SSH key — moving from detection to full resolution without guessing at each new incident from scratch.

## Prerequisites

Read or execute access to the location being audited (a repository, a live server, a container image). Sufficient permissions in whichever service issued the exposed credential to actually revoke or rotate it once found.

## Steps

1. Detect using the right pattern for the secret type actually being searched for. Generic words like "password" and "secret" catch some cases; recognizing actual credential shapes catches more. AWS keys start with AKIA or ASIA. GitHub tokens start with ghp_ or github_pat_. Slack tokens start with xox. Database connection strings follow a protocol://user:password@host pattern. Private keys contain a distinctive BEGIN PRIVATE KEY header. For any engagement beyond a small known codebase, use a dedicated scanner such as gitleaks or truffleHog rather than relying on manual grep patterns alone, since these tools check hundreds of known formats and use entropy analysis to catch unrecognized ones.

2. Contain immediately using whichever mechanism the issuing service actually provides. An AWS access key gets deactivated in IAM Console or via aws iam update-access-key. A GitHub token gets revoked under Developer settings. A database password gets changed directly, which invalidates every existing connection using the old value simultaneously. A third-party API key (Stripe, Twilio, SendGrid, or similar) gets revoked or rolled from that specific service's own dashboard. An SSH key gets removed from the authorized_keys file of anything that trusted it. The specific action varies; the urgency and immediacy do not.

3. Decide between rotating to a new static credential or eliminating the category of static credential entirely, by asking whether a role-based or temporary-credential alternative exists for this specific service. AWS workloads running on EC2, Lambda, or ECS can eliminate static keys entirely using an IAM Role. Database access from an AWS-hosted application can often eliminate static passwords using AWS Secrets Manager or IAM database authentication. Many third-party SaaS APIs have no equivalent system and genuinely require rotating to a new static key — in that case, store the replacement in a secrets manager or a properly gitignored .env file, never hardcoded again, and set a recurring reminder to rotate it periodically regardless.

4. Choose manual console work or CLI automation based on whether this specific task is a one-time incident or something that will recur. A single client's single exposed key, handled once, is reasonably done manually in the console, especially when visual confirmation of the full picture matters or when the CLI itself lacks the needed permission. Anything that will repeat — across multiple servers, multiple clients, or on any kind of schedule — should be scripted and considered as a candidate for its own dedicated playbook here.

## Guardrail Check

Never leave real credential values in any saved documentation, chat log, or screenshot, even after the credential has been fully revoked or deleted — always redact to a masked placeholder. Never delay containment to first investigate root cause; contain first, understand afterward. Confirm with the human operator before considering an incident fully closed if the exposed secret had access to production client data, regardless of how quickly it was contained.

## Reference Implementation

See github.com/SwitchhToDevOpsIn90/devops-journey, Session 19 — a real incident where an active AWS access key was found in plaintext on a live server, contained by deactivation, then resolved architecturally by migrating to an IAM Role rather than merely rotating to a new key, with the old credential subsequently fully deleted.
