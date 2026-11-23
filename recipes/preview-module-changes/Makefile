LIB := ../../scripts/lib
QUERY := rules=lifecycle_prevent_destroy_data,lifecycle_ignore_tags

.PHONY: demo refusals live live-refusals fixtures

demo: ## Replay the captured preview (no network)
	@echo "Captured $$(cat expected/CAPTURED_AT) from the public preview route:"; echo
	@$(LIB)/render-diff.sh expected/preview.json

refusals: ## Replay the captured refusals (no network)
	@for f in expected/refusals/*.json; do echo "== $$(basename $$f .json)"; $(LIB)/render-diff.sh $$f; echo; done

live: ## Same call, live (curl + jq, no account)
	@tmp=$$(mktemp) && $(LIB)/capture.sh $$tmp s3-bucket 5.15.4 '$(QUERY)' >/dev/null && $(LIB)/render-diff.sh $$tmp; rm -f $$tmp

live-refusals: ## Refusals, live (about 1 minute: calls are spaced out)
	@tmp=$$(mktemp -d) && EXPECTED=$$tmp ./capture.sh >/dev/null && for f in $$tmp/refusals/*.json; do echo "== $$(basename $$f .json)"; $(LIB)/render-diff.sh $$f; echo; done; rm -rf $$tmp

fixtures: ## Regenerate expected/ from the live route
	./capture.sh
