---
title: "Read the diff before you change a module source"
description: "Ask the compliance.tf public preview what two operational rules change in terraform-aws-modules/s3-bucket 5.15.4, and read the HCL diff without an account."
status: published
---

# Read the diff before you change a module source

When you pin `terraform-aws-modules/s3-bucket` 5.15.4, you can check the HCL diff for two rules before you change the module source. The public preview doesn't need an account. compliance.tf calls these named HCL rewrites operational rules. It applies them when it serves a module download. A rule can add a `lifecycle` block, for instance.

## Problem

Your team evaluates modules served by compliance.tf. The first question is what changes in the code you already run. The preview summary says "2 rules applied." The diff shows what settings each bucket resource gets.

## Solution

Request a pinned version and name the rules.

```sh
curl -sS "https://registry.compliance.tf/api/v1/modules/terraform-aws-modules/s3-bucket/aws/5.15.4/rules/preview?rules=lifecycle_prevent_destroy_data,lifecycle_ignore_tags" \
  | jq '{summary, outcomes, files}'
```

The response carries the diff for `main.tf`.

```diff
@@ -54,6 +54,11 @@
   force_destroy       = var.force_destroy
   object_lock_enabled = var.object_lock_enabled
   tags                = var.tags
+
+  lifecycle {
+    prevent_destroy = true
+    ignore_changes = [tags, tags_all]
+  }
 }
 
 resource "aws_s3_directory_bucket" "this" {
@@ -72,6 +77,10 @@
   }
 
   tags = var.tags
+
+  lifecycle {
+    ignore_changes = [tags]
+  }
 }
 
 resource "aws_s3_bucket_logging" "this" {
```

The diff shows `prevent_destroy = true` and `ignore_changes = [tags, tags_all]` on `aws_s3_bucket.this`. It shows `ignore_changes = [tags]` on the directory bucket.

## Run it

```sh
git clone https://github.com/compliancetf/cookbook
cd cookbook/recipes/preview-module-changes
make demo
```

`make demo` replays the capture offline. It uses `make`, `bash`, and `jq`. The summary above the diff reports the outcome for each rule.

```text
Captured 2026-10-07 from the public preview route:
module:   terraform-aws-modules/s3-bucket/aws 5.15.4
rules:    lifecycle_ignore_tags, lifecycle_prevent_destroy_data
applied:  2 of 2 rules, 3 resources, 1 file(s) changed
  lifecycle_ignore_tags: enforced
  lifecycle_prevent_destroy_data: enforced
```

`make live` sends the same request now. It uses `curl` over the network with no account.

The route refuses requests it cannot preview. `make refusals` replays five.

| Request | HTTP | Code |
| --- | --- | --- |
| `&framework=soc2` | 400 | `PREVIEW_PARAM_NOT_ACCEPTED` |
| `&disable=s3_bucket_logging_enabled` | 400 | `PREVIEW_PARAM_NOT_ACCEPTED` |
| Version `latest` | 400 | `PREVIEW_VERSION_NOT_PINNED` |
| `&ruleset=production` | 403 | `PREVIEW_TIER_REQUIRED` |
| No `rules=` | 400 | `RULE_SYNTAX` |

Each refusal has an HTTP error status and a `remediation` field. A successful preview can report zero changed files.

## How it works

The public route previews [operational rules](https://compliance.tf/docs/rules/) against a fixed list of modules at pinned versions. Before you read the diff, use `jq '.outcomes, .summary' expected/preview.json`. Check `outcomes` for one entry per rule. In `summary`, `scope_coverage` reports `module_root_only` for this preview. `submodules_omitted` lists five entries.

## Limits

- The preview returns an HCL diff for review. Module download, Terraform
  planning and rule enforcement happen outside the preview request.
- It previews operational rules only. The route refuses `framework=`, so this
  recipe says nothing about framework controls.
- It covers the module root. The five omitted submodules need their own review.
- If you use the settings shown, Terraform ignores drift in the listed tag
  attributes on each resource. Another system can manage those attributes.
  Decide who owns them first.

Live requests are rate limited. The scripts use a default spacing of 11 seconds. They back off on HTTP 429. The [Rules Playground](https://registry.compliance.tf/playground) shows previews in a browser.

## Files

- [expected/preview.json](expected/preview.json): the captured response
- [expected/refusals/](expected/refusals/): the five captured refusals
- [capture.sh](capture.sh): the requests behind `make fixtures`

## Next steps

- [Set prevent_destroy on a bucket inside a module](../prevent-destroy-in-module/)
- [Rule catalog](https://compliance.tf/docs/rules/catalog/): operational rules and what they change
- [Registry endpoints](https://compliance.tf/docs/features/endpoints/): the source-line forms for downloading a module
