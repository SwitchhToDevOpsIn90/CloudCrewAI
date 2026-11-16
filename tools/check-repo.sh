#!/usr/bin/env bash
# Consistency check for the library itself. Exit 0 = consistent, 1 = problems listed.
#  - every playbook has a Guardrail Check and a Reference Implementation section
#  - every playbook is routed from AGENT.md
#  - the playbook count in README.md matches the files
#  - every skill folder has a SKILL.md and every playbook it names exists
#  - every tool script has a test script
cd "$(dirname "$0")/.." || exit 2
bad=0; say() { echo "PROBLEM: $*"; bad=$((bad+1)); }
n=0
for f in playbooks/*.md; do
  n=$((n+1)); b=$(basename "$f")
  grep -qi '^#\+ *guardrail' "$f" || say "$b: no Guardrail Check heading"
  grep -qi '^#\+ *reference implementation' "$f" || say "$b: no Reference Implementation heading"
  grep -q "$b" AGENT.md || say "$b: not routed from AGENT.md"
done
claimed=$(grep -o 'Playbooks\*\* ([0-9]*)' README.md | grep -o '[0-9]*')
[ "$claimed" = "$n" ] || say "README claims $claimed playbooks, found $n"
for d in skills/*/; do
  [ -f "$d/SKILL.md" ] || say "$d: no SKILL.md"
  for p in $(grep -o 'playbooks/[A-Za-z0-9._-]*\.md' "$d/SKILL.md" 2>/dev/null | sort -u); do
    [ -f "$p" ] || say "$d: names missing playbook $p"
  done
done
for t in tools/*.sh tools/*.py; do
  [ -e "$t" ] || continue
  case "$t" in */test_*) continue;; esac
  base=$(basename "$t"); base=${base%.*}; base=${base//-/_}
  ls tools/test_"$base".* >/dev/null 2>&1 || say "$t: no test script (tools/test_$base.*)"
done
[ $bad = 0 ] && echo "check-repo: consistent ($n playbooks)" || echo "check-repo: $bad problem(s)"
[ $bad = 0 ]
