#!/usr/bin/env bash
# Tests tools/ledger.py on a temporary ledger. No real credentials are used; test values are built at runtime.
cd "$(dirname "$0")/.." || exit 1
D=$(mktemp -d); export CREW_LEDGER="$D/ledger.md"; L="python3 tools/ledger.py"
pass=0; fail=0
ok() { if [ "$1" = "$2" ]; then pass=$((pass+1)); else fail=$((fail+1)); echo "FAIL: $3 (got $1, wanted $2)"; fi; }
$L check >/dev/null 2>&1; ok $? 1 "check with no ledger must fail"
$L init demo '$5' eu-north-1 >/dev/null; ok $? 0 "init"
$L init demo '$5' eu-north-1 >/dev/null 2>&1; ok $? 1 "init must not overwrite"
$L check >/dev/null; ok $? 0 "empty ledger is clear"
$L add cluster demo-eks '$0.10/h' crew-build 'eksctl delete cluster demo-eks' >/dev/null; ok $? 0 "add"
$L add volume demo-vol '$1' crew-build 'aws ec2 delete-volume' >/dev/null
$L check >/dev/null; ok $? 1 "open rows must fail check"
$L close 1 "" >/dev/null 2>&1; ok $? 1 "close without evidence refused"
$L close 1 "teardown-check exit 0" >/dev/null; ok $? 0 "close with evidence"
$L close 1 "again" >/dev/null 2>&1; ok $? 1 "double close refused"
$L check >/dev/null; ok $? 1 "one row still open"
$L keep 2 "kept on purpose, free" >/dev/null; ok $? 0 "keep"
$L check >/dev/null; ok $? 0 "all closed or kept is clear"
KEY="AKI""AABCDEFGHIJKLMNOP"; $L add key "$KEY" '$0' x y >/dev/null 2>&1; ok $? 1 "credential refused"
ID="1234""56789012"; $L note decision "role in account $ID chosen" >/dev/null
grep -q "$ID" "$CREW_LEDGER"; ok $? 1 "12-digit number must be masked"
grep -q "ACCOUNT_ID" "$CREW_LEDGER"; ok $? 0 "mask placeholder present"
$L note bogus "x" >/dev/null 2>&1; ok $? 1 "unknown note kind refused"
$L add 'a|b' n c d e >/dev/null; ok $? 0 "pipe in input is sanitised"
[ "$(grep -c '^| [0-9]' "$CREW_LEDGER")" = 3 ]; ok $? 0 "table stays well-formed (3 rows)"
echo "passed=$pass failed=$fail"; rm -rf "$D"; [ "$fail" = 0 ]
