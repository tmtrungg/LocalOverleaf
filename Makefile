# LocalOverleaf - Local LaTeX compilation with versioned PDF output
#
# Commands:
#   make              Compile and open PDF
#   make watch        Auto-compile on file save
#   make list         List all PDF versions
#   make clean        Remove build artifacts
#   make commit msg="message"   Git commit .tex/.cls files
#   make diff         Show uncommitted .tex changes
#   make history      Show git log

.PHONY: all compile watch commit clean list diff history

all: compile

compile:
	@./compile.sh

watch:
	@echo "Watching for changes... (Ctrl+C to stop)"
	@if command -v latexmk >/dev/null 2>&1; then \
		latexmk -pdf -pvc -interaction=nonstopmode -output-directory=.build main.tex; \
	elif command -v fswatch >/dev/null 2>&1; then \
		fswatch -o *.tex *.cls *.sty *.bib | xargs -n1 -I{} ./compile.sh --no-open; \
	else \
		echo "Error: Install latexmk or fswatch for watch mode"; \
		echo "  macOS: brew install fswatch"; \
		exit 1; \
	fi

commit:
ifndef msg
	$(error Usage: make commit msg="your commit message")
endif
	@git add main.tex resume.cls *.sty *.bib 2>/dev/null || true
	@git commit -m "$(msg)"
	@echo "Committed: $(msg)"

clean:
	@echo "Cleaning build artifacts..."
	@rm -rf .build
	@echo "Done."

list:
	@echo "Output PDFs:"
	@echo "============"
	@ls -lh output/*.pdf 2>/dev/null || echo "  No PDFs yet. Run 'make' to compile."

diff:
	@git diff -- '*.tex' '*.cls'

history:
	@git log --oneline --graph -20
