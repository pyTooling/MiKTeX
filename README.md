# MikTeX Docker Image

This repository is based on [Debian 12.x Bookworm (slim) with Python 3.14](https://hub.docker.com/_/python).

Docker Hub: https://hub.docker.com/r/pytooling/miktex

| Docker Hub Image           | GitHub Branch/Tag | Comment                                       |
|----------------------------|-------------------|-----------------------------------------------|
| `pytooling/miktex:latest`  | `vX.Y.Z`          | Created from tagged release on `main` brnach. |
| `pytooling/miktex:release` | `main`            | Created from commits on `main` brnach.        |
| `pytooling/miktex:dev`     | `dev`             | Created from commits on `dev` brnach.         |

| Docker Hub Image                                              | Comment                                                                         |
|---------------------------------------------------------------|---------------------------------------------------------------------------------|
| tbd; see [#12](https://github.com/pyTooling/MiKTeX/issues/12) | Created specificly for processing [Doxygen](https://www.doxygen.nl/) ouputs.    |
| tbd; see [#11](https://github.com/pyTooling/MiKTeX/issues/11) | Created specificly for processing [Pandoc](https://pandoc.org/) ouputs.         |
| `pytooling/miktex:sphinx`                                     | Created specificly for processing [Sphinx](https://www.sphinx-doc.org/) ouputs. |


## Why another MikTeX Docker Image?

* [MikTeX original containers](https://hub.docker.com/r/miktex/miktex) do not provide installations based on Debian.
* MikTeX original containers are infrequently updated (>1 year).
* MikTeX original containers aren't smaller (less download time).
* Prepare MiKTeX with Unicode support ([`pyTooling.sty`](pyTooling.sty)).
* pyTooling has control over preinstalled commonly used LaTeX packages (`amsfonts`/`amsmath`, `babel`, `hyperref`, `longtables`, ...)
* pyTooling can derive specific images for e.g.Doxygen, Pandoc, [`Sphinx`](Sphinx.list), ...

## Usage

### Standalone Docker Container
```bash
docker image run --rm -it -v $(pwd):/latex pytooling/miktex:latest
```

### GitHub Action Pipeline
```yml
  MiKTeX:
    name: 📓 Translate to PDF
    runs-on: 'ubuntu-24.04'
    container:
      image: pytooling/miktex:latest
    steps:
      - name: ⏬ Checkout repository
        uses: actions/checkout@v6

      - name: 📓 Compile 'latex/document.tex'
        run: |
          set -o pipefail
          
          cd ./latex
          chown -R latex:latex .
          sudo -u latex latexmk \
            --lualatex \
            --interaction=nonstopmode \
            --file-line-error \
            --halt-on-error \
            document.tex | filter.latexmk.sh
          
          ls -lAh *.pdf

      - name: 📤 Upload 'document-pdf' artifact
        uses: pyTooling/upload-artifact@v7
        with:
          name: document-pdf
          working-directory: latex
          path: document.pdf
          if-no-files-found: error
          retention-days: 1
```

## MiKTeX Docker Image
### Installed Tools

Installed additional tools are:

* curl
* MikTeX
  * Preinstalled packages: [Common.list](Common.list) 
* Perl
* Python 3.14
* sudo
* tree

### Installed Fonts

* Cabin
* DejaVu
* Latin Modern (LM)
* Libertinus (optimized `Linux Libertine` for LuaLaTeX)
* [URW Type Foundy](https://en.wikipedia.org/wiki/URW_Type_Foundry)
  * URW Bookman (`ITC Bookman` clone)
  * Nimbus Sans (`Helvetica` clone)
  * Nimbus Roman (`Times New Roman` clone)
  * ~~Palladio -> Palatino~~
* Noto (No Tofu)

## Derived Variant Docker Images

### Doxygen

**planned**, see [#12](https://github.com/pyTooling/MiKTeX/issues/12)

### Pandoc

**planned**, see [#11](https://github.com/pyTooling/MiKTeX/issues/11)

### Sphinx

MiKTeX:
* Common package list: [Common.list](Common.list)  
* Sphinx specific package list: [Sphinx.list](Sphinx.list)

Additional Debian Packages: [Sphinx.packages](Sphinx.packages)
* nodejs: [Sphinx.npm](Sphinx.npm)
  * Mermaid

#### Sphinx configuration in `conf.py`

The following configuration will activate LaTeX code specific for LuaLaTeX and Unicode support. It deactivates
`polyglossia` and uses `babel` (has now better Unicode support).

```py
from textwrap import dedent

latex_engine = "lualatex"
latex_use_xindy = False
latex_elements = {
	"papersize":   "a4paper",      # The paper size ('letterpaper' or 'a4paper').
	"pointsize":   "10pt",         # The font size ('10pt', '11pt' or '12pt').
	"inputenc":    "",             # Let LuaLaTeX handle input encoding
	"utf8extra":   "",
	"polyglossia": "",
	"babel":      r"\usepackage[english]{babel}",
	"fontenc":    r"\usepackage{fontspec}",  # Disable the default T1 font encoding (Essential for LuaLaTeX)
	"fontpkg":    r"\usepackage[fontfamily=libertinus]{pytooling}",
	"passoptionstopackages": dedent("""\
		\\PassOptionsToPackage{verbatimvisiblespace=\\ }{sphinx}
	"""),
	"makeindex":  r"\usepackage[columns=1]{idxlayout}\makeindex",
	"printindex": r"\def\twocolumn[#1]{#1}\printindex",
}
```

## `pytooling.sty`

### Options

| Option     | Default            | Description                                                                               | 
|------------|--------------------|-------------------------------------------------------------------------------------------|
| fontfamily | latinmodern        | Select a Unicode capable font family.<br>Supported: dejavu, latinmodern, libertinus, noto |
| emojifont  | NotoColorEmoji.ttf | Select a Unicode icon/emoji font.                                                         |
| emojiscale | 0.6                | Scaling of emojis to match text height.                                                   |
| emojiraise | 0.1em              | Raise emojis to match normal texts baseline.                                              |


## License

This Docker Image build receipt and all it's accompanying configuration and script files (source code) are licensed
under [The MIT License](LICENSE.md) if not mentioned otherwise within the respective file.

---
SPDX-License-Identifier: MIT
