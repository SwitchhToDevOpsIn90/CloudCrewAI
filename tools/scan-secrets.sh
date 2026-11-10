#!/usr/bin/env bash
# Read-only scan for secrets and account identifiers before committing.
# Usage: tools/scan-secrets.sh <path> [<path> ...]
# Exit 0 = nothing found. Exit 1 = matches found (review each one by hand).
# Optional private-terms list: see the end of this script.
# 12-digit numbers can be false positives (timestamps, ids); a human decides.
set -u
[ $# -ge 1 ] || { echo "usage: $0 <path> [<path>...]"; exit 2; }
found=0
scan() {
  label="$1"; pattern="$2"; shift 2
  out=$(grep -rnIE --exclude-dir=.git --exclude-dir=node_modules "$pattern" "$@" 2>/dev/null)
  if [ -n "$out" ]; then
    echo "== $label"; echo "$out"; echo; found=1
  fi
}
scan "AWS access key id"        'AKIA[0-9A-Z]{16}|ASIA[0-9A-Z]{16}' "$@"
scan "Private key block"        '-----BEGIN [A-Z ]*PRIVATE KEY-----' "$@"
scan "AWS secret key assignment" 'aws_secret_access_key[[:space:]]*[=:][[:space:]]*[A-Za-z0-9/+=]{20,}' "$@"
scan "GitHub token"             'gh[pousr]_[A-Za-z0-9]{30,}' "$@"
scan "Password/secret/token with a literal value" '(password|passwd|secret|token|api[_-]?key)["'"'"']?[[:space:]]*[=:][[:space:]]*["'"'"']?[A-Za-z0-9/+=_-]{8,}' "$@"
scan "12-digit number (possible AWS account id)" '(^|[^0-9])[0-9]{12}([^0-9]|$)' "$@"
# Private terms: usernames, real names, internal hostnames etc. that must never reach a public repo.
# Keep them in ~/.crew-private-terms (one per line, outside any repository; override with CREW_PRIVATE_TERMS).
TERMS_FILE="${CREW_PRIVATE_TERMS:-$HOME/.crew-private-terms}"
if [ -s "$TERMS_FILE" ]; then
  out=$(grep -rnIiF --exclude-dir=.git --exclude-dir=node_modules -f "$TERMS_FILE" "$@" 2>/dev/null)
  if [ -n "$out" ]; then echo "== Private term from $TERMS_FILE"; echo "$out"; echo; found=1; fi
fi
if [ $found -eq 0 ]; then echo "scan-secrets: no matches"; else echo "scan-secrets: REVIEW the matches above before committing"; fi
exit $found
