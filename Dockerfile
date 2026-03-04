# check=skip=InvalidDefaultArgInFrom;error=true
# The MIT License (MIT)
#
# Copyright © 2026 The pyTooling Authors
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
# documentation files (the “Software”), to deal in the Software without restriction, including without limitation the
# rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit
# persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the
# Software.
#
# THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
# WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
# OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
ARG IMAGE
ARG MIKTEX_SRC_REPO

FROM ${IMAGE}
ARG MIKTEX_SRC_REPO

# Install dependencies via apt-get
RUN --mount=type=bind,target=/context \
    apt-get update \
 && xargs --no-run-if-empty --exit --arg-file=/context/Debian.packages apt-get install -y --no-install-recommends \
 && rm -rf /var/lib/apt/lists/* \
 && apt-get clean
# TODO: rm and clean can be replaced by `apt-get dist-clean`, when supported by all OS versions.

# Switch Dash to Bash
RUN ln -sf /bin/bash /bin/sh

# Install MikTeX
RUN curl -fsSL https://miktex.org/download/key | gpg --dearmor -o /usr/share/keyrings/miktex.gpg
RUN echo "deb [signed-by=/usr/share/keyrings/miktex.gpg] https://miktex.org/download/debian bookworm universe" | tee /etc/apt/sources.list.d/miktex.list
# Install dependencies via apt-get
RUN --mount=type=bind,target=/context \
    apt-get update \
 && xargs --no-run-if-empty --exit --arg-file=/context/Install.packages apt-get install -y --no-install-recommends \
 && rm -rf /var/lib/apt/lists/* \
 && apt-get clean
# TODO: rm and clean can be replaced by `apt-get dist-clean`, when supported by all OS versions.

# Install executables like lualatex into /usr/local/bin
RUN miktexsetup --shared=yes finish

# Enable automatic package installations
RUN initexmf --admin --set-config-value [MPM]AutoInstall=1

# Change line length settings in 'texmfapp.ini'
RUN configFile="$(find /usr/local/share/miktex-texmf -name "texmfapp.ini" 2>/dev/null | head -n 1)"; \
    printf -- "Patching '${configFile}' ..."; \
    if [[ -f "${configFile}" ]]; then \
      sed -i \
        -e 's/^error_line = .*/error_line = 1000/' \
        -e 's/^half_error_line = .*/half_error_line = 200/' \
        -e 's/^max_print_line = .*/max_print_line = 1000/' \
      "${configFile}"; \
      printf -- "[DONE]\n"; \
    else \
      printf -- "[NOT FOUND]\n"; \
    fi

RUN groupadd --gid 1000 latex \
 && useradd --uid 1000 --gid 1000 -m -d /latex latex \
 && printf -- "latex ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/latex \
 && chmod 0440 /etc/sudoers.d/latex \
 && ls -lAh /

WORKDIR /latex
ENV HOME=/latex

# Install LaTeX packages
RUN --mount=type=bind,target=/context \
     miktex --admin --verbose packages update-package-database \
 && (miktex --admin --verbose packages install --package-id-file /context/Packages.list || (cat /var/log/miktex/mpmcli_admin.log && exit 1)) \
 && initexmf --admin --update-fndb

# Install STDOUT filter scripts for LaTeX
RUN --mount=type=bind,target=/context \
    install -m 755 /context/filter.latexmk.sh /usr/local/bin/filter.latexmk.sh

# Configure MiKTeX directories and create directories if mountpoint from host is missing.
ENV MIKTEX_USERCONFIG=/latex/.miktex/texmfs/config \
    MIKTEX_USERDATA=/latex/.miktex/texmfs/data \
    MIKTEX_USERINSTALL=/latex/.miktex/texmfs/install \
    MIKTEX_MAINT_GIVEUP_AFTER_DAYS=9999

RUN mkdir -p $MIKTEX_USERCONFIG $MIKTEX_USERDATA $MIKTEX_USERINSTALL \
 && chown -R latex:latex /latex

USER latex
