FROM bitnami/kafka:3.7.0

USER root

RUN apt update && \
    apt install -y curl jq kafkacat less && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY entrypoint.sh /
COPY scripts/ /app/scripts/
COPY data/ /app/data/
COPY setup/ /app/setup/

HEALTHCHECK --interval=10s --timeout=1s --retries=12 CMD /bin/bash -c 'test -f "/app/healthy"'

ENTRYPOINT [ "/entrypoint.sh" ]
