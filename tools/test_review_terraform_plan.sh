#!/usr/bin/env bash
# Tests tools/review-terraform-plan.py on generated plan JSON. No terraform, no cloud access.
cd "$(dirname "$0")/.." || exit 1
D=$(mktemp -d); pass=0; fail=0; R="python3 tools/review-terraform-plan.py"
ok() { if [ "$1" = "$2" ]; then pass=$((pass+1)); else fail=$((fail+1)); echo "FAIL: $3 (got $1, wanted $2)"; fi; }
plan() { printf '{"resource_changes":[%s]}' "$1" > "$D/p.json"; }
rc() { printf '{"address":"%s.x","type":"%s","change":{"actions":%s,"after":%s}}' "$1" "$1" "$2" "${3:-{\}}"; }
plan "$(rc aws_instance '["create"]')"; $R "$D/p.json" >/dev/null; ok $? 0 "plain create passes"
plan "$(rc aws_db_instance '["delete"]')"; $R "$D/p.json" >/dev/null; ok $? 1 "database delete flagged"
plan "$(rc aws_db_instance '["delete","create"]')"; $R "$D/p.json" | grep -q "REPLACED"; ok $? 0 "database replace reported as replace"
plan "$(rc aws_s3_bucket '["delete"]')"; $R "$D/p.json" >/dev/null; ok $? 1 "bucket delete flagged"
plan "$(rc aws_instance '["delete","create"]')"; $R "$D/p.json" >/dev/null; ok $? 1 "any replace flagged"
plan "$(rc aws_instance '["delete"]')"; $R "$D/p.json" >/dev/null; ok $? 0 "non-stateful delete is a warning only"
$R "$D/p.json" | grep -q "^WARN"; ok $? 0 "non-stateful delete warned"
plan "$(rc aws_vpc_security_group_ingress_rule '["create"]' '{"cidr_ipv4":"0.0.0.0/0","from_port":22}')"; $R "$D/p.json" >/dev/null; ok $? 1 "world-open rule flagged"
plan "$(rc aws_vpc_security_group_ingress_rule '["create"]' '{"cidr_ipv4":"10.0.0.0/16"}')"; $R "$D/p.json" >/dev/null; ok $? 0 "private rule passes"
plan "$(rc aws_iam_policy '["create"]' '{"policy":"{\"Statement\":[{\"Action\":\"*\",\"Resource\":\"*\"}]}"}')"; $R "$D/p.json" >/dev/null; ok $? 1 "admin-style policy flagged"
plan "$(rc aws_iam_policy '["create"]' '{"policy":"{\"Statement\":[{\"Action\":\"s3:GetObject\",\"Resource\":\"arn:aws:s3:::b/*\"}]}"}')"; $R "$D/p.json" >/dev/null; ok $? 0 "scoped policy passes"
plan "$(rc aws_instance '["no-op"]')"; $R "$D/p.json" | grep -q "0 change"; ok $? 0 "no-op ignored"
echo '{"x":1}' > "$D/bad.json"; $R "$D/bad.json" >/dev/null; ok $? 2 "not a plan is a usage error"
$R "$D/missing.json" >/dev/null; ok $? 2 "missing file is a usage error"
$R >/dev/null; ok $? 2 "no argument is a usage error"
echo "passed=$pass failed=$fail"; rm -rf "$D"; [ "$fail" = 0 ]
