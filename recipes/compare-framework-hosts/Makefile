FRAMEWORKS := soc2 hipaa pcidss

.PHONY: demo controls diff fixtures live

demo: controls diff ## The controls each host's module names, then the code diff

controls: ## Control names in each served module, per host
	@for fw in $(FRAMEWORKS); do echo "== $$fw"; grep -ho "Control '[a-z0-9_]*'" expected/served-$$fw/*.tf | sort -u; done

diff: ## soc2 against hipaa and against pcidss
	@for fw in hipaa pcidss; do echo "== soc2 vs $$fw"; diff -ru expected/served-soc2 expected/served-$$fw || true; done

fixtures: ## Download each framework's served module into expected/. Needs a trial or paid token.
	@for fw in $(FRAMEWORKS); do ../../scripts/lib/check-auth.sh $$fw.compliance.tf || exit 1; done
	@for fw in $(FRAMEWORKS); do (cd $$fw && terraform init -input=false >/dev/null) && \
	   mkdir -p expected/served-$$fw && cp $$fw/.terraform/modules/s3_bucket/*.tf expected/served-$$fw/; done
	date -u +%Y-%m-%d > expected/CAPTURED_AT

live: fixtures demo ## Download and compare now (writes expected/)
