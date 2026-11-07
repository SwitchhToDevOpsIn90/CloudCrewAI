#!/usr/bin/env python3
"""CloudCrewAI policy hook (layer 4). Runs before a tool call and blocks actions
that guardrails/never-do-without-approval.md says need human approval.

Input: Claude Code PreToolUse JSON on stdin. Exit 0 = allow, exit 2 = block (reason on stderr).
Approval: the human operator adds the EXACT command, one per line, to the file named by
CREW_APPROVALS (default .crew/approvals.txt). An approved command is allowed once matched exactly.
"""
import json, os, re, sys

# (regex, reason). Matched against the Bash command.
BASH_RULES = [
    (r"\beksctl\s+delete\b", "irreversible deletion: EKS cluster/nodegroup"),
    (r"\baws\s+eks\s+delete-", "irreversible deletion: EKS resource"),
    (r"\bterraform\s+(destroy|apply\s+.*-destroy)\b", "irreversible deletion: terraform destroy"),
    (r"\bkubectl\s+delete\s+(ns|namespace|pvc|persistentvolumeclaim|pv|persistentvolume|statefulset|sts|cluster)\b", "irreversible deletion: data-bearing Kubernetes resource"),
    (r"\bkubectl\s+delete\b.*--all\b", "irreversible deletion: delete --all"),
    (r"\baws\s+ec2\s+(delete-volume|delete-snapshot|terminate-instances|delete-vpc)\b", "irreversible deletion: EC2/EBS resource"),
    (r"\baws\s+rds\s+delete-", "irreversible deletion: database"),
    (r"\baws\s+s3\s+(rb|rm)\b.*(--recursive|\brb\b)|\baws\s+s3\s+rb\b", "irreversible deletion: S3 bucket/objects"),
    (r"\baws\s+s3api\s+delete-(bucket|object)", "irreversible deletion: S3"),
    (r"\baws\s+iam\s+(delete-user|delete-access-key|delete-role|delete-policy)\b", "irreversible deletion: IAM"),
    (r"\bhelm\s+uninstall\b", "irreversible deletion: helm uninstall (history lost without --keep-history)"),
    (r"\bgit\s+push\b.*(--force\b|-f\b|--force-with-lease)", "history rewrite: force push"),
    (r"\bgit\s+filter-(repo|branch)\b|\bbfg\b", "history rewrite"),
    (r"\brm\s+-[a-zA-Z]*r[a-zA-Z]*f|\brm\s+-[a-zA-Z]*f[a-zA-Z]*r", "irreversible deletion: rm -rf"),
    (r"0\.0\.0\.0/0|::/0", "security exposure: world-open network rule"),
    (r"\baws\s+ec2\s+authorize-security-group-ingress\b.*--cidr\s+0\.0\.0\.0/0", "security exposure: world-open ingress"),
    (r"\baws\s+iam\s+(attach-user-policy|put-user-policy|attach-role-policy|create-user)\b", "security change: IAM permissions"),
    (r"\bhelm\s+(upgrade|rollback)\b.*(prod|production)", "production change: needs exact command + approval"),
    (r"\bkubectl\s+(apply|scale|rollout|set|patch|edit)\b.*(--context[ =]\S*prod|-n\s*prod|--namespace[ =]prod)", "production change"),
]

# Content rules for Write/Edit: block secrets and account IDs from entering files.
CONTENT_RULES = [
    (r"AKIA[0-9A-Z]{16}", "access key id in file content"),
    (r"(?i)aws_secret_access_key\s*[=:]\s*\S{20,}", "secret access key in file content"),
    (r"-----BEGIN (RSA |EC |OPENSSH )?PRIVATE KEY-----", "private key in file content"),
    (r"arn:aws[a-z-]*:[a-z0-9-]*:[a-z0-9-]*:\d{12}:", "real AWS account ID in an ARN (mask it)"),
]

def approved(cmd):
    path = os.environ.get("CREW_APPROVALS", ".crew/approvals.txt")
    try:
        with open(path) as f:
            return cmd.strip() in {l.strip() for l in f if l.strip() and not l.startswith("#")}
    except OSError:
        return False

def check(tool, inp):
    if tool == "Bash":
        cmd = inp.get("command", "")
        if approved(cmd):
            return None
        for pat, why in BASH_RULES:
            if re.search(pat, cmd):
                return why
    elif tool in ("Write", "Edit"):
        text = inp.get("content", "") + "\n" + inp.get("new_string", "")
        for pat, why in CONTENT_RULES:
            if re.search(pat, text):
                return why
    return None

def main():
    try:
        data = json.load(sys.stdin)
    except Exception:
        return 0  # not a hook payload: do not block
    why = check(data.get("tool_name", ""), data.get("tool_input", {}) or {})
    if why:
        print(f"BLOCKED by CloudCrewAI policy: {why}. Ask the human operator for approval naming the exact "
              f"action; they add the exact command to .crew/approvals.txt. See guardrails/never-do-without-approval.md.",
              file=sys.stderr)
        return 2
    return 0

if __name__ == "__main__":
    sys.exit(main())
