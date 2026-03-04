# check=skip=InvalidDefaultArgInFrom;error=true

ARG IMAGE
ARG MIKTEX_SRC_REPO

FROM ${IMAGE}
ARG MIKTEX_SRC_REPO

# Install dependencies via apt-get
RUN --mount=type=bind,target=/context \
    apt-get update \
 && xargs -a /context/Debian.packages apt-get install -y --no-install-recommends \
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
 && xargs -a /context/Install.packages apt-get install -y --no-install-recommends \
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

# Install LaTeX packages
RUN --mount=type=bind,target=/context \
     miktex --admin --verbose packages update-package-database \
 && (miktex --admin --verbose packages install --package-id-file /context/Packages.list || (cat /var/log/miktex/mpmcli_admin.log && exit 1)) \
 && initexmf --admin --update-fndb

ENV MIKTEX_USERCONFIG=/miktex/.miktex/texmfs/config
ENV MIKTEX_USERDATA=/miktex/.miktex/texmfs/data
ENV MIKTEX_USERINSTALL=/miktex/.miktex/texmfs/install

ENV MIKTEX_MAINT_GIVEUP_AFTER_DAYS=9999
