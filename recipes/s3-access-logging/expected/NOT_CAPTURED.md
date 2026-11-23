# Not yet captured

These files need a compliance.tf token with SOC 2 access (trial or paid) and AWS
credentials, which the author of this capture did not have. They are not
committed until they come from a real run.

| File | Shows | Command |
|------|-------|---------|
| `plan-after.txt` | `after/` failing on the access-logging control | `make fixtures` |
| `plan-after-fixed.txt` | `after-fixed/` planning cleanly, with resource addresses | `make fixtures` |
| `served-vs-upstream.diff` | What the soc2 host changed in the module | `make fixtures` |

Prerequisites: `terraform login soc2.compliance.tf` (see
[docs/auth-setup.md](../../../docs/auth-setup.md)) and AWS credentials for any
account (plan reads the caller identity; nothing is created).
