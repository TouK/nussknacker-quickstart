FROM holomekc/wiremock-gui:3.8.1 AS wiremock

RUN apt-get update && \ 
    apt-get install -y wget && \
    wget -P /var/wiremock/extensions https://repo1.maven.org/maven2/org/wiremock/extensions/wiremock-faker-extension-standalone/0.2.0/wiremock-faker-extension-standalone-0.2.0.jar

FROM phusion/baseimage:noble-1.0.0

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

# install
USER root

RUN apt-get update -y && \
    apt -y install openjdk-11-jre-headless && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# WIREMOCK
COPY --from=wiremock /var/wiremock /var/wiremock
COPY --from=wiremock /home/wiremock /home/wiremock

COPY http-service/mocks /home/wiremock/
COPY http-service/scripts /etc/service/http-service
RUN mv /etc/service/http-service/run-wiremock.sh /etc/service/http-service/run

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=30 \
  CMD (curl -f http://localhost:8080/__admin/) || exit 1

  # todo: delete