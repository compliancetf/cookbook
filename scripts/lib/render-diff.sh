#!/usr/bin/env bash
# Render a preview response (live or a committed fixture) for a terminal.
#
#   render-diff.sh <response.json>
set -euo pipefail

file=${1:?preview response JSON}

jq -r '
  if (.http_status // 200) >= 400 then
    "HTTP \(.http_status)  \(.code // .error_code)\n  \(.message // .error)\n  remediation: \(.remediation // "-")"
  else
    "module:   \(.module.namespace)/\(.module.name)/\(.module.provider) \(.module.version)",
    "rules:    \(.rules.resolved | join(", "))",
    "applied:  \(.summary.rules_applied) of \(.summary.rules_evaluated) rules, \(.summary.resources_affected) resources, \(.summary.files_changed) file(s) changed",
    (.outcomes | to_entries[] | "  \(.key): \(.value.outcome)"),
    "",
    (.files[]? | .unified)
  end
' "$file"
