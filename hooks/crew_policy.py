#!/usr/bin/env python3
"""CloudCrewAI policy hook (layer 4). Runs before a tool call and blocks actions
that guardrails/never-do-without-approval.md says need human approval.

Input: Claude Code PreToolUse JSON on stdin. Exit 0 = allow, exit 2 = block (reason on stderr).
Own demo namespace: a namespace listed in CREW_OWNED (default .crew/owned.txt) may be deleted without approval.
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

def owned_names():
    """Names the agent created itself this engagement (recorded in the resource ledger),
    one per line in CREW_OWNED (default .crew/owned.txt), e.g. a demo namespace."""
    path = os.environ.get("CREW_OWNED", ".crew/owned.txt")
    try:
        with open(path) as f:
            return {l.strip() for l in f if l.strip() and not l.startswith("#")}
    except OSError:
        return set()

def deletes_only_owned_namespace(cmd):
    ctx = r"(?:\s+--context[ =]\S+)?"
    m = re.fullmatch(r"\s*kubectl" + ctx + r"\s+delete\s+(?:ns|namespace)[ /]+([a-z0-9-]+)" + ctx + r"\s*", cmd)
    return bool(m) and m.group(1) in owned_names()

INTERPRETERS = re.compile(r"\b(bash|sh|zsh|dash|ksh|python3?|perl|ruby|node|eval|source)\b")

def strip_heredoc_bodies(cmd):
    """Remove heredoc bodies that are only data (for example text written to a file with cat or tee).
    A heredoc fed to a shell or interpreter is code, so it is kept and still checked."""
    lines, out, i = cmd.split("\n"), [], 0
    while i < len(lines):
        line = lines[i]
        out.append(line)
        m = re.search(r"<<-?\s*['\"]?(\w+)['\"]?", line)
        i += 1
        if m:
            marker = m.group(1)
            body = []
            while i < len(lines) and lines[i].strip() != marker:
                body.append(lines[i]); i += 1
            if INTERPRETERS.search(line):
                out.extend(body)
            if i < len(lines):
                out.append(lines[i]); i += 1
    return "\n".join(out)

def check(tool, inp):
    if tool == "Bash":
        cmd = inp.get("command", "")
        if approved(cmd) or deletes_only_owned_namespace(cmd):
            return None
        checked = strip_heredoc_bodies(cmd)
        for pat, why in BASH_RULES:
            if re.search(pat, checked):
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
