SHELL := /bin/bash

CLOUDFLARE_EMAIL := ${CLOUDFLARE_EMAIL}
CLOUDFLARE_TOKEN := ${CLOUDFLARE_TOKEN}

RECORD_DOMAIN := ${RECORD_DOMAIN}
RECORD_NAME := ${RECORD_NAME}
RECORD_VALUE := ${RECORD_VALUE}
RECORD_TYPE := ${RECORD_TYPE}
RECORD_TTL ?= 1

ZONEID := $(shell curl -s -X GET "https://api.cloudflare.com/client/v4/zones?name=$(RECORD_DOMAIN)&status=active&page=1&per_page=20&order=status&direction=desc&match=all" -H "X-Auth-Email: $(CLOUDFLARE_EMAIL)" -H "X-Auth-Key: $(CLOUDFLARE_TOKEN)" -H "Content-Type: application/json" | jq -r '.result[].id')
RECORD_ID := $(shell curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$(ZONEID)/dns_records?name=$(RECORD_NAME).$(RECORD_DOMAIN)&page=1&per_page=20&order=type&direction=desc&match=all" -H "X-Auth-Email: $(CLOUDFLARE_EMAIL)" -H "X-Auth-Key: $(CLOUDFLARE_TOKEN)" -H "Content-Type: application/json"| jq -r '.result[].id')

CF_DIR=$(CURDIR)/terraform/cloudflare
TERRAFORM_FLAGS :=
CF_TERRAFORM_FLAGS = -var "cloudflare_email=$(CLOUDFLARE_EMAIL)" \
		-var "cloudflare_email=$(CLOUDFLARE_EMAIL)" \
		-var "cloudflare_token=$(CLOUDFLARE_TOKEN)" \
		-var "record_domain=$(RECORD_DOMAIN)" \
		-var "record_name=$(RECORD_NAME)" \
		-var "record_value=$(RECORD_VALUE)" \
		-var "record_type=$(RECORD_TYPE)" \
		-var "record_ttl=$(RECORD_TTL)"

.PHONY: help
help:
	@echo -e "$$(grep -hE '^\S+:.*##' $(MAKEFILE_LIST) | sed -e 's/:.*##\s*/:/' -e 's/^\(.\+\):\(.*\)/\\x1b[36m\1\\x1b[m:\2/' | column -c2 -t -s :)"

.PHONY: cf-init
cf-init:
	@:$(call check_defined, CLOUDFLARE_EMAIL, Cloudflare email address)
	@:$(call check_defined, CLOUDFLARE_TOKEN, Cloudflare api key)
	@:$(call check_defined, RECORD_DOMAIN, Record domain)
	@:$(call check_defined, RECORD_NAME, Record name)
	@:$(call check_defined, RECORD_VALUE, Record value)
	@:$(call check_defined, RECORD_TYPE, Record type)
	@:$(call check_defined, RECORD_TTL, Record TTL)
	@cd $(CF_DIR) && terraform init $(CF_TERRAFORM_FLAGS)		

.PHONY: cf-import
cf-import: cf-init ## Run terraform plan for Cloudflare worker.
ifdef RECORD_ID
	@cd $(CF_DIR) && terraform import $(CF_TERRAFORM_FLAGS) cloudflare_record.record $(RECORD_DOMAIN)/$(RECORD_ID)
endif

.PHONY: cf-plan
cf-plan: cf-init ## Run terraform plan for Cloudflare worker.
	@cd $(CF_DIR) && terraform plan $(CF_TERRAFORM_FLAGS)

.PHONY: cf-apply
cf-apply: cf-init ## Run terraform apply for Cloudflare worker.
	@cd $(CF_DIR) && terraform apply $(CF_TERRAFORM_FLAGS) \
		$(TERRAFORM_FLAGS)

.PHONY: cf-destroy
cf-destroy: cf-init ## Run terraform destroy for Cloudflare worker.
	@cd $(CF_DIR) && terraform destroy \
		$(CF_TERRAFORM_FLAGS)

check_defined = \
				$(strip $(foreach 1,$1, \
				$(call __check_defined,$1,$(strip $(value 2)))))
__check_defined = \
				$(if $(value $1),, \
					$(error Undefined $1$(if $2, ($2))$(if $(value @), \
					required by target `$@')))

.PHONY: update
update: update-terraform ## Update terraform binary locally.

TERRAFORM_BINARY:=$(shell which terraform || echo "/usr/local/bin/terraform")
TMP_TERRAFORM_BINARY:=/tmp/terraform
.PHONY: update-terraform
update-terraform: ## Update terraform binary locally from the docker container.
	@echo "Updating terraform binary..."
	$(shell docker run --rm --entrypoint bash r.j3ss.co/terraform -c "cd \$\$$(dirname \$\$$(which terraform)) && tar -Pc terraform" | tar -xvC $(dir $(TMP_TERRAFORM_BINARY)) > /dev/null)
	sudo mv $(TMP_TERRAFORM_BINARY) $(TERRAFORM_BINARY)
	sudo chmod +x $(TERRAFORM_BINARY)
	@echo "Update terraform binary: $(TERRAFORM_BINARY)"
	@terraform version

.PHONY: test
test: shellcheck ## Runs the tests on the repository.

# if this session isn't interactive, then we don't want to allocate a
# TTY, which would fail, but if it is interactive, we do want to attach
# so that the user can send e.g. ^C through.
INTERACTIVE := $(shell [ -t 0 ] && echo 1 || echo 0)
ifeq ($(INTERACTIVE), 1)
	DOCKER_FLAGS += -t
endif

.PHONY: shellcheck
shellcheck: ## Runs the shellcheck tests on the scripts.
	docker run --rm -i $(DOCKER_FLAGS) \
		--name shellcheck \
		-v $(CURDIR):/usr/src:ro \
		--workdir /usr/src \
		r.j3ss.co/shellcheck ./test.sh

