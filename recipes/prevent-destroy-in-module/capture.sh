#!/usr/bin/env bash
# Regenerate the rule gallery in expected/gallery/ from the live public preview
# route, one call per line of gallery.txt. No token needed. Calls are spaced
# about 11s apart to stay under the route's rate limit.
set -euo pipefail
cd "$(dirname "$0")"
out=${EXPECTED:-expected}

grep -v '^#' gallery.txt | while read -r rule module version; do
  [[ -z $rule ]] && continue
  ../../scripts/lib/capture.sh "$out/gallery/$rule.json" "$module" "$version" "rules=$rule"
done

date -u +%Y-%m-%d >"$out/CAPTURED_AT"
