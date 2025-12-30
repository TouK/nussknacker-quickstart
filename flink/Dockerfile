ARG TOUK_FLINK_VERSION

FROM touk/flink:${TOUK_FLINK_VERSION}

USER root

ADD https://repo1.maven.org/maven2/org/postgresql/postgresql/42.6.0/postgresql-42.6.0.jar /opt/flink/lib/postgresql-42.6.0.jar
RUN chmod 644 /opt/flink/lib/postgresql-42.6.0.jar

RUN echo '#!/bin/sh' > /ex-docker-entrypoint.sh && \
    echo 'export FLINK_PROPERTIES=$(cat /opt/flink/conf/flink-properties.yml) && /docker-entrypoint.sh "$@"' >> /ex-docker-entrypoint.sh && \
    chmod +x /ex-docker-entrypoint.sh

USER flink
COPY flink-properties.yml /opt/flink/conf/
RUN mkdir -p /opt/flink/data && \
    chmod -R 777 /opt/flink/data

VOLUME /opt/flink/data

ENTRYPOINT [ "/ex-docker-entrypoint.sh" ]
