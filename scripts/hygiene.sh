#!/usr/bin/env bash
# Fail if the tree carries something that must never be published: AWS account
# ids, personal emails, or credential-shaped strings. Documented example values
# go in .hygiene-allowlist (one fixed string per line).
set -euo pipefail
cd "$(dirname "$0")/.."

patterns=(
  '\b[0-9]{12}\b'                                        # AWS account id
  '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}'       # email
  'atlasv1\.[A-Za-z0-9]+'                                # Terraform Cloud token
  '\bctf_[A-Za-z0-9]{16,}'                               # compliance.tf token
  '\bgh[pousr]_[A-Za-z0-9]{20,}|github_pat_[A-Za-z0-9_]{20,}'
  '\b(AKIA|ASIA|AROA|AIDA)[0-9A-Z]{16}\b'                # AWS key / role / user id
  'aws_secret_access_key\s*=\s*[A-Za-z0-9/+=]{40}'
  '-----BEGIN [A-Z ]*PRIVATE KEY-----'
  '^\s*password\s+\S+'                                   # .netrc line
)

allow=$(mktemp)
trap 'rm -f "$allow"' EXIT
grep -v '^#' .hygiene-allowlist 2>/dev/null | sed '/^$/d' >"$allow" || true

hits=$(git ls-files -z | xargs -0 grep -nIE "$(IFS='|'; echo "${patterns[*]}")" -- 2>/dev/null \
  | grep -vFf "$allow" | grep -v '^scripts/hygiene.sh:' || true)

if [[ -n $hits ]]; then
  echo "Hygiene check failed. Remove these, or allowlist a documented example:" >&2
  echo "$hits" >&2
  exit 1
fi
echo "hygiene: clean ($(git ls-files | wc -l) tracked files)"
