#!/bin/sh -e

java $JAVA_OPTS -cp /var/wiremock/lib/*:/var/wiremock/extensions/* wiremock.Run \
    --port=8080 \
    --root-dir=/home/wiremock \
    --max-request-journal=1000 \
    --local-response-templating \
    --async-response-enable=true \
    --async-response-threads=30