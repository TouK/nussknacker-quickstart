FROM holomekc/wiremock-gui:3.8.1 AS wiremock

RUN apt-get update && \ 
    apt-get install -y wget && \
    wget -P /var/wiremock/extensions https://repo1.maven.org/maven2/org/wiremock/extensions/wiremock-faker-extension-standalone/0.2.0/wiremock-faker-extension-standalone-0.2.0.jar

FROM phusion/baseimage:noble-1.0.0

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

USER root

RUN apt update && \
    apt install -y curl jq less && \
    apt -y install openjdk-11-jre-headless && \
    apt clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    curl https://raw.githubusercontent.com/birdayz/kaf/master/godownloader.sh | BINDIR=/bin bash

WORKDIR /app

COPY run.sh /etc/service/setup/run

COPY setup/ /app/setup/
COPY mocks/ /app/mocks/
COPY data/ /app/data/
COPY utils/ /app/utils/

# WIREMOCK
COPY --from=wiremock /var/wiremock /var/wiremock
COPY --from=wiremock /home/wiremock /home/wiremock

RUN mv /app/mocks/http-service/mocks /home/wiremock/ && \
    mkdir -p /etc/service/http-service && \
    mv /app/mocks/http-service/scripts/run-wiremock.sh /etc/service/http-service/run

EXPOSE 8080

HEALTHCHECK --interval=10s --timeout=1s --retries=12 --start-period=30s \
  CMD (/bin/bash -c 'test -f "/app/healthy"' && curl -f http://localhost:8080/__admin/) || exit 1
