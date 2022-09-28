SHELL := /bin/bash

DOCKER_NAME      := votive-web
IMAGE_NAME       := votive-web
BUILD_IMAGE_NAME := ghcr.io/eldencat/devtools/votive-dev
BUILD_IMAGE_TAG  := latest
DOCKER_PORT      := 8080
HOST_PORT        := 9000

CARGO_MANIFEST_PATH ?= $(shell find -maxdepth 1 -name Cargo.toml)
CARGO_INCREMENTAL   ?= 1
RUSTC_BOOTSTRAP     ?= 0
RELEASE_TARGET      ?= x86_64-unknown-linux-musl
MD_FILES ?= $(shell find . -type f -iname '*.md' ! -path "./target/*" ! -path "./.cargo/*" ! -path "./.cargo-husky/*")

# Style templates for console output.
GREEN  := $(shell echo -e `tput setaf 2`)
YELLOW := $(shell echo -e `tput setaf 3`)
CYAN   := $(shell echo -e `tput setaf 6`)
NC     := $(shell echo -e `tput setaf 9`)
BOLD   := $(shell echo -e `tput bold`)
SMUL   := $(shell echo -e `tput smul`)
SGR0   := $(shell echo -e `tput sgr0`)

# function with a generic template to run docker with the required values
# Accepts $1 = command to run, $2 = additional flags (optional)
docker_run = docker run \
	--name=$(DOCKER_NAME)-$@ \
	--rm \
	--user `id -u`:`id -g` \
	-e CARGO_INCREMENTAL=$(CARGO_INCREMENTAL) \
	-e RUSTC_BOOTSTRAP=$(RUSTC_BOOTSTRAP) \
	-v "$(PWD):/usr/local/app" \
	-v "$(PWD)/.cargo/registry:/usr/local/cargo/registry" \
	$(2) \
	-t $(BUILD_IMAGE_NAME):$(BUILD_IMAGE_TAG) \
	$(1)

cargo_run = $(call docker_run,cargo $(1) --manifest-path "$(CARGO_MANIFEST_PATH)" $(2))

taplo_run = docker run \
	--name=$(DOCKER_NAME)-taplo-$@ \
	--rm \
	--user `id -u`:`id -g` \
	-w "/usr/local/app" \
	-v "$(PWD):/usr/local/app" \
	-t tamasfe/taplo $(1)

cspell_run = docker run \
		--name=$(DOCKER_NAME)-cspell-$@ \
		--rm \
		--user `id -u`:`id -g` \
		-w "/usr/local/app" \
		-v "$(PWD):/usr/local/app" \
		-t ghcr.io/streetsidesoftware/cspell:6.10.1 \
		cspell $(1)

help:
	@echo ""
	@echo "$(BOLD)$(CYAN)Available targets$(NC)$(SGR0)"
	@echo ""
	@echo "$(SMUL)$(BOLD)$(GREEN)Rust$(NC)$(SGR0)"
	@echo "  $(YELLOW)All cargo commands will use '--manifest-path $(CARGO_MANIFEST_PATH)'$(NC)"
	@echo "  $(BOLD)build$(SGR0)       -- Run 'cargo build'"
	@echo "  $(BOLD)release$(SGR0)     -- Run 'cargo build --release --target RELEASE_TARGET'"
	@echo "                 (RELEASE_TARGET=$(RELEASE_TARGET))"
	@echo "  $(BOLD)publish$(SGR0)     -- Run 'cargo publish --dry-run --target RELEASE_TARGET'"
	@echo "                 (RELEASE_TARGET=$(RELEASE_TARGET))"
	@echo "  $(BOLD)clean$(SGR0)       -- Run 'cargo clean'"
	@echo "  $(BOLD)rust-check$(SGR0)  -- Run 'cargo check'"
	@echo "  $(BOLD)rust-test$(SGR0)   -- Run 'cargo test --all'"
	@echo "  $(BOLD)rust-clippy$(SGR0) -- Run 'cargo clippy --all -- -D warnings'"
	@echo "  $(BOLD)rust-fmt$(SGR0)    -- Run 'cargo fmt --all -- --check' to check rust file formats."
	@echo "  $(BOLD)rust-tidy$(SGR0)   -- Run 'cargo fmt --all' to fix rust file formats if needed."
	@echo ""
	@echo "$(SMUL)$(BOLD)$(GREEN)TOML$(NC)$(SGR0)"
	@echo "  $(BOLD)toml-test$(SGR0)   -- Run 'taplo format --check' to validate TOML file formats."
	@echo "  $(BOLD)toml-tidy$(SGR0)   -- Run 'taplo format' to fix TOML file formats if needed."
	@echo ""
	@echo "$(SMUL)$(BOLD)$(GREEN)CSpell$(NC)$(SGR0)"
	@echo "  $(BOLD)cspell-test$(SGR0) -- Run 'cspell --words-only --unique "**/**" -c .cspell.config.yaml'"
	@echo "                 to validate files are not containing any spelling errors."
	@echo "  $(BOLD)cspell-add-words$(SGR0) -- Run 'cspell --words-only --unique "**/**" -c .cspell.config.yaml 2> /dev/null |"
	@echo "                      sort -f >> .cspell.project-words.txt'"
	@echo "                      to add remaining words to the project's cspell ignore list"
	@echo ""
	@echo "$(SMUL)$(BOLD)$(GREEN)Combined targets$(NC)$(SGR0)"
	@echo "  $(BOLD)test$(SGR0) -- Run targets; rust-check rust-test rust-clippy rust-fmt toml-test"
	@echo "  $(BOLD)tidy$(SGR0) -- Run targets; rust-tidy toml-tidy"

	@echo "  $(BOLD)run$(SGR0)  -- Run docker container as a daemon, binding port $(HOST_PORT):$(DOCKER_PORT)"
	@echo "  $(BOLD)stop$(SGR0) -- Run 'docker kill ${DOCKER_NAME}-run && docker rm ${DOCKER_NAME}-run' to stop and cleanup our docker after running"
	@echo "  $(BOLD)all$(SGR0)  -- Run targets; test build release run"


