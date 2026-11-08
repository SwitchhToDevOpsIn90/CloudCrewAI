#!/usr/bin/env bash
# Tests tools/teardown-check.sh with a fake `aws` command (no AWS access needed).
cd "$(dirname "$0")/.." || exit 1
T=$(mktemp -d); mkdir "$T/bin"
export FAKE_ID="1234""56789012"
cat > "$T/bin/aws" <<'FAKE'
#!/usr/bin/env bash
case "$MODE" in
 denied) echo "An error occurred (AccessDenied) when calling X: User: arn:aws:iam::${FAKE_ID}:user/u is not authorized" >&2; exit 254;;
 clean) exit 0;;
 found) case "$*" in *describe-volumes*) printf 'vol-0abc\t1\n';; esac; exit 0;;
esac
FAKE
chmod +x "$T/bin/aws"; pass=0; fail=0
t() { MODE=$1 PATH="$T/bin:$PATH" bash tools/teardown-check.sh eu-north-1 x >"$T/out" 2>&1; got=$?
  if [ "$got" = "$2" ]; then pass=$((pass+1)); else fail=$((fail+1)); echo "FAIL: $1 expected $2 got $got"; fi; }
t denied 2; t clean 0; t found 1
MODE=denied PATH="$T/bin:$PATH" bash tools/teardown-check.sh eu-north-1 x 2>&1 | grep -q "$FAKE_ID" && { fail=$((fail+1)); echo "FAIL: account id leaked in denied output"; }
echo "passed=$pass failed=$fail"; rm -rf "$T"; [ "$fail" = 0 ]
