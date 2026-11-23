---
title: "Compare what three framework hosts serve for one module"
description: "Hold the s3-bucket version and caller inputs constant, download the module from the SOC 2, HIPAA and PCI DSS v4.0 hosts, and compare the controls and code each one serves."
status: published
---

# Compare what three framework hosts serve for one module

## Problem

```diff
-  source  = "soc2.compliance.tf/terraform-aws-modules/s3-bucket/aws"
+  source  = "hipaa.compliance.tf/terraform-aws-modules/s3-bucket/aws"
```

The source line names the framework you requested. It does not show which
checks the downloaded module contains, or what changes when you switch a
bucket to another framework's host.

## Solution

Keep the module version and the caller inputs identical, download from each
host, and compare what was served. [soc2/main.tf](soc2/main.tf),
[hipaa/main.tf](hipaa/main.tf) and [pcidss/main.tf](pcidss/main.tf) differ only
in the registry host. All three pin s3-bucket 5.15.4.

Each check in a served module names its control, so `make controls` lists them
per host. From the capture:

| Control | soc2 | hipaa | pcidss |
| --- | --- | --- | --- |
| `s3_bucket_cross_region_replication_enabled` | yes | yes | yes |
| `s3_bucket_default_encryption_enabled_kms` | yes | yes | yes |
| `s3_bucket_logging_enabled` | yes | yes | yes |
| `s3_bucket_object_lock_enabled` | yes | yes | yes |
| `s3_bucket_versioning_enabled` | yes | yes | yes |
| `s3_public_access_block_bucket` | yes | yes | yes |
| `s3_bucket_mfa_delete_enabled` | yes | no | yes |
| `s3_bucket_versioning_and_lifecycle_policy_enabled` | yes | no | yes |
| `s3_bucket_static_website_hosting_disabled` | yes | no | no |
| `s3_bucket_not_accessible_to_all_authenticated_user` | yes | yes | no |
| `s3_bucket_acls_should_prohibit_user_access` | no | no | yes |
| `s3_bucket_policy_restricts_cross_account_permission_changes` | no | no | yes |

The hipaa module names three fewer controls than the soc2 module. Against soc2,
the pcidss module adds the bucket policy guard, drops the website hosting check,
and checks object ownership under another control name. Both ownership controls
require `BucketOwnerEnforced`. The two control messages from the soc2-to-pcidss
diff:

```diff
-Control 's3_bucket_not_accessible_to_all_authenticated_user': S3 bucket must use BucketOwnerEnforced ownership to prevent AuthenticatedUsers access.
+Control 's3_bucket_acls_should_prohibit_user_access': S3 bucket must use BucketOwnerEnforced ownership to disable ACLs and prohibit user access
```

## Run it

```sh
git clone https://github.com/compliancetf/cookbook
cd cookbook/recipes/compare-framework-hosts
make demo
```

`make demo` replays the capture in `expected/served-*`, taken on the date in
[expected/CAPTURED_AT](expected/CAPTURED_AT). It prints the controls per host,
then the code diff of soc2 against hipaa and of soc2 against pcidss. It needs no
account or network.

`make live` downloads the three modules again and compares them. It needs
Terraform and a [token covering all three hosts](../../docs/auth-setup.md) on a
trial or paid plan. It runs `terraform init`, which downloads the modules and
applies nothing, then copies each module's root `.tf` files into
`expected/served-*`.

## Limits

- The table lists checks in this module at this version. Another module, or
  another s3-bucket version, can serve a different set.
- The capture compares root `.tf` files. Submodules, such as the bucket policy
  guard the pcidss module calls, are not included.
- `pcidss` serves PCI DSS v4.0. PCI DSS v3.2.1 has its own host, `pcidssv321`.
- A control the module does not check can still be in the framework. Some
  controls are met outside the module. The
  [control catalog](https://compliance.tf/docs/controls/) maps each control to
  framework clauses.

## Files

- [soc2/](soc2/), [hipaa/](hipaa/), [pcidss/](pcidss/): one caller per host
- [expected/](expected/): the root `.tf` files each host served, and the capture date

## Next steps

- [Require S3 access logging through the module source](../s3-access-logging/): plan a bucket against the soc2 host and fix each error
- [Registry endpoints](https://compliance.tf/docs/features/endpoints/): the hosts and source-line forms
- [Registry tokens](https://compliance.tf/docs/platform/registry-tokens/): create the token the downloads need
