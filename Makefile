# LocalOverleaf Makefile
# Usage:
#   make                          - Compile default project
#   make project=MyProject        - Compile specific project
#   make watch                    - Auto-compile on file changes
#   make commit msg="message"     - Git commit source files
#   make list                     - List all output PDFs
#   make clean                    - Remove build artifacts
#   make diff                     - Show uncommitted changes
#   make history                  - Show git log

# Default project (change this or override with: make project=X)
project ?= CV_bigtechresearch

.PHONY: all compile watch commit clean list diff history init

all: compile

compile:
	@./compile.sh $(project)

# Auto-compile on file changes using latexmk -pvc (continuous preview)
watch:
	@echo "Watching $(project) for changes... (Ctrl+C to stop)"
	@cd projects/$(project) && latexmk -pdf -pvc -interaction=nonstopmode -output-directory=.build main.tex

# Git commit source files
commit:
ifndef msg
	$(error Usage: make commit msg="your commit message")
endif
	@git add projects/$(project)/*.tex projects/$(project)/*.cls projects/$(project)/*.sty projects/$(project)/*.bib 2>/dev/null || true
	@git commit -m "$(msg)"
	@echo ""
	@echo "Committed: $(msg)"

# Remove build artifacts
clean:
	@echo "Cleaning build artifacts for $(project)..."
	@rm -rf projects/$(project)/.build
	@echo "Done."

# Clean all projects
clean-all:
	@echo "Cleaning all build artifacts..."
	@find projects -name ".build" -type d -exec rm -rf {} + 2>/dev/null || true
	@echo "Done."

# List all output PDFs
list:
	@echo "Output PDFs:"
	@echo "============"
	@ls -lh output/*.pdf 2>/dev/null || echo "  No PDFs yet. Run 'make' to compile."

# Show git diff for tex files
diff:
	@git diff -- 'projects/$(project)/*.tex' 'projects/$(project)/*.cls'

# Show git history
history:
	@git log --oneline --graph -20

# Initialize git repo (run once)
init:
	@git init
	@git add -A
	@git commit -m "Initial commit: LocalOverleaf setup"
	@echo "Git repository initialized."
