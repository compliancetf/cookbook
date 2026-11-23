---
title: "Cookbook"
seo_title: "compliance.tf cookbook for terraform-aws-modules"
description: "Short recipes for terraform-aws-modules users. Each recipe explains a Terraform problem and shows the HCL change. It links to the code and captured output you can replay."
---

# Cookbook

If you use terraform-aws-modules on AWS, pick a recipe by the Terraform error or
the review question you have. Each recipe shows the HCL change and quotes
captured output. You can clone the code and replay the capture.

Several recipes use operational rules: named rewrites compliance.tf applies to a
module's HCL when it serves the download.

## Pick a recipe

| Recipe | Use when | Needs |
| --- | --- | --- |
| [Set prevent_destroy on a bucket inside a module](prevent-destroy-in-module/) | Terraform rejects `lifecycle` on your module call, or a variable in `prevent_destroy` | No account |
| [Read the diff before you change a module source](preview-module-changes/) | You want to review the HCL changes a rule makes to a pinned module version before you adopt it | No account |

## Before you start

```sh
git clone https://github.com/compliancetf/cookbook
cd cookbook/recipes/prevent-destroy-in-module
make demo
```

`make demo` replays captured output. It needs `make`, `bash` and `jq`, and no
account, token, AWS credentials or network. In the same directory, `make live`
runs the recipe against the live service. The recipe lists what that needs.

A recipe appears here once its quoted output has been captured from a real run.
The recipe stores the output and capture date in `expected/`. Its "Limits"
section describes the scope of the capture.

## Not what you need

- One complete application stack built from these modules: the
  [end-to-end demo](https://github.com/compliancetf/demo).
- Operational rules and what they change: the
  [Rule catalog](https://compliance.tf/docs/rules/catalog/).
- The source-line forms for downloading a module:
  [Registry endpoints](https://compliance.tf/docs/features/endpoints/).
