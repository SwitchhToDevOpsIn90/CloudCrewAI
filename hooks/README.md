# Policy hooks (layer 4)

A hook runs before a tool call and blocks actions that need human approval. It turns the rules in `guardrails/never-do-without-approval.md` from advice into enforcement for agents that support hooks (Claude Code does; for others the guardrails remain instructions).

## What it blocks
- Irreversible deletion: eksctl/EKS deletes, terraform destroy, kubectl delete of namespaces/PVCs/PVs/StatefulSets, EBS volume/snapshot deletion, RDS/S3/IAM deletes, helm uninstall, `rm -rf`
- History rewrite: force push, filter-repo/filter-branch
- Security exposure: any `0.0.0.0/0` rule, IAM permission changes, mounting the Docker socket, `--privileged` containers, and publishing port 8080 on all interfaces (bind `127.0.0.1`)
- Production changes: helm upgrade/rollback and kubectl changes aimed at prod
- Secrets in files: access key IDs, secret keys, private keys, real account IDs in ARNs (Write/Edit)

## Approval
The human operator adds the EXACT command, one per line, to `.crew/approvals.txt` (gitignored). Only an exact match is allowed; a changed target is blocked again. Approved commands are not removed automatically; clear the file when the task ends.

## Own demo namespaces
A namespace the agent created itself and recorded in the resource ledger can be listed (one per line) in `.crew/owned.txt`. Deleting exactly that namespace is then allowed without approval, matching the guardrail exemption for disposable demo resources. Any other namespace, or several at once, is still blocked. This was added after the first `/crew-sprint` test, where the agent shared the `default` namespace to avoid the approval pause.

## Isolated Docker engines
A Docker-in-Docker engine for CI needs `--privileged`, which the hook blocks. That is intended: the operator approves the exact `docker run` command by adding it to `.crew/approvals.txt`, and the approval is the record that the privileged container was a deliberate choice (see playbooks/jenkins-docker-build-and-ecr-push.md).

## Install (Claude Code)
Copy `hooks/settings.example.json` into `.claude/settings.json` of the project the agent works in, with the path to this repo's `hooks/crew_policy.py`.

## Test
`bash hooks/test_policy.sh` (33 cases).

## Known limits
- Pattern matching, not understanding: a command built indirectly (script file, variable, `bash -c`) can slip past. It is a safety net, not a replacement for the guardrails or the independent verifier (layer 6).
- Blocks whole patterns, so read-only commands containing `0.0.0.0/0` are blocked too; the operator approves them.
- The demo-resource exemption cannot be detected by the hook; the operator approves those commands too.
- Live result (sprint 2, 2026-11-07): in a real Claude Code session the owned-namespace exemption allowed deleting the agent's own namespace without approval. The hook also blocked two plain file-edit commands whose heredoc text contained a namespace-delete string. Fixed since: heredoc bodies that are only data (for example written to a file with cat) are no longer checked, while a heredoc fed to a shell or interpreter still is; `kubectl --context X delete namespace <owned>` is now accepted too.
- Still pattern matching: a deletion hidden in a variable, a script file or an encoded string can pass. The verifier and the operator remain the backstop.
