# Playbook: GitOps Auto-Sync

## WHY

Manual deployment steps get forgotten or delayed. GitOps eliminates this by making the server check for updates on its own.

## WHAT This Delivers

A cron-scheduled script that detects new commits on GitHub and pulls them automatically, zero manual intervention.

## Steps

1. Write a sync script comparing local HEAD against origin main.
2. If different, pull changes and log the result.

3. Schedule via cron every 5 minutes.
4. Add the log file to .gitignore immediately.

## Guardrail Check

This only pulls code, never pushes or deletes automatically. Confirm branch protection prevents unreviewed code reaching main, since anything merged there auto-deploys.

## Reference

See devops-journey repo, gitops-sync.sh, Session 15.
