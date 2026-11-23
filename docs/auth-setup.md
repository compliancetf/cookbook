# Authenticate the download, not the preview

Replaying a recipe and calling the public preview need no account.
A token enters the workflow when Terraform downloads a module from an
authenticated compliance.tf host.

| Task | Authentication needed |
| ------ | ----------------------- |
| Any recipe: `make demo`, or a public preview call | None |
| `s3-access-logging`: `make live`, `make fixtures` | Token with SOC 2 access; also AWS credentials for the plans |
| `prevent-destroy-in-module`: initialize `with-rules/` | Token in `~/.netrc` for `registry.compliance.tf` |
| `compare-framework-hosts`: capture framework modules | Token covering SOC 2, HIPAA and PCI DSS v4.0; no AWS credentials |

Create a token at [app.compliance.tf/tokens/](https://app.compliance.tf/tokens/).
Check its framework access before running a live target: the free plan serves
CIS, while trial and paid access can cover the framework hosts used here. See
[plans and entitlements](https://compliance.tf/docs/platform/plans-entitlements/)
for current terms.

## Match authentication to the source format

A registry-protocol source looks like this:

```hcl
source = "soc2.compliance.tf/terraform-aws-modules/s3-bucket/aws"
```

Configure credentials for its hostname:

```sh
terraform login soc2.compliance.tf
```

For `compare-framework-hosts`, repeat for `hipaa.compliance.tf` and
`pcidss.compliance.tf`. Terraform credentials are host-specific.

A direct HTTPS source, used by `prevent-destroy-in-module/with-rules/`, looks like this:

```hcl
source = "https://registry.compliance.tf/terraform-aws-modules/s3-bucket/aws?version=5.15.4&rules=lifecycle_prevent_destroy_data"
```

Terraform reads `~/.netrc` for this download format:

```text
machine registry.compliance.tf
    login anything
    password ctf_YOUR_TOKEN_HERE
```

Replace the placeholder locally. `login` can be any value. Restrict the file:

```sh
chmod 600 ~/.netrc
```

A successful `terraform login` does not configure this HTTPS download format.
Keep credentials out of the recipe directories and version control.

## Check access before running the recipe

From the repository root:

```sh
scripts/lib/check-auth.sh soc2.compliance.tf
```

The helper checks `/whoami` and reports the plan tier and entitled frameworks,
or the missing prerequisite. For `compare-framework-hosts`, check all three hosts.

Then return to the recipe. Authentication enables a download; it does
not supply Terraform variables or AWS credentials for a plan. See
[troubleshooting](troubleshooting.md) when a command reaches a different error.

Reference: [Registry Endpoints](https://compliance.tf/docs/features/endpoints/).
