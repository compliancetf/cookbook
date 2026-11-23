# compliance.tf cookbook

Here are short recipes. They are for people who run terraform-aws-modules. Each recipe states one problem. Then it shows the change that solves it with [compliance.tf](https://compliance.tf). The code and the captured output from a real run live in one directory.

The same recipes live at [compliance.tf/docs/cookbook/](https://compliance.tf/docs/cookbook/). For a full application stack, look at the [end-to-end demo](https://github.com/compliancetf/demo).

## Recipes

| Recipe | Problem it solves | Needs |
| --- | --- | --- |
| [Set prevent_destroy on a bucket inside a module](recipes/prevent-destroy-in-module/) | Terraform rejects `lifecycle` on a module call and variables in `prevent_destroy` | No account |
| [Read the diff before you change a module source](recipes/preview-module-changes/) | You want to review the HCL changes a rule makes to a pinned module version before you adopt it | No account |
| [Require S3 access logging through the module source](recipes/s3-access-logging/) | A scanner flags a bucket without access logging, and the next caller of the module should not be able to skip it | No account to replay; a SOC 2 token and AWS credentials to run live |
| [Compare what three framework hosts serve for one module](recipes/compare-framework-hosts/) | You need to know which checks a module gets from the SOC 2, HIPAA and PCI DSS hosts | No account to replay; a token for all three hosts to run live |

## Run a recipe

```sh
git clone https://github.com/compliancetf/cookbook
cd cookbook/recipes/prevent-destroy-in-module
make demo
```

Every recipe has three targets. They are the same for all:

| Target | What it does |
| --- | --- |
| `make demo` | Replays captured output. No account, token, AWS credentials or network |
| `make live` | Makes the real calls. Requirements are listed in the recipe |
| `make fixtures` | Writes new captures into `expected/` |

From the repository root, run `make demo-<recipe>` to run one recipe. Run `make demo-all` to run all of them.

To run `make demo`, you need `make`, `bash`, and `jq`. For live preview calls, add `curl`. Live plans need Terraform >= 1.5.7 and a registry token. See [token setup](docs/auth-setup.md) and [troubleshooting](docs/troubleshooting.md).

## How a recipe is built

```
recipes/<task-slug>/
  README.md    the recipe, and the source of its docs page
  Makefile     demo, live, fixtures
  expected/    captured output from real runs, with the capture date
  ...          the Terraform the recipe talks about
```

The `README.md` file starts with frontmatter: `title`, `description`, and `status`. Then it follows these sections in order: Problem, Solution, Run it, How it works, Limits, Files, Next steps. When `status` is `published`, the solution is captured and the docs site imports the page. When `status` is `held`, the recipe stays here only. The `make check` command fails for a published recipe that still has `expected/NOT_CAPTURED.md`.

Files under `expected/` come from real runs. The preview scripts wait 11 seconds between live requests. They back off on HTTP 429.

## License

Apache 2.0. See [LICENSE](LICENSE).
