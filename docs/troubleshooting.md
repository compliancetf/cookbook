# Read the error before retrying the command

First identify the operation: replaying a file, requesting a public preview,
downloading a module, or planning AWS resources. The same credential cannot fix
every failure, and an HTTP success does not always mean a rule applied.

## A preview error usually needs a different request

| Result | What it means | Next action |
| -------- | --------------- | ------------- |
| `HTTP 429` | The public preview request budget is exhausted | Let the scripts back off; avoid concurrent live runs |
| `PREVIEW_VERSION_NOT_PINNED` | The public route does not accept that version | Use the pinned version in the recipe; do not use `latest` |
| `PREVIEW_PARAM_NOT_ACCEPTED` | The public request includes an unsupported parameter | Remove the parameter; read the response's `remediation` field |
| `PREVIEW_TIER_REQUIRED` | The request selects a feature requiring authentication | Use the appropriate authenticated workflow |
| `RULE_SYNTAX` | The rules selection is missing or invalid | Supply the recipe's explicit `rules=` value |
| `not_configured` with no changed files | The request succeeded, but that rule was not configured | Do not claim enforcement; the region rule in `prevent-destroy-in-module`'s gallery shows this |

You can inspect recorded refusals without calling the API:

```sh
make -C recipes/preview-module-changes refusals
```

The live scripts space calls 11 seconds apart and retry HTTP 429 responses.
`make demo` needs no network access.

## A download error needs the right host and credential format

| Result | Check |
| -------- | ------- |
| `401 Unauthorized` on `terraform init` | Is a token configured for the exact hostname and source format? |
| `403` with `FRAMEWORK_NOT_ENTITLED` | Does the token cover that framework? The free plan serves CIS |
| Registry login works, but a direct HTTPS source fails | Configure `~/.netrc` for the HTTPS download; registry credentials alone do not cover it |

Follow [token setup](auth-setup.md), then run
`scripts/lib/check-auth.sh soc2.compliance.tf` from the repository root.

## A Terraform error may be the result you came to reproduce

`prevent-destroy-in-module` intentionally contains invalid configurations. `make problem`
prints `Reserved block type name in module block` and `Variables not allowed`.
The target tolerates validation failures, so read the errors instead of using
its exit status as proof the configuration is valid.

For `s3-access-logging`, set `TF_VAR_bucket_name` and `TF_VAR_log_bucket_name` before
running the authenticated plans. The S3 module also reads AWS caller identity,
so these plans need AWS credentials even though `terraform plan` does not apply
infrastructure.

If `make scan` is slow, Checkov may be downloading the public module. To read
the existing capture directly:

```sh
cat recipes/s3-access-logging/expected/checkov-before.txt
```

## NOT_CAPTURED means the repository has no result yet

`s3-access-logging` and `compare-framework-hosts` list missing artifacts under
`expected/NOT_CAPTURED.md`.
`make demo-compare-framework-hosts` prints those instructions until framework
modules are captured.
This is an evidence gap, not a successful comparison with an empty diff.

Run the recipe's `make fixtures` only when you want to write new files into
`expected/`. `compare-framework-hosts`' `make live` also writes those files. Read the actual
capture and plan before replacing a missing-result note with a success claim.
