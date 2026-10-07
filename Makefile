TERRAFORM_MODULES := $(patsubst %/versions.tf,%,$(wildcard terraform/modules/*/versions.tf terraform/apps/*/versions.tf))

.PHONY: terraform/fmt
terraform/fmt:
	terraform fmt -check -recursive terraform

.PHONY: terraform/test
terraform/test: $(TERRAFORM_MODULES:%=%/test)

.PHONY: $(TERRAFORM_MODULES:%=%/test)
$(TERRAFORM_MODULES:%=%/test):
	terraform -chdir=$(@D) init -input=false -backend=false
	terraform -chdir=$(@D) validate
	terraform -chdir=$(@D) test

.PHONY: check
check: terraform/fmt terraform/test

VENV := ansible/.venv

$(VENV): ansible/requirements.txt
	python3 -m venv $(VENV)
	$(VENV)/bin/pip install -q -r ansible/requirements.txt
	touch $(VENV)

# One role at a time: `gmake ansible/molecule ROLE=caddy`. Without ROLE, every
# role that has a scenario.
.PHONY: ansible/molecule
ansible/molecule: $(VENV)
	@for role in ansible/roles/$(or $(ROLE),*)/; do \
		[ -d "$$role/molecule" ] || continue; \
		echo "--- molecule: $$role ---"; \
		(cd "$$role" && PATH="$(CURDIR)/$(VENV)/bin:$$PATH" MOLECULE_EPHEMERAL_DIRECTORY="$$PWD/.molecule-ephemeral" molecule test) || exit 1; \
	done

# Compares what manifest.yaml references with Upstream's current head.
.PHONY: drift
drift: $(VENV)
	$(VENV)/bin/python scripts/check_drift.py
