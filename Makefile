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
