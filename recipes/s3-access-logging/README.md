---
title: "Require S3 access logging through the module source"
description: "A Checkov finding shows a versioned bucket without access logging. Change the module source to the SOC 2 host, read the four plan errors, and supply the inputs that make the plan pass."
status: published
---

# Require S3 access logging through the module source

## Problem

A scan of a versioned bucket from `terraform-aws-modules/s3-bucket` 5.15.4:

```text
Check: CKV_AWS_18: "Ensure the S3 bucket has access logging enabled"
	FAILED for resource: module.s3_bucket.aws_s3_bucket.this[0]
```

Versioning does not configure access logging. You can add logging to this
bucket's inputs. To require it from every caller of the module, change where
the module comes from.

## Solution

Change the source line and keep the version:

```diff
 module "s3_bucket" {
-  source  = "terraform-aws-modules/s3-bucket/aws"
+  source  = "soc2.compliance.tf/terraform-aws-modules/s3-bucket/aws"
   version = "5.15.4"
```

`terraform plan` on [after/](after/) now fails. The plan reports four unmet
SOC 2 controls, access logging among them. The control message from each error:

```text
Control 's3_bucket_cross_region_replication_enabled': S3 bucket replication
rule must have status Enabled: aws_s3_bucket_replication_configuration.this
is not created with these inputs

Control 's3_bucket_default_encryption_enabled_kms': S3 bucket encryption must
use aws:kms or aws:kms:dsse:
aws_s3_bucket_server_side_encryption_configuration.this is not created with
these inputs

Control 's3_bucket_logging_enabled': S3 bucket access logging is required:
configure logging with a valid target bucket: aws_s3_bucket_logging.this is
not created with these inputs

Control 's3_bucket_versioning_and_lifecycle_policy_enabled': S3 bucket
lifecycle rule must have status Enabled (requires versioning to be
configured): aws_s3_bucket_lifecycle_configuration.this is not created with
these inputs
```

[after-fixed/main.tf](after-fixed/main.tf) supplies one input block per
control. The logging block addresses CKV_AWS_18:

```hcl
logging = {
  target_bucket = var.log_bucket_name
  target_prefix = "s3-access-logs/"
}
```

With only those four blocks, the next plan fails on two more checks:
`s3_bucket_default_encryption_enabled_kms` also requires a `kms_master_key_id`,
and `s3_bucket_mfa_delete_enabled` requires `mfa_delete = true` in `versioning`.
`after-fixed/` sets both. Its plan passes; the resource lines and summary:

```text
  # module.s3_bucket.aws_s3_bucket.this[0] will be created
  # module.s3_bucket.aws_s3_bucket_lifecycle_configuration.this[0] will be created
  # module.s3_bucket.aws_s3_bucket_logging.this[0] will be created
  # module.s3_bucket.aws_s3_bucket_public_access_block.this[0] will be created
  # module.s3_bucket.aws_s3_bucket_replication_configuration.this[0] will be created
  # module.s3_bucket.aws_s3_bucket_server_side_encryption_configuration.this[0] will be created
  # module.s3_bucket.aws_s3_bucket_versioning.this[0] will be created
Plan: 7 to add, 0 to change, 0 to destroy.
```

## Run it

```sh
git clone https://github.com/compliancetf/cookbook
cd cookbook/recipes/s3-access-logging
make demo
```

`make demo` shows the finding, the two source diffs and both plans. It runs
Checkov if installed and replays
[expected/checkov-before.txt](expected/checkov-before.txt) (Checkov 3.3.20,
captured 2026-09-28) otherwise. The plans replay
[expected/plan-after.txt](expected/plan-after.txt) and
[expected/plan-after-fixed.txt](expected/plan-after-fixed.txt), captured on the
date in [expected/CAPTURED_AT](expected/CAPTURED_AT).

`make live` plans `after/` and `after-fixed/` now. It needs Terraform, a
[token with SOC 2 access](../../docs/auth-setup.md) and AWS credentials for any
account: the module reads the caller identity, and nothing is created.
`make fixtures` writes the same results into `expected/` and replaces the
account id in them with `111122223333`.

## How it works

The SOC 2 host serves the same module version with Terraform preconditions and
postconditions added. A control can have several checks. The four errors above
are preconditions: they stop the plan, before anything is created, while the
inputs they check are missing. See
[expected/served-vs-upstream.diff](expected/served-vs-upstream.diff) for the
changes the host made to the module's code. The diff leaves out examples,
Markdown and dotfiles.

## Limits

- The variables in [after-fixed/variables.tf](after-fixed/variables.tf) are
  placeholders. The plan does not check that the log bucket, KMS key,
  replication role or replica bucket exist. Replace them before you apply.
- AWS sets `mfa_delete` only with the root user's credentials and MFA device.
  An apply with any other identity fails on that input.
- A logging block does not show that logs arrive. Review the target bucket and
  its permissions separately.
- Passing the SOC 2 controls in the plan is not a SOC 2 audit result.

## Files

- [before/](before/), [after/](after/), [after-fixed/](after-fixed/): the three caller configurations
- [.checkov.yaml](.checkov.yaml): scopes the scan to CKV_AWS_18
- [expected/](expected/): the captured finding, both plans and the served-module diff

## Next steps

- [Registry endpoints](https://compliance.tf/docs/features/endpoints/): the source-line forms for downloading a module
- [Registry tokens](https://compliance.tf/docs/platform/registry-tokens/): create the token the download needs
- [Compare what three framework hosts serve for one module](../compare-framework-hosts/): the same module version from the SOC 2, HIPAA and PCI DSS hosts
