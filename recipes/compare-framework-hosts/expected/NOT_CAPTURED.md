# Not yet captured

This recipe compares what three framework hosts serve for the same module.
Nothing is committed until it comes from a real run with a token that covers all
three frameworks (trial or paid).

| File | Shows | Command |
|------|-------|---------|
| `served-soc2/` | s3-bucket 5.15.4 as served by soc2.compliance.tf | `make fixtures` |
| `served-hipaa/` | the same module from hipaa.compliance.tf | `make fixtures` |
| `served-pcidssv321/` | the same module from pcidssv321.compliance.tf | `make fixtures` |

After capture, `make demo` prints soc2 vs hipaa and soc2 vs pcidssv321.
