#!/bin/bash
# LocalOverleaf - Compile LaTeX and save versioned PDF
# https://github.com/tmtrungg/LocalOverleaf
set -uo pipefail

# Colors (disabled if not a terminal)
if [ -t 1 ]; then
    RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'
else
    RED=''; GREEN=''; YELLOW=''; CYAN=''; BOLD=''; NC=''
fi

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
BUILD_DIR="$ROOT_DIR/.build"
OUTPUT_DIR="$ROOT_DIR/output"
MAIN_TEX="main.tex"
NO_OPEN=false

# Parse arguments
for arg in "$@"; do
    case $arg in
        --no-open) NO_OPEN=true ;;
        --help|-h)
            echo "LocalOverleaf - Compile LaTeX and save versioned PDFs"
            echo ""
            echo "Usage: ./compile.sh [options]"
            echo ""
            echo "Options:"
            echo "  --no-open   Don't open the PDF after compiling"
            echo "  --help, -h  Show this help message"
            echo ""
            echo "The script compiles main.tex, saves a versioned PDF in output/,"
            echo "and keeps output/latest.pdf always pointing to the newest build."
            exit 0
            ;;
    esac
done

# Check dependencies
if ! command -v latexmk &>/dev/null && ! command -v pdflatex &>/dev/null; then
    echo -e "${RED}Error:${NC} Neither latexmk nor pdflatex found."
    echo "Install a TeX distribution:"
    echo "  macOS:   brew install --cask mactex-no-gui"
    echo "  Ubuntu:  sudo apt install texlive-full"
    echo "  Windows: https://miktex.org/download"
    exit 1
fi

# Validate main.tex exists
if [ ! -f "$ROOT_DIR/$MAIN_TEX" ]; then
    echo -e "${RED}Error:${NC} $MAIN_TEX not found in $ROOT_DIR"
    exit 1
fi

# Create directories
mkdir -p "$BUILD_DIR" "$OUTPUT_DIR"

echo -e "${CYAN}Compiling${NC} $MAIN_TEX ..."

# Compile: prefer latexmk, fall back to pdflatex
cd "$ROOT_DIR"
if command -v latexmk &>/dev/null; then
    latexmk -pdf -interaction=nonstopmode -halt-on-error -output-directory=.build "$MAIN_TEX" >/dev/null 2>&1 || true
else
    # Run pdflatex twice for references
    pdflatex -interaction=nonstopmode -halt-on-error -output-directory=.build "$MAIN_TEX" >/dev/null 2>&1 || true
    pdflatex -interaction=nonstopmode -halt-on-error -output-directory=.build "$MAIN_TEX" >/dev/null 2>&1 || true
fi

PDF_FILE="$BUILD_DIR/$(basename "$MAIN_TEX" .tex).pdf"

if [ -f "$PDF_FILE" ] && [ "$PDF_FILE" -nt "$ROOT_DIR/$MAIN_TEX" ]; then
    # Determine next version number
    EXISTING_VERSIONS=$(ls "$OUTPUT_DIR"/v*.pdf 2>/dev/null | wc -l | tr -d ' ')
    NEXT_VERSION=$((EXISTING_VERSIONS + 1))
    TIMESTAMP=$(date +"%Y-%m-%d_%H-%M")
    VERSIONED_NAME="v${NEXT_VERSION}_${TIMESTAMP}.pdf"

    # Copy to output
    cp "$PDF_FILE" "$OUTPUT_DIR/$VERSIONED_NAME"
    cp "$PDF_FILE" "$OUTPUT_DIR/latest.pdf"

    echo -e "${GREEN}Compiled successfully!${NC}"
    echo -e "  ${BOLD}v${NEXT_VERSION}${NC} -> output/$VERSIONED_NAME"
    echo -e "  Latest -> output/latest.pdf"

    # Open PDF viewer
    if [ "$NO_OPEN" = false ]; then
        if command -v open &>/dev/null; then
            open "$OUTPUT_DIR/latest.pdf"                    # macOS
        elif command -v xdg-open &>/dev/null; then
            xdg-open "$OUTPUT_DIR/latest.pdf" &>/dev/null &  # Linux
        elif command -v start &>/dev/null; then
            start "$OUTPUT_DIR/latest.pdf"                   # Windows (Git Bash)
        fi
    fi
else
    echo -e "${RED}Compilation failed!${NC}"

    LOG_FILE="$BUILD_DIR/$(basename "$MAIN_TEX" .tex).log"
    if [ -f "$LOG_FILE" ]; then
        echo ""
        # Extract LaTeX errors with context
        grep -A 2 "^! " "$LOG_FILE" | head -30 | while IFS= read -r line; do
            echo -e "  ${RED}$line${NC}"
        done
        # Show line references
        grep "^l\." "$LOG_FILE" | head -10 | while IFS= read -r line; do
            echo -e "  ${YELLOW}$line${NC}"
        done
    fi
    exit 1
fi
