#!/usr/bin/env bash
# Capture one public preview response as a committed fixture.
#
#   capture.sh <out.json> <module> <version> <query>
#
# Drops the fields that change on every call (request_id, timestamp, cache) and
# the full before/after file text, keeps the unified diffs, and records the HTTP
# status as "http_status" so a replay can show refusals exactly as served.
set -euo pipefail

out=${1:?output file}
shift
here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

status_file=$(mktemp)
trap 'rm -f "$status_file"' EXIT

body=$("$here/preview.sh" "$@" 2>"$status_file")
code=$(sed -n 's/^HTTP \([0-9]*\)$/\1/p' "$status_file" | tail -1)

mkdir -p "$(dirname "$out")"
jq -S --argjson code "$code" '
  del(.request_id, .timestamp, .cache)
  | if .files then .files |= map(del(.before, .after)) else . end
  | .http_status = $code
' <<<"$body" >"$out"

echo "captured $out (HTTP $code)"
