.PHONY: demo scan diff not-captured live fixtures

demo: scan diff not-captured ## Scanner finding, the one-line change, and what it does

scan: ## CKV_AWS_18 on before/ (live if checkov is installed, else the capture)
	@if command -v checkov >/dev/null; then checkov --config-file .checkov.yaml -o cli --quiet --soft-fail 2>/dev/null; \
	 else echo "checkov not installed, replaying expected/checkov-before.txt"; cat expected/checkov-before.txt; fi

diff: ## The whole migration: one line
	@diff -u before/main.tf after/main.tf || true

not-captured:
	@echo; cat expected/NOT_CAPTURED.md

live: ## plan after/ (fails on the control) and after-fixed/ (passes). Needs a token and AWS credentials.
	@../../scripts/lib/check-auth.sh soc2.compliance.tf
	-cd after && terraform init -input=false && terraform plan -input=false
	cd after-fixed && terraform init -input=false && terraform plan -input=false

fixtures: ## Capture the served module and both plans into expected/. Needs a token and AWS credentials.
	@../../scripts/lib/check-auth.sh soc2.compliance.tf
	cd before && terraform init -input=false >/dev/null
	cd after-fixed && terraform init -input=false >/dev/null
	diff -ru -x '.*' -x '*.md' before/.terraform/modules/s3_bucket after-fixed/.terraform/modules/s3_bucket > expected/served-vs-upstream.diff || true
	-cd after && terraform init -input=false >/dev/null && terraform plan -input=false -no-color > ../expected/plan-after.txt 2>&1
	cd after-fixed && terraform plan -input=false -no-color > ../expected/plan-after-fixed.txt 2>&1
	date -u +%Y-%m-%d > expected/CAPTURED_AT
