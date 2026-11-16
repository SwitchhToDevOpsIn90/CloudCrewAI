#!/usr/bin/env bash
# Tests tools/check-repo.sh against a tiny temporary repository layout.
cd "$(dirname "$0")/.." || exit 1
SRC="$PWD/tools/check-repo.sh"; pass=0; fail=0
ok() { if [ "$1" = "$2" ]; then pass=$((pass+1)); else fail=$((fail+1)); echo "FAIL: $3 (got $1, wanted $2)"; fi; }
mk() { D=$(mktemp -d); mkdir -p "$D/tools" "$D/playbooks" "$D/skills/s"; cp "$SRC" "$D/tools/check-repo.sh"; : > "$D/tools/test_check_repo.sh"
  printf '## Guardrail Check\nx\n## Reference Implementation\ny\n' > "$D/playbooks/a.md"
  echo "| thing | a.md |" > "$D/AGENT.md"; echo "- **Playbooks** (1) here" > "$D/README.md"
  printf 'uses playbooks/a.md\n' > "$D/skills/s/SKILL.md"; }
mk; bash "$D/tools/check-repo.sh" >/dev/null; ok $? 0 "consistent layout passes"; rm -rf "$D"
mk; sed -i 's/Guardrail Check/Other/' "$D/playbooks/a.md"; bash "$D/tools/check-repo.sh" >/dev/null; ok $? 1 "missing guardrail heading caught"; rm -rf "$D"
mk; echo "nothing" > "$D/AGENT.md"; bash "$D/tools/check-repo.sh" >/dev/null; ok $? 1 "unrouted playbook caught"; rm -rf "$D"
mk; echo "- **Playbooks** (7) here" > "$D/README.md"; bash "$D/tools/check-repo.sh" >/dev/null; ok $? 1 "wrong README count caught"; rm -rf "$D"
mk; rm "$D/skills/s/SKILL.md"; bash "$D/tools/check-repo.sh" >/dev/null; ok $? 1 "skill without SKILL.md caught"; rm -rf "$D"
mk; echo 'playbooks/missing.md' >> "$D/skills/s/SKILL.md"; bash "$D/tools/check-repo.sh" >/dev/null; ok $? 1 "skill naming a missing playbook caught"; rm -rf "$D"
mk; echo '#!/bin/sh' > "$D/tools/orphan.sh"; bash "$D/tools/check-repo.sh" >/dev/null; ok $? 1 "tool without test caught"; rm -rf "$D"
echo "passed=$pass failed=$fail"; [ "$fail" = 0 ]
