#!/usr/bin/env bash
# Preflight for recipes that need a compliance.tf token. Prints the plan tier
# and entitled frameworks, so an auth problem reads as an auth problem instead
# of a broken demo.
#
#   check-auth.sh soc2.compliance.tf
#
# Token lookup order: $TF_REGISTRY_TOKEN, then the credentials file written by
# `terraform login <host>`, then a ~/.netrc entry for the host. With none of
# them it warns and defers to terraform's own credentials lookup.
set -euo pipefail

host=${1:?registry host, e.g. soc2.compliance.tf}
token=${TF_REGISTRY_TOKEN:-}

creds=${TF_CLI_CONFIG_DIR:-$HOME/.terraform.d}/credentials.tfrc.json
if [[ -z $token && -f $creds ]]; then
  token=$(jq -r --arg h "$host" '.credentials[$h].token // empty' "$creds")
fi
if [[ -z $token && -f $HOME/.netrc ]]; then
  token=$(awk -v h="$host" '$1 == "machine" && $2 == h { f = 1 } f && $1 == "password" { print $2; exit }' "$HOME/.netrc")
fi

if [[ -z $token ]]; then
  # Terraform may still have one (a credentials block in the CLI config, a
  # TF_TOKEN_* variable); terraform init reports it if not.
  echo "$host: no token found here, leaving it to terraform (see docs/auth-setup.md)" >&2
  exit 0
fi

body=$(curl -sS -H "Authorization: Bearer $token" "https://$host/whoami")
if ! jq -e '.tier' >/dev/null 2>&1 <<<"$body"; then
  echo "$host rejected the token: $body" >&2
  exit 1
fi

jq -r --arg h "$host" '"\($h): tier \(.tier), frameworks: \(.frameworks | join(", "))"' <<<"$body"

# Host slugs drop the underscores of framework ids (soc2 serves soc_2, hipaa
# serves hipaa_*, pcidss serves pci_dss_*).
framework=${host%%.*}
if [[ $framework != registry ]] && ! jq -e --arg f "$framework" 'any(.frameworks[]; gsub("_"; "") | startswith($f))' >/dev/null <<<"$body"; then
  echo "Your plan does not include $framework. The free plan serves CIS only; a trial covers every framework." >&2
  exit 1
fi
