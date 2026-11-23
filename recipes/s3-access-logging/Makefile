.PHONY: demo scan diff plans live fixtures

demo: scan diff plans ## Scanner finding, the source change, and both captured plans

scan: ## CKV_AWS_18 on before/ (live if checkov is installed, else the capture)
	@if command -v checkov >/dev/null; then checkov --config-file .checkov.yaml -o cli --quiet --soft-fail 2>/dev/null; \
	 else echo "checkov not installed, replaying expected/checkov-before.txt"; cat expected/checkov-before.txt; fi

diff: ## The source change, then the inputs the plan errors ask for
	@diff -u before/main.tf after/main.tf || true
	@diff -u after/main.tf after-fixed/main.tf || true

plans: ## Replay the captured plans: after/ fails, after-fixed/ plans
	@echo "== after/ (captured $$(cat expected/CAPTURED_AT))"; grep -A3 "^Control '" expected/plan-after.txt
	@echo; echo "== after-fixed/"; grep -E '^  # |^Plan:' expected/plan-after-fixed.txt

live: ## plan after/ (fails on the control) and after-fixed/ (passes). Needs a token and AWS credentials.
	@../../scripts/lib/check-auth.sh soc2.compliance.tf
	-cd after && terraform init -input=false && terraform plan -input=false
	cd after-fixed && terraform init -input=false && terraform plan -input=false

fixtures: ## Capture the served module and both plans into expected/. Needs a token and AWS credentials.
	@../../scripts/lib/check-auth.sh soc2.compliance.tf
	cd before && terraform init -input=false >/dev/null
	cd after-fixed && terraform init -input=false >/dev/null
	diff -ru -x '.*' -x '*.md' -x examples before/.terraform/modules/s3_bucket after-fixed/.terraform/modules/s3_bucket > expected/served-vs-upstream.diff || true
	-cd after && terraform init -input=false >/dev/null && terraform plan -input=false -no-color > ../expected/plan-after.txt 2>&1
	cd after-fixed && terraform plan -input=false -no-color > ../expected/plan-after-fixed.txt 2>&1
	@# The caller identity is printed in the plan; replace the account id with the AWS documentation one.
	perl -pi -e 's/\b\d{12}\b/111122223333/g' expected/plan-after.txt expected/plan-after-fixed.txt
	date -u +%Y-%m-%d > expected/CAPTURED_AT
