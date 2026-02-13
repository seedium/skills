.PHONY: all clean validate plugin/all plugin/engineering

DIST_DIR := dist

# Default target
all: plugin/all

# Create dist directory
$(DIST_DIR):
	mkdir -p $(DIST_DIR)

# Validate marketplace
validate:
	@echo "Validating marketplace..."
	@python3 -c "import json; json.load(open('.claude-plugin/marketplace.json'))" && echo "marketplace.json: valid" || echo "marketplace.json: invalid"
	@for f in $$(find plugins -name 'plugin.json'); do \
		python3 -c "import json; json.load(open('$$f'))" && echo "$$f: valid" || echo "$$f: invalid"; \
	done

# Zip engineering plugin
plugin/engineering: $(DIST_DIR)
	@echo "Zipping engineering plugin..."
	@cd plugins/engineering && zip -r ../../$(DIST_DIR)/engineering.zip . -x "*.git*" -x "*.DS_Store"
	@echo "Created $(DIST_DIR)/engineering.zip"

# Zip all plugins (add new plugins here)
plugin/all: plugin/engineering
	@echo "All plugins zipped successfully"

# Clean dist directory
clean:
	@echo "Cleaning dist directory..."
	@rm -rf $(DIST_DIR)
	@echo "Done"
