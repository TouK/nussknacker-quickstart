#!/bin/sh -e

echo "RUNNING Wiremock service..."

java $JAVA_OPTS -cp /var/wiremock/lib/*:/var/wiremock/extensions/* wiremock.Run \
    --port=8080 \
    --root-dir=/home/wiremock/mocks \
    --max-request-journal=1000 \
    --global-response-templating \
    --extensions=org.wiremock.RandomExtension \
    --async-response-enable=true \
    --async-response-threads=30 \
    --disable-banner