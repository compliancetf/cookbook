---
title: "Require S3 access logging through the module source"
description: "A Checkov finding shows a versioned bucket without access logging. Change the module source to the SOC 2 host, supply logging inputs, and review the plan."
status: held
---

# Require S3 access logging through the module source

> Held. The plans that prove the solution are not captured yet, so this recipe
> is not published in the docs. See
> [expected/NOT_CAPTURED.md](expected/NOT_CAPTURED.md).

## Problem

A scan of a versioned bucket from `terraform-aws-modules/s3-bucket` 5.15.4:

```text
Check: CKV_AWS_18: "Ensure the S3 bucket has access logging enabled"
	FAILED for resource: module.s3_bucket.aws_s3_bucket.this[0]
```

Versioning does not configure access logging. You can add logging to this one
bucket. The harder question is how the next caller of the module is required to
do the same.

## Solution

Change the source line and keep the version:

```diff
 module "s3_bucket" {
-  source  = "terraform-aws-modules/s3-bucket/aws"
+  source  = "soc2.compliance.tf/terraform-aws-modules/s3-bucket/aws"
   version = "5.15.4"
```

Then supply the logging inputs, as in [after-fixed/main.tf](after-fixed/main.tf):

```hcl
logging = {
  target_bucket = var.log_bucket_name
  target_prefix = "s3-access-logs/"
}
```

The expected result is a plan error for `after/` and a plan without that error
for `after-fixed/`. Neither plan is captured here.

## Run it

```sh
git clone https://github.com/compliancetf/cookbook
cd cookbook/recipes/s3-access-logging
make demo
```

`make demo` shows the finding and the source diff. It runs Checkov if installed
and replays [expected/checkov-before.txt](expected/checkov-before.txt)
(Checkov 3.3.20, captured 2026-09-28) otherwise.

`make live` plans `after/` and `after-fixed/`. It needs Terraform, a
[token with SOC 2 access](../../docs/auth-setup.md), AWS credentials, and
`TF_VAR_bucket_name` and `TF_VAR_log_bucket_name`. It applies nothing.
`make fixtures` writes the same results into `expected/`.

## Limits

- The capture proves the finding. The remediation needs the two plans.
- One logging control is one control. It is not a SOC 2 audit result.
- A logging block does not show that logs arrive. Review the target bucket and
  its permissions separately.

## Files

- [before/](before/), [after/](after/), [after-fixed/](after-fixed/): the three caller configurations
- [.checkov.yaml](.checkov.yaml): scopes the scan to CKV_AWS_18
- [expected/](expected/): the captured finding and the list of missing captures

## Next steps

- [Registry endpoints](https://compliance.tf/docs/features/endpoints/): the source-line forms for downloading a module
- [Registry tokens](https://compliance.tf/docs/platform/registry-tokens/): create the token the download needs