# Rust / cargo targets
pre-action:
	@docker pull $(BUILD_IMAGE_NAME):$(BUILD_IMAGE_TAG)
	if [ ! -d "$(PWD)/.cargo/registry" ]; then mkdir -p "$(PWD)/.cargo/registry" ; fi

build: pre-action
	@$(call cargo_run,build)

release:
	@$(call cargo_run,build,--release --target $(RELEASE_TARGET))

publish:
	@$(call cargo_run,publish,--dry-run --target $(RELEASE_TARGET))

clean: pre-action
	@$(call cargo_run,clean)

rust-check: pre-action
	@$(call cargo_run,check)

rust-test: pre-action
	@$(call cargo_run,test,--all)

rust-clippy: pre-action
	@$(call cargo_run,clippy,--all -- -D warnings)

rust-fmt: pre-action
	@echo "$(YELLOW)Running and checking Rust codes formats...$(NC)"
	@$(call cargo_run,fmt,--all -- --check)

rust-tidy: pre-action
	@echo "$(YELLOW)Running rust file formatting fixes...$(NC)"
	@$(call cargo_run,fmt,--all)

# TOML / taplo targets
toml-test:
	@echo "$(YELLOW)Running toml file formatting tests...$(NC)"
	@$(call taplo_run,format --check)

toml-tidy:
	@echo "$(YELLOW)Running toml file formatting fixes...$(NC)"
	@$(call taplo_run,format)

# editorconfig targets
editorconfig-test:
	@echo "$(YELLOW)Checking if the codebase is compliant with the .editorconfig file...$(NC)"
	@docker run \
		--name=$(DOCKER_NAME)-$@ \
		--rm \
		--user `id -u`:`id -g` \
		-w "/usr/local/app" \
		-v "$(PWD):/usr/local/app" \
		-t mstruebing/editorconfig-checker

link-test:
	@echo "$(YELLOW)'make link-test': Checking if all document links are valid...$(NC)"
	@docker run \
		--name=link-test \
		--rm \
		--user `id -u`:`id -g` \
		-w "/usr/src/app" \
		-v "$(PWD):/usr/src/app" \
		ghcr.io/tcort/markdown-link-check:stable \
		--quiet \
		$(MD_FILES)

# cspell targets
cspell-test:
	@echo "$(YELLOW)Checking for spelling errors...$(NC)"
	@$(call cspell_run,--words-only --unique "**/**" -c .cspell.config.yaml)

# Combined targets
test: rust-check rust-test rust-clippy rust-fmt toml-test
tidy: rust-tidy toml-tidy

run: stop
# Run docker container as a daemon and map a port
	@$(call docker_run,sh,-d -p $(HOST_PORT):$(DOCKER_PORT))

stop:
	@docker kill ${DOCKER_NAME}-run || true
	@docker rm ${DOCKER_NAME}-run || true

all: test build release run

