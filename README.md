# LocalOverleaf

I build a local LaTex compiler for easier Resume editing/compiling. Compile LaTeX locally. Edit `.tex` files in any editor, run one command, get a versioned PDF.

No accounts, no uploads, no internet required. Your files stay on your machine.

## Why

- **Overleaf is great, but** — you don't always want to be online, deal with compile timeouts, or lose control of your files
- **Version control built in** — every compile saves a timestamped PDF, so you can always go back
- **Works with any editor** — VS Code, Vim, Sublime, whatever you like
- **Zero config** — clone, edit `main.tex`, run `./compile.sh`

## Quick Start

```bash
git clone https://github.com/tmtrungg/LocalOverleaf.git
cd LocalOverleaf

# Edit main.tex with your details, then:
./compile.sh
```

The PDF opens automatically. A versioned copy is saved in `output/`.

## Requirements

A LaTeX distribution with `latexmk` or `pdflatex`:

| OS | Install |
|----|---------|
| macOS | `brew install --cask mactex-no-gui` |
| Ubuntu/Debian | `sudo apt install texlive-full` |
| Fedora | `sudo dnf install texlive-scheme-full` |
| Windows | [MiKTeX](https://miktex.org/download) or [TeX Live](https://tug.org/texlive/) |

## Commands

| Command | What it does |
|---------|-------------|
| `./compile.sh` | Compile and open PDF |
| `./compile.sh --no-open` | Compile without opening |
| `make watch` | Auto-compile on every file save |
| `make list` | List all versioned PDFs |
| `make clean` | Remove build artifacts |
| `make commit msg="..."` | Git commit your `.tex` changes |
| `make diff` | Show uncommitted changes |
| `make history` | Show git log |

> **Note:** `make` requires Xcode Command Line Tools on macOS (`xcode-select --install`). You can always use `./compile.sh` directly instead.

## Project Structure

```
LocalOverleaf/
├── main.tex        ← your resume/CV (edit this)
├── resume.cls      ← document style
├── compile.sh      ← compilation script
├── Makefile        ← shortcut commands
├── output/         ← compiled PDFs (auto-generated, gitignored)
│   ├── latest.pdf
│   ├── v1_2025-01-15_14-30.pdf
│   └── v2_2025-01-15_16-45.pdf
└── .build/         ← LaTeX temp files (auto-generated, gitignored)
```

## How It Works

1. You edit `main.tex` (and optionally `resume.cls` for styling)
2. Run `./compile.sh`
3. `latexmk` compiles the LaTeX → PDF (with automatic multi-pass for references)
4. The PDF is copied to `output/v{N}_{timestamp}.pdf` and `output/latest.pdf`
5. The PDF opens in your default viewer

Each compile increments the version number. All versions are kept in `output/` so you never lose a previous build.

## Customization

### Use your own template

Replace `main.tex` and `resume.cls` with any LaTeX template — the compile script works with any `.tex` file that has a `main.tex` entry point.

### Change the main file name

If your entry point isn't `main.tex`, edit the `MAIN_TEX` variable at the top of `compile.sh`.

### Add packages

The included `resume.cls` is minimal. Add any LaTeX packages you need with `\usepackage{}` in `main.tex`.

## Troubleshooting

**"latexmk not found"** — Install a TeX distribution (see Requirements above).

**"make: command not found"** — On macOS, run `xcode-select --install`. Or just use `./compile.sh` directly.

**Compilation errors** — The script shows LaTeX errors with line numbers. Check your `.tex` syntax.

**PDF not updating in Preview (macOS)** — Preview auto-refreshes when the file changes. If it doesn't, close and reopen the PDF.

## License

MIT
