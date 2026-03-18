#!/bin/bash
# LocalOverleaf - Compile LaTeX project and save versioned PDF
set -uo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECTS_DIR="$SCRIPT_DIR/projects"
OUTPUT_DIR="$SCRIPT_DIR/output"

# Usage
if [ $# -lt 1 ]; then
    echo -e "${YELLOW}Usage:${NC} ./compile.sh <project_name> [--no-open]"
    echo -e "${YELLOW}Available projects:${NC}"
    for dir in "$PROJECTS_DIR"/*/; do
        if [ -d "$dir" ]; then
            name=$(basename "$dir")
            echo "  - $name"
        fi
    done
    exit 1
fi

PROJECT_NAME="$1"
NO_OPEN="${2:-}"
PROJECT_DIR="$PROJECTS_DIR/$PROJECT_NAME"
BUILD_DIR="$PROJECT_DIR/.build"

# Validate project exists
if [ ! -d "$PROJECT_DIR" ]; then
    echo -e "${RED}Error:${NC} Project '$PROJECT_NAME' not found in $PROJECTS_DIR"
    exit 1
fi

# Find main .tex file
MAIN_TEX="main.tex"
if [ -f "$PROJECT_DIR/.localoverleaf.conf" ]; then
    source "$PROJECT_DIR/.localoverleaf.conf"
fi

if [ ! -f "$PROJECT_DIR/$MAIN_TEX" ]; then
    echo -e "${RED}Error:${NC} $MAIN_TEX not found in $PROJECT_DIR"
    exit 1
fi

# Create build and output directories
mkdir -p "$BUILD_DIR"
mkdir -p "$OUTPUT_DIR"

echo -e "${CYAN}Compiling${NC} $PROJECT_NAME/$MAIN_TEX ..."

# Run latexmk
cd "$PROJECT_DIR"
COMPILE_OUTPUT=$(latexmk -pdf -interaction=nonstopmode -halt-on-error -output-directory=.build "$MAIN_TEX" 2>&1) || true
PDF_FILE="$BUILD_DIR/$(basename "$MAIN_TEX" .tex).pdf"

if [ -f "$PDF_FILE" ] && [ "$PDF_FILE" -nt "$PROJECT_DIR/$MAIN_TEX" ]; then
    # Compilation succeeded — determine next version number
    EXISTING_VERSIONS=$(ls "$OUTPUT_DIR"/${PROJECT_NAME}_v*.pdf 2>/dev/null | wc -l | tr -d ' ')
    NEXT_VERSION=$((EXISTING_VERSIONS + 1))

    # Timestamp
    TIMESTAMP=$(date +"%Y-%m-%d_%H-%M")

    # Versioned filename
    VERSIONED_NAME="${PROJECT_NAME}_v${NEXT_VERSION}_${TIMESTAMP}.pdf"

    # Copy to output
    cp "$PDF_FILE" "$OUTPUT_DIR/$VERSIONED_NAME"
    cp "$PDF_FILE" "$OUTPUT_DIR/${PROJECT_NAME}_latest.pdf"

    echo ""
    echo -e "${GREEN}Compiled successfully!${NC}"
    echo -e "  Version:  ${CYAN}v${NEXT_VERSION}${NC}"
    echo -e "  Output:   ${CYAN}output/$VERSIONED_NAME${NC}"
    echo -e "  Latest:   ${CYAN}output/${PROJECT_NAME}_latest.pdf${NC}"

    # Open in Preview (macOS) unless --no-open
    if [ "$NO_OPEN" != "--no-open" ]; then
        open "$OUTPUT_DIR/${PROJECT_NAME}_latest.pdf"
    fi
else
    # Compilation failed
    echo ""
    echo -e "${RED}Compilation failed!${NC}"
    echo ""

    # Parse log for errors
    LOG_FILE="$BUILD_DIR/$(basename "$MAIN_TEX" .tex).log"
    if [ -f "$LOG_FILE" ]; then
        echo -e "${YELLOW}Errors:${NC}"
        grep -n "^! " "$LOG_FILE" | while IFS= read -r line; do
            echo -e "  ${RED}$line${NC}"
        done

        # Show line references
        grep -n "^l\." "$LOG_FILE" | while IFS= read -r line; do
            echo -e "  ${YELLOW}$line${NC}"
        done
    fi
    exit 1
fi
