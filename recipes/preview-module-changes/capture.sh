#!/usr/bin/env bash
# Regenerate $out/ from the live public preview route. No token needed.
# Calls are spaced about 11s apart to stay under the route's rate limit.
set -euo pipefail
cd "$(dirname "$0")"
cap=../../scripts/lib/capture.sh
out=${EXPECTED:-expected}

$cap "$out/preview.json" s3-bucket 5.15.4 'rules=lifecycle_prevent_destroy_data,lifecycle_ignore_tags'

# Each refusal: the parameter the public route will not accept, and why.
$cap "$out/refusals/framework.json" s3-bucket 5.15.4 'rules=lifecycle_ignore_tags&framework=soc2'
$cap "$out/refusals/disable.json"   s3-bucket 5.15.4 'rules=lifecycle_ignore_tags&disable=s3_bucket_logging_enabled'
$cap "$out/refusals/latest.json"    s3-bucket latest 'rules=lifecycle_ignore_tags'
$cap "$out/refusals/ruleset.json"   s3-bucket 5.15.4 'rules=lifecycle_ignore_tags&ruleset=production'
$cap "$out/refusals/no-rules.json"  s3-bucket 5.15.4 'enable_tags=true'

date -u +%Y-%m-%d >"$out/CAPTURED_AT"
