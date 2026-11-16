#!/usr/bin/env bash
# Tests tools/check-workflows.py on generated fixtures. No network, no credentials.
cd "$(dirname "$0")/.." || exit 1
D=$(mktemp -d); pass=0; fail=0; C="python3 tools/check-workflows.py"
SHA40="3d3c42e5aac5ba805825da76410c181273ba90b1"
ok() { if [ "$1" = "$2" ]; then pass=$((pass+1)); else fail=$((fail+1)); echo "FAIL: $3 (got $1, wanted $2)"; fi; }
cat > "$D/good.yml" <<YML
name: CI
on: { pull_request: }
permissions:
  contents: read
jobs:
  t:
    runs-on: ubuntu-latest
    timeout-minutes: 5
    steps:
      - uses: actions/checkout@$SHA40 # v7
        with:
          persist-credentials: false
      - run: echo hello
YML
$C "$D/good.yml" >/dev/null; ok $? 0 "clean workflow passes"
sed 's/@'"$SHA40"'/@v4/' "$D/good.yml" > "$D/tag.yml"; $C "$D/tag.yml" >/dev/null; ok $? 1 "tag instead of SHA is flagged"
sed 's/pull_request: /pull_request_target: /' "$D/good.yml" > "$D/prt.yml"; $C "$D/prt.yml" >/dev/null; ok $? 1 "pull_request_target flagged"
sed 's/contents: read/write-all/;s/^permissions:/permissions: write-all #/' "$D/good.yml" > "$D/wa.yml"; $C "$D/wa.yml" >/dev/null; ok $? 1 "write-all flagged"
{ cat "$D/good.yml"; echo '      - run: echo "${{ github.event.pull_request.title }}"'; } > "$D/inj.yml"; $C "$D/inj.yml" >/dev/null; ok $? 1 "script injection flagged"
{ cat "$D/good.yml"; echo '      - if: github.event.pull_request.title == '"'x'"; } > "$D/ifok.yml"; $C "$D/ifok.yml" >/dev/null; ok $? 0 "untrusted text in if: is allowed"
{ cat "$D/good.yml"; echo '      - run: echo ${{ secrets.TOKEN }}'; } > "$D/sec.yml"; $C "$D/sec.yml" >/dev/null; ok $? 1 "echoed secret flagged"
sed '/^permissions:/,/contents: read/d' "$D/good.yml" > "$D/noperm.yml"; out=$($C "$D/noperm.yml"); rc=$?; ok $rc 0 "missing permissions is a warning only"; echo "$out" | grep -q "WARN.*permissions"; ok $? 0 "missing permissions warned"
sed '/persist-credentials/d;/with:/d' "$D/good.yml" > "$D/pc.yml"; $C "$D/pc.yml" | grep -q "WARN.*persist-credentials"; ok $? 0 "checkout persist-credentials warned"
sed '/timeout-minutes/d' "$D/good.yml" > "$D/to.yml"; $C "$D/to.yml" | grep -q "WARN.*timeout"; ok $? 0 "missing timeout warned"
$C >/dev/null 2>&1; ok $? 2 "no arguments is a usage error"
$C "$D" >/dev/null; ok $? 1 "folder scan finds the flagged files"
echo "passed=$pass failed=$fail"; rm -rf "$D"; [ "$fail" = 0 ]
