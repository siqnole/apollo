FROM ubuntu:22.04

# Minimal tools — everything a sysadmin problem might need
RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    coreutils \
    findutils \
    grep \
    sed \
    gawk \
    tree \
    file \
    less \
    nano \
    vim-tiny \
    curl \
    wget \
    tar \
    gzip \
    zip \
    unzip \
    diffutils \
    procps \
    iproute2 \
    man-db \
    && rm -rf /var/lib/apt/lists/*

# Create the sandbox user — never run as root
RUN useradd -m -s /bin/bash user && \
    echo 'user ALL=(ALL) NOPASSWD: /bin/chmod, /bin/chown' >> /etc/sudoers

# ── Problem setup scripts ──────────────────────────────────────────────────
# Each problem has:
#   /opt/problems/<slug>/setup.sh   — builds the starting filesystem in /home/user
#   /opt/problems/<slug>/check.sh   — exits 0 if solved, 1 if not
RUN mkdir -p /opt/problems

COPY problems/ /opt/problems/

# Global dispatcher scripts
RUN echo '#!/bin/bash\nSLUG=$1\nif [ -f "/opt/problems/$SLUG/setup.sh" ]; then\n  bash /opt/problems/$SLUG/setup.sh\nelse\n  echo "Unknown problem: $SLUG" >&2; exit 1\nfi' \
    > /usr/local/bin/setup-problem && chmod +x /usr/local/bin/setup-problem

RUN echo '#!/bin/bash\nSLUG=$1\nif [ -f "/opt/problems/$SLUG/check.sh" ]; then\n  bash /opt/problems/$SLUG/check.sh\nelse\n  echo "No checker for: $SLUG" >&2; exit 1\nfi' \
    > /usr/local/bin/check-solution && chmod +x /usr/local/bin/check-solution

USER user
WORKDIR /home/user