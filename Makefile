RECIPES := $(sort $(dir $(wildcard recipes/*/Makefile)))

.PHONY: help demo-all check hygiene fmt recipes fixtures-public

help:
	@echo "make demo-<recipe>     replay one recipe, e.g. make demo-prevent-destroy-in-module"
	@echo "make demo-all          replay every recipe"
	@echo "make check             fmt + hygiene + recipe contract (what CI runs)"
	@echo "make fixtures-public   recapture the recipes that use the public preview route"

demo-%:
	@$(MAKE) --no-print-directory -C recipes/$* demo

demo-all:
	@for r in $(RECIPES); do echo "######## $$r"; $(MAKE) --no-print-directory -C $$r demo; echo; done

fmt:
	terraform fmt -check -recursive recipes

hygiene:
	@scripts/hygiene.sh

recipes:
	@scripts/check-recipes.sh

check: fmt hygiene recipes

fixtures-public:
	$(MAKE) -C recipes/preview-module-changes fixtures
	$(MAKE) -C recipes/prevent-destroy-in-module fixtures
