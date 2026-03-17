    FROM ubuntu:22.04

    ENV DEBIAN_FRONTEND=noninteractive
    ENV PGPASSWORD=apollo
    ENV PGUSER=apollo
    ENV PGDATABASE=apollo
    ENV PGHOST=localhost

    RUN apt-get update && apt-get install -y --no-install-recommends \
        bash coreutils findutils grep sed gawk tree file less nano \
        postgresql postgresql-client \
        && rm -rf /var/lib/apt/lists/*

    RUN rm -rf /var/lib/postgresql/14/main && \
        mkdir -p /var/lib/postgresql/14/main && \
        chown postgres:postgres /var/lib/postgresql/14/main && \
        su -c "/usr/lib/postgresql/14/bin/initdb -D /var/lib/postgresql/14/main" postgres
    
    # Create sandbox user
    RUN useradd -m -s /bin/bash user

    # Problem scripts
    RUN mkdir -p /opt/problems
    COPY problems/ /opt/problems/

    # Global dispatchers
    RUN printf '#!/bin/bash\nSLUG=$1\n[ -f "/opt/problems/$SLUG/setup.sh" ] && bash /opt/problems/$SLUG/setup.sh || { echo "Unknown problem: $SLUG" >&2; exit 1; }\n' \
        > /usr/local/bin/setup-problem && chmod +x /usr/local/bin/setup-problem

    RUN printf '#!/bin/bash\nSLUG=$1\n[ -f "/opt/problems/$SLUG/check.sh" ] && bash /opt/problems/$SLUG/check.sh || { echo "No checker for: $SLUG" >&2; exit 1; }\n' \
        > /usr/local/bin/check-solution && chmod +x /usr/local/bin/check-solution

    # Entrypoint: start postgres, then keep alive
    COPY entrypoint.sh /entrypoint.sh
    RUN chmod +x /entrypoint.sh

    USER root
    ENTRYPOINT ["/entrypoint.sh"]