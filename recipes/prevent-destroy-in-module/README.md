---
title: "Set prevent_destroy on a bucket inside a module"
description: "Terraform rejects lifecycle on a module call and variables in prevent_destroy. See both errors and the preview diff of the lifecycle block a compliance.tf rule adds to the s3-bucket module."
status: published
---

# Set prevent_destroy on a bucket inside a module

You want Terraform to reject any plan that destroys a bucket created by
`terraform-aws-modules/s3-bucket`. Terraform rejects `lifecycle` on a module
call and rejects a variable in `prevent_destroy`, so you cannot set it from
outside the module. This recipe replays both errors and shows the preview diff
of the operational rule that adds `prevent_destroy = true` to the bucket
resource. An operational rule is a named rewrite compliance.tf applies to a
module's HCL when it serves the download. Replaying needs no account.

## Problem

Adding `lifecycle` to the module call fails:

```hcl
module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "5.15.4"

  bucket = "example"

  lifecycle {
    prevent_destroy = true
  }
}
```

```text
Error: Reserved block type name in module block

  on main.tf line 9, in module "s3_bucket":
   9:   lifecycle {
```

Terraform also rejects a variable as the value of `prevent_destroy`. A fork that
takes the value as an input fails the same way:

```hcl
resource "terraform_data" "bucket" {
  lifecycle {
    prevent_destroy = var.prevent_destroy
  }
}
```

```text
Error: Variables not allowed

  on main.tf line 11, in resource "terraform_data" "bucket":
  11:     prevent_destroy = var.prevent_destroy
```

A wrapper that puts `lifecycle` on the upstream module call hits the first
error. A fork has to hard-code the value.

## Solution

Request the `lifecycle_prevent_destroy_data` rule on the module source:

```hcl
module "s3_bucket" {
  source = "https://registry.compliance.tf/terraform-aws-modules/s3-bucket/aws?version=5.15.4&rules=lifecycle_prevent_destroy_data"

  bucket = var.bucket_name
}
```

For that rule on s3-bucket 5.15.4, the public preview returns this change to
`aws_s3_bucket.this` in `main.tf` (captured 2026-10-07):

```diff
   force_destroy       = var.force_destroy
   object_lock_enabled = var.object_lock_enabled
   tags                = var.tags
+
+  lifecycle {
+    prevent_destroy = true
+  }
 }
```

The preview diff adds one `lifecycle` block with a literal `true` and no
variables. The module source line shows the rule during code review.

Downloading from that source needs a [registry token](../../docs/auth-setup.md).
This recipe captures the preview and stops before the download.

## Run it

```sh
git clone https://github.com/compliancetf/cookbook
cd cookbook/recipes/prevent-destroy-in-module
make demo
```

`make demo` replays the captures with `make`, `bash` and `jq`. It makes no
network calls. After the two errors, the first rule preview starts with:

```text
module:   terraform-aws-modules/s3-bucket/aws 5.15.4
rules:    lifecycle_prevent_destroy_data
applied:  1 of 1 rules, 1 resources, 1 file(s) changed
  lifecycle_prevent_destroy_data: enforced
```

| Command | Needs | Shows |
| --- | --- | --- |
| `make problem` | Terraform, network to the public registry | Both errors from your own Terraform |
| `make live` | `curl`, network, no account | The same previews requested now |
| `make gallery` | nothing extra | The five rule previews without the errors. One needs parameters and answers `not_configured` |

## How it works

Terraform reads `lifecycle` while it builds the dependency graph, before it can
evaluate expressions. The value has to be a literal inside the resource. See the
[lifecycle reference](https://developer.hashicorp.com/terraform/language/meta-arguments/lifecycle)
and [hashicorp/terraform#3116](https://github.com/hashicorp/terraform/issues/3116).

compliance.tf applies [operational rules](https://compliance.tf/docs/rules/) to
the module's HCL when it serves the download. The public preview route returns
that rewrite as a diff, which is what this recipe captures.

## Limits

- Captured here: both errors (Terraform 1.16.3) and the preview diff, on
  2026-10-07. No download, plan or destroy attempt is captured.
- `prevent_destroy` is a plan-time guard. It rejects destroy and replace plans
  while the resource is in your configuration. It does not stop deletion in the
  AWS console, or after the module block is removed.
- The preview covers the module root. It lists five omitted submodules under
  `summary.submodules_omitted`.

## Files

- [problem/](problem/): the two configurations Terraform rejects
- [expected/](expected/): captured errors and preview responses
- [with-rules/main.tf](with-rules/main.tf): the caller with the rule on its source line
- [gallery.txt](gallery.txt): rules and pinned versions behind `make gallery`

## Next steps

- [Registry tokens](https://compliance.tf/docs/platform/registry-tokens/): create the token the download needs
- [Rule catalog](https://compliance.tf/docs/rules/catalog/): operational rules and what they change
- [Rulesets in the console](https://compliance.tf/docs/platform/rulesets/): apply rules to an organization's downloads without a query string
- [Read the diff before you change a module source](../preview-module-changes/)
