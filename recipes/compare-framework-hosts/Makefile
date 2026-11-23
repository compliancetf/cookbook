FRAMEWORKS := soc2 hipaa pcidssv321

.PHONY: demo fixtures live

demo: ## Replay the three-way comparison, once captured
	@if [ -d expected/served-soc2 ]; then \
	   for fw in hipaa pcidssv321; do echo "== soc2 vs $$fw"; diff -ru expected/served-soc2 expected/served-$$fw || true; done; \
	 else cat expected/NOT_CAPTURED.md; fi

fixtures: ## Download each framework's served module into expected/. Needs a trial or paid token.
	@for fw in $(FRAMEWORKS); do ../../scripts/lib/check-auth.sh $$fw.compliance.tf || exit 1; done
	@for fw in $(FRAMEWORKS); do (cd $$fw && terraform init -input=false >/dev/null) && \
	   mkdir -p expected/served-$$fw && cp $$fw/.terraform/modules/s3_bucket/*.tf expected/served-$$fw/; done
	date -u +%Y-%m-%d > expected/CAPTURED_AT

live: fixtures demo ## Download and compare now (writes expected/)
