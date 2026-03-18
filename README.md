# LocalOverleaf

I built a local LaTeX compiler for easier resume editing, compiling, and quick adaptation for different job applications — without needing to open Overleaf every time.

## The Problem

Every time I needed to tweak my CV for a specific role, I had to:
- Log into Overleaf, wait for it to load
- Make edits, wait for cloud compilation
- Download the PDF, rename it manually
- Lose track of which version I sent where

I wanted something that just works locally — edit, compile, done — with every version saved automatically so I can always trace back what I submitted.

## What This Does

- **One command to compile** — run `./compile.sh`, get a PDF, it opens automatically
- **Every version is kept** — each compile saves a timestamped PDF (`v1`, `v2`, `v3`...) so I never lose a previous version
- **`output/latest.pdf`** always points to the most recent build
- **Works offline** — no accounts, no internet, files stay on my machine
- **Git-friendly** — track changes to `.tex` source files with simple `make commit` commands

## How I Use It

```
# Edit main.tex in VS Code (or any editor), then:
./compile.sh

# Output:
#   ✓ Compiled successfully!
#     v3 -> output/v3_2025-03-18_14-30.pdf
#     Latest -> output/latest.pdf
```

When applying to jobs, I keep a version for each application. I edit, compile, and the PDF is ready to attach — with all previous versions still in `output/` if I need to go back.

`make watch` auto-compiles on every save, so the PDF updates live while I'm editing — similar to Overleaf's preview but fully local.

## Setup

**Requirements:** A LaTeX distribution (`latexmk` or `pdflatex`):

| OS | Install |
|----|---------|
| macOS | `brew install --cask mactex-no-gui` |
| Ubuntu/Debian | `sudo apt install texlive-full` |
| Windows | [MiKTeX](https://miktex.org/download) |

**Then:**

```bash
git clone https://github.com/tmtrungg/LocalOverleaf.git
cd LocalOverleaf
# Edit main.tex with your own details
./compile.sh
```

The included `main.tex` is a clean resume template — replace the placeholders with your info and you're good to go.

## Commands

| Command | What it does |
|---------|-------------|
| `./compile.sh` | Compile and open PDF |
| `./compile.sh --no-open` | Compile without opening |
| `make watch` | Auto-compile on every file save |
| `make list` | List all versioned PDFs |
| `make commit msg="..."` | Git commit `.tex` changes |
| `make clean` | Remove build artifacts |

## Project Structure

```
LocalOverleaf/
├── main.tex        ← your resume (edit this)
├── resume.cls      ← document style
├── compile.sh      ← compile script
├── Makefile        ← shortcut commands
├── output/         ← all compiled PDFs (gitignored)
└── .build/         ← LaTeX temp files (gitignored)
```

I made this public so anyone who wants a simple local LaTeX workflow can grab it and use it. Feel free to swap in your own `.cls` template or adapt it for papers, cover letters, etc.

## License

MIT
