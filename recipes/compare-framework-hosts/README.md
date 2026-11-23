---
title: "Compare what three framework hosts serve for one module"
description: "Hold the s3-bucket version and caller inputs constant, download the module from the SOC 2, HIPAA and PCI DSS v3.2.1 hosts, and diff the served code."
status: held
---

# Compare what three framework hosts serve for one module

> Held. The served modules are not captured yet, so this recipe is not
> published in the docs. See [expected/NOT_CAPTURED.md](expected/NOT_CAPTURED.md).

## Problem

```diff
-  source  = "soc2.compliance.tf/terraform-aws-modules/s3-bucket/aws"
+  source  = "hipaa.compliance.tf/terraform-aws-modules/s3-bucket/aws"
```

A framework name in a source line says what you requested. It does not say which validations and defaults the downloaded module contains.

## Solution

Keep the module version and the caller inputs identical, download from each host, and diff the code. [soc2/main.tf](soc2/main.tf), [hipaa/main.tf](hipaa/main.tf) and [pcidssv321/main.tf](pcidssv321/main.tf) differ only in the registry host. All three pin s3-bucket 5.15.4.

## Run it

```sh
git clone https://github.com/compliancetf/cookbook
cd cookbook/recipes/compare-framework-hosts
make fixtures
make demo
```

`make fixtures` needs Terraform and a [token covering all three hosts](../../docs/auth-setup.md). It runs `terraform init`, which downloads the modules and applies nothing, then copies each module's root `.tf` files into `expected/served-*`. `make demo` prints SOC 2 against HIPAA and SOC 2 against PCI DSS v3.2.1. Until the capture exists it prints the missing-capture note.

For each changed block, name the argument or resource, the default or validation it adds, and the control it supports. The [control catalog](https://compliance.tf/docs/controls/) has the mapping.

## Limits

- No comparison result is recorded here yet.
- The capture compares root `.tf` files. Submodules are not included.
- `pcidssv321` is PCI DSS v3.2.1 only.
- An empty diff would mean identical root files. It would not mean the
  frameworks have identical requirements.

## Files

- [soc2/](soc2/), [hipaa/](hipaa/), [pcidssv321/](pcidssv321/): one caller per host
- [expected/NOT_CAPTURED.md](expected/NOT_CAPTURED.md): the missing captures and the command for each

## Next steps

- [Registry endpoints](https://compliance.tf/docs/features/endpoints/): the hosts and source-line forms
- [Registry tokens](https://compliance.tf/docs/platform/registry-tokens/): create the token the downloads need
