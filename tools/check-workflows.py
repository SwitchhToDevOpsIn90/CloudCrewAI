#!/usr/bin/env python3
"""Audit GitHub Actions workflow files for the mistakes found in CloudCrewAI sessions 42-44.
Usage: tools/check-workflows.py <workflow-file-or-folder> [...]
Rules (FLAG fails the run, WARN is advice):
  FLAG  action not pinned to a 40-character commit SHA (a tag or branch can be moved)
  FLAG  pull_request_target (runs with secrets on untrusted pull requests; needs a human look)
  FLAG  permissions: write-all
  FLAG  untrusted text (issue/PR title or body, branch name, commit message, comment) used in an expression
        outside an 'if:' line, which can inject shell commands
  FLAG  a secret echoed or printed in a run step
  WARN  no workflow-level 'permissions:' block (token gets the repository default)
  WARN  actions/checkout without persist-credentials: false
  WARN  fewer 'timeout-minutes' than jobs
  WARN  a required-looking check job name that is a matrix or has no stable gate job is not checked here
Line-based on purpose (no YAML library needed); it can miss unusual formatting. Status: v0, tested on
fixtures (tools/test_check_workflows.sh). It does not replace actionlint; it adds the rules above.
Exit: 0 no FLAG, 1 at least one FLAG, 2 usage error.
"""
import os, re, sys

UNTRUSTED = re.compile(r"\$\{\{[^}]*(github\.head_ref|github\.event\.(issue|pull_request|comment|review|discussion)\.(title|body|head\.ref|head\.label)|github\.event\.head_commit\.(message|author\.(name|email))|github\.event\.commits)[^}]*\}\}")
USES = re.compile(r"^\s*-?\s*uses:\s*([^\s#]+)")
SHA = re.compile(r"@[0-9a-f]{40}$")

def audit(path):
    flags, warns = [], []
    try:
        lines = open(path, encoding="utf-8").read().split("\n")
    except OSError as e:
        return [f"{path}: cannot read ({e})"], []
    text = "\n".join(lines)
    for n, line in enumerate(lines, 1):
        code = line.split(" #")[0] if not line.lstrip().startswith("#") else ""
        m = USES.match(code)
        if m:
            ref = m.group(1)
            if not ref.startswith("./") and not ref.startswith("docker://") and not SHA.search(ref):
                flags.append(f"{path}:{n}: action not pinned to a commit SHA: {ref}")
            if ref.startswith("actions/checkout@"):
                if not any("persist-credentials" in l for l in lines[n:n + 6]):
                    warns.append(f"{path}:{n}: actions/checkout without persist-credentials: false")
        if re.search(r"\bpull_request_target\b", code) and not re.match(r"^\s*(-\s*)?if:", code):
            flags.append(f"{path}:{n}: pull_request_target needs a human look (secrets reach untrusted code)")
        if re.search(r"permissions:\s*write-all", code):
            flags.append(f"{path}:{n}: permissions: write-all")
        if UNTRUSTED.search(code) and not re.match(r"^\s*(-\s*)?if:", code):
            flags.append(f"{path}:{n}: untrusted text in an expression outside 'if:' (script injection risk); pass it through an env variable")
        if re.search(r"\b(echo|printf|cat)\b[^\n]*\$\{\{\s*secrets\.", code):
            flags.append(f"{path}:{n}: secret printed in a run step")
    if not re.search(r"^permissions\s*:", text, re.M):
        warns.append(f"{path}: no workflow-level permissions block")
    jobs = len(re.findall(r"^\s+runs-on\s*:", text, re.M))
    timeouts = len(re.findall(r"^\s+timeout-minutes\s*:", text, re.M))
    if timeouts < jobs:
        warns.append(f"{path}: {jobs} job(s) but only {timeouts} timeout-minutes")
    return flags, warns

def main(argv):
    if not argv:
        print(__doc__); return 2
    files = []
    for a in argv:
        if os.path.isdir(a):
            for r, _, fs in os.walk(a):
                files += [os.path.join(r, f) for f in sorted(fs) if f.endswith((".yml", ".yaml"))]
        else:
            files.append(a)
    if not files:
        print("no workflow files found"); return 2
    nflag = 0
    for f in files:
        flags, warns = audit(f)
        for x in flags: print("FLAG", x)
        for x in warns: print("WARN", x)
        nflag += len(flags)
    print(f"check-workflows: {len(files)} file(s), {nflag} flag(s)")
    return 1 if nflag else 0

if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
