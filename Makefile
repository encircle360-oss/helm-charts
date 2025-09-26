.PHONY: help
help: ## Display this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

##@ Development

.PHONY: lint
lint: ## Lint all charts
	@echo "Linting all charts..."
	@for chart in charts/*/; do \
		echo "Linting $$chart..."; \
		helm lint $$chart; \
	done

.PHONY: template
template: ## Template all charts
	@echo "Templating all charts..."
	@for chart in charts/*/; do \
		echo "Templating $$chart..."; \
		helm template $$chart; \
	done

.PHONY: docs
docs: ## Generate documentation for all charts
	@echo "Generating documentation..."
	@helm-docs --chart-search-root=charts

.PHONY: package
package: ## Package all charts
	@echo "Packaging all charts..."
	@mkdir -p dist
	@for chart in charts/*/; do \
		echo "Packaging $$chart..."; \
		helm package $$chart -d dist; \
	done

.PHONY: index
index: package ## Create Helm repository index
	@echo "Creating repository index..."
	@helm repo index dist --url https://encircle360-oss.github.io/helm-charts/

##@ Testing

.PHONY: test
test: lint ## Run tests
	@echo "Running chart tests..."
	@ct lint --config ct.yaml

.PHONY: test-install
test-install: ## Test chart installation (requires kind cluster)
	@echo "Testing chart installation..."
	@ct install --config ct.yaml

##@ Utilities

.PHONY: clean
clean: ## Clean build artifacts
	@echo "Cleaning..."
	@rm -rf dist/
	@find . -type f -name '*.tgz' -delete

.PHONY: update-deps
update-deps: ## Update chart dependencies
	@echo "Updating chart dependencies..."
	@for chart in charts/*/; do \
		if [ -f "$$chart/Chart.yaml" ]; then \
			echo "Updating dependencies for $$chart..."; \
			helm dependency update $$chart; \
		fi \
	done

.PHONY: install-tools
install-tools: ## Install required tools
	@echo "Installing tools..."
	@echo "Installing helm-docs..."
	@go install github.com/norwoodj/helm-docs/cmd/helm-docs@latest
	@echo "Installing chart-testing..."
	@pip install yamllint yamale
	@curl -sSL https://github.com/helm/chart-testing/releases/download/v3.11.0/chart-testing_3.11.0_linux_amd64.tar.gz | tar -xz
	@sudo mv ct /usr/local/bin/
	@echo "Tools installed successfully!"