# =============================================================================
# Configuration
# =============================================================================

DATABASE_URL ?= postgres://postgres:password@localhost:5432/event_store
export DATABASE_URL

.DEFAULT_GOAL := help


# =============================================================================
# Help
# =============================================================================

.PHONY: help
help: ## Show available commands
	@grep -E '^[a-zA-Z0-9_-]+:.*## ' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' | \
		sort


# =============================================================================
# Development
# =============================================================================

.PHONY: check lint fmt fmt-check test
check: ## Check workspace
	cargo check --workspace --all-targets

lint: ## Run clippy
	cargo clippy --workspace --all-targets -- -D warnings

fmt: ## Format all code
	$(MAKE) remove-unused
	$(MAKE) sort
	cargo fmt --all

fmt-check: ## Check formatting for all files (Rust, Cargo.toml, unused deps)
	cargo fmt --all -- --check
	cargo sort --workspace --check
	cargo machete

test: ## Run all tests
	cargo test --workspace --all-features

# =============================================================================
# Dependencies
# =============================================================================

.PHONY: install-tools sort remove-unused upgrade upgrade-latest
install-tools: ## Install development tools
	cargo install \
		cargo-sort \
		cargo-machete \
		cargo-edit \
		sqlx-cli

sort: ## Sort Cargo.toml dependencies
	cargo sort --workspace

remove-unused: ## Remove unused dependencies
	cargo machete --fix || true

upgrade: ## Upgrade compatible dependencies
	cargo upgrade

upgrade-latest: ## Upgrade dependencies to latest versions
	cargo upgrade --incompatible
