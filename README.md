# MikTeX Docker Image

This repository is based on [Debian 12.x Bookworm (slim) with Python 3.14](https://hub.docker.com/_/python).

Docker Hub: https://hub.docker.com/r/pytooling/miktex

## Usage

```bash
docker image run --rm -v $(pwd):/latex pytooling/miktex:latest
```

## Installed Tools

Installed additional tools are:

* curl
* GhostScript
* make
* MikTeX
  * Preinstalled packages: [Common.list](Common.list) 
* Perl
* Python 3.14
* sudo
* tree


## Why another MikTeX Docker Image?

* [MikTeX original containers](https://hub.docker.com/r/miktex/miktex) do not provide installations based on Ubuntu LTS.
* MikTeX original containers are infrequently updated (>1 year).
* MikTeX original containers aren't smaller (less download time).
* pyTooling has control over preinstalled commonly used LaTeX packages (`amsfonts`/`amsmath`, `babel`, `hyperref`, `longtables`, ...)
* pyTooling can derive specific images for e.g. [Sphinx](Sphinx.list).

## Derived Variants

### Sphinx

MiKTeX:
* Common package list: [Common.list](Common.list)  
* Sphinx specific package list: [Sphinx.list](Sphinx.list)

Additional Debian Packages: [Sphinx.packages](Sphinx.packages)
* nodejs: [Sphinx.npm](Sphinx.npm)
  * Mermaid


### Doxygen

**planned**

### Pandoc

**planned**


## License

This Docker Image build receipt and all it's accompanying configuration and script files (source code) are licensed
under [The MIT License](LICENSE.md) if not mentioned otherwise within the respective file.

---

SPDX-License-Identifier: MIT