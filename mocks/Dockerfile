FROM phusion/baseimage:noble-1.0.0

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

# install
USER root

RUN apt-get install -y --no-install-recommends curl ca-certificates && \
    install -d /usr/share/postgresql-common/pgdg && \
    curl -o /usr/share/postgresql-common/pgdg/apt.postgresql.org.asc --fail https://www.postgresql.org/media/keys/ACCC4CF8.asc && \
    echo "deb [signed-by=/usr/share/postgresql-common/pgdg/apt.postgresql.org.asc] https://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list && \
    apt-get update -y && \
    apt -y install postgresql-16 && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# users
# postgres user is already added by install command

# postgres
ENV PG_DB_NAME="mocks"
ENV PG_USER="mocks"
ENV PG_PASS="mocks_pass"

ENV PG_BIN_DIR="/usr/lib/postgresql/16/bin"
ENV PG_DIR="/usr/local/pgsql"
ENV PG_DATA_DIR="$PG_DIR/data"
ENV PG_CUSTOM_BIN_DIR="$PG_DIR/bin"
ENV PG_CUSTOM_CONF_DIR="$PG_DIR/conf"
ENV PG_CONF_FILE="$PG_CUSTOM_CONF_DIR/postgresql.conf"
ENV PG_HBA_FILE="$PG_CUSTOM_CONF_DIR/pg_hba.conf"

COPY postgres "$PG_CUSTOM_BIN_DIR"
RUN chmod -R +x "$PG_CUSTOM_BIN_DIR" && \
    mkdir /etc/service/postgres && \
    mv "$PG_CUSTOM_BIN_DIR"/run_postgres.sh /etc/service/postgres/run && \
    "$PG_CUSTOM_BIN_DIR"/postgres_setup.sh

# ports
EXPOSE 5432
