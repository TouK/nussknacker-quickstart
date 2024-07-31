FROM holomekc/wiremock-gui:3.8.1 AS wiremock
FROM postgres:16 AS postgres

FROM phusion/baseimage:noble-1.0.0

# install
USER root

RUN apt-get update -y && \
    apt -y install openjdk-11-jre-headless && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# WIREMOCK
COPY --from=wiremock /var/wiremock /var/wiremock
COPY --from=wiremock /home/wiremock /home/wiremock

COPY http-service/run-wiremock.sh /var/wiremock
RUN mkdir -p /etc/service/http-service && \
    mv /var/wiremock/run-wiremock.sh /etc/service/http-service/run

EXPOSE 8080

# POSTGRES
COPY --from=postgres /usr/local/bin/docker-entrypoint.sh /usr/local/bin/
COPY --from=postgres /docker-entrypoint-initdb.d/ /docker-entrypoint-initdb.d/
COPY --from=postgres /usr/share/postgresql/ /usr/share/postgresql/

COPY postgres /etc/service/postgresql
RUN mv /etc/service/postgresql/run_postgres.sh /etc/service/postgresql/run 

EXPOSE 5432

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=30 \
  CMD (curl -f http://localhost:8080/__admin/ && pg_isready -U postgres) || exit 1