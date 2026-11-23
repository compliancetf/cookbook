#!/usr/bin/env bash
# Fail if a recipe breaks the contract the docs build relies on: frontmatter
# with title, description and status; a published recipe has no missing capture
# and is listed in recipes/README.md.
set -euo pipefail
cd "$(dirname "$0")/.."

fail=0
for dir in recipes/*/; do
  slug=$(basename "$dir")
  readme=$dir/README.md
  field() { sed -n '2,/^---$/p' "$readme" | sed -n "s/^$1: *//p" | head -1 | tr -d '"'; }
  [[ $slug =~ ^[a-z0-9][a-z0-9-]*$ ]] ||
    { echo "$slug: name the directory with lowercase letters, digits and hyphens"; fail=1; }
  [[ $(head -1 "$readme") == --- && -n $(field title) && -n $(field description) ]] ||
    { echo "$slug: README.md needs title and description frontmatter"; fail=1; }
  case $(field status) in
    held) ;;
    published)
      [[ ! -e $dir/expected/NOT_CAPTURED.md ]] ||
        { echo "$slug: published, but expected/NOT_CAPTURED.md exists"; fail=1; }
      grep -qF "]($slug/)" recipes/README.md ||
        { echo "$slug: published, but not linked from recipes/README.md"; fail=1; }
      ;;
    *) echo "$slug: status must be published or held"; fail=1 ;;
  esac
done
[[ $fail -eq 0 ]] && echo "recipes: contract holds ($(find recipes -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ') recipes)"
exit $fail
