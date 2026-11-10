#!/usr/bin/env bash
# Tests the private-terms feature of tools/scan-secrets.sh with temporary files.
cd "$(dirname "$0")/.." || exit 1
D=$(mktemp -d); pass=0; fail=0
echo "hello world" > "$D/clean.md"; echo "owner is Some-Private-Name here" > "$D/leak.md"
echo "some-private-name" > "$D/terms"
CREW_PRIVATE_TERMS="$D/terms" bash tools/scan-secrets.sh "$D/clean.md" >/dev/null 2>&1; [ $? = 0 ] && pass=$((pass+1)) || { fail=$((fail+1)); echo "FAIL: clean file flagged"; }
CREW_PRIVATE_TERMS="$D/terms" bash tools/scan-secrets.sh "$D/leak.md" >/dev/null 2>&1; [ $? = 1 ] && pass=$((pass+1)) || { fail=$((fail+1)); echo "FAIL: private term (any case) not caught"; }
CREW_PRIVATE_TERMS="$D/missing" bash tools/scan-secrets.sh "$D/leak.md" >/dev/null 2>&1; [ $? = 0 ] && pass=$((pass+1)) || { fail=$((fail+1)); echo "FAIL: missing terms file should not fail"; }
echo "passed=$pass failed=$fail"; rm -rf "$D"; [ "$fail" = 0 ]
