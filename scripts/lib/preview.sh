#!/usr/bin/env bash
# Call the public, no-auth Rules Preview route of registry.compliance.tf.
#
#   preview.sh <module> <version> <query>
#   preview.sh s3-bucket 5.15.4 'rules=lifecycle_prevent_destroy_data'
#
# Prints the JSON body on stdout and the HTTP status on stderr as "HTTP <code>".
# The route allows about 6 cache misses per minute per IP, so calls are spaced
# PREVIEW_SPACING seconds apart (default 11) and a 429 is retried with backoff.
set -euo pipefail

module=${1:?module name, e.g. s3-bucket}
version=${2:?pinned version, e.g. 5.15.4}
query=${3:?query string, e.g. rules=lifecycle_ignore_tags}

base=${PREVIEW_BASE:-https://registry.compliance.tf/api/v1/modules/terraform-aws-modules}
spacing=${PREVIEW_SPACING:-11}
stamp=${TMPDIR:-/tmp}/compliance-tf-preview.last

# Space calls out across invocations, not only within one.
if [[ -f $stamp ]]; then
  wait=$(( $(cat "$stamp") + spacing - $(date +%s) ))
  (( wait > 0 )) && sleep "$wait"
fi

body=$(mktemp)
trap 'rm -f "$body"' EXIT

for attempt in 1 2 3 4; do
  code=$(curl -sS -o "$body" -w '%{http_code}' "$base/$module/aws/$version/rules/preview?$query")
  date +%s >"$stamp"
  [[ $code != 429 ]] && break
  echo "HTTP 429, retrying in $(( spacing * attempt ))s" >&2
  sleep $(( spacing * attempt ))
done

echo "HTTP $code" >&2
cat "$body"
