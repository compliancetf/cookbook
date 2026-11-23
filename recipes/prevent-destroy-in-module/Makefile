LIB := ../../scripts/lib

.PHONY: demo problem gallery live fixtures

demo: ## The problem, then the rule gallery (no network)
	@$(MAKE) --no-print-directory problem-replay gallery

problem-replay:
	@for f in expected/problem-*.txt; do echo "== $$f"; cat $$f; echo; done

problem: ## Reproduce both errors with your own Terraform (public registry only)
	@for d in problem/module-lifecycle problem/variable-lifecycle; do \
	  echo "== $$d"; (cd $$d && terraform init -backend=false -input=false >/dev/null 2>&1; terraform validate -no-color) || true; echo; done

gallery: ## One served diff per rule, from the captured public preview
	@echo "Captured $$(cat expected/CAPTURED_AT) from the public preview route."; echo
	@grep -v '^#' gallery.txt | while read -r rule module version; do \
	  [ -z "$$rule" ] && continue; echo "==================== $$rule on $$module $$version"; \
	  $(LIB)/render-diff.sh expected/gallery/$$rule.json; echo; done

live: ## Re-run the gallery against the live route (about 1 minute)
	@tmp=$$(mktemp -d) && EXPECTED=$$tmp ./capture.sh >/dev/null && \
	  for f in $$tmp/gallery/*.json; do $(LIB)/render-diff.sh $$f; echo; done; rm -rf $$tmp

fixtures: ## Regenerate expected/ (gallery from the live route, problem outputs locally)
	./capture.sh
	@for d in module-lifecycle variable-lifecycle; do (cd problem/$$d && terraform init -backend=false -input=false >/dev/null 2>&1; \
	  { echo "# terraform validate, Terraform $$(terraform version -json | jq -r .terraform_version), captured $$(date -u +%Y-%m-%d)"; \
	    terraform validate -no-color 2>&1 || true; } > ../../expected/problem-$$d.txt); done
