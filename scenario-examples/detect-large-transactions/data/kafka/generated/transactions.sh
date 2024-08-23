#!/bin/bash -e

cd "$(dirname "$0")"

source /app/utils/lib.sh

ID=$((1 + $(random_4digit_number) % 5))
AMOUNT=$((1 + $(random_4digit_number) % 30))
TIME=$(($(now) - $(random_4digit_number) % 20))

echo "{ \"clientId\": \"Client$ID\", \"amount\": $AMOUNT, \"eventDate\": $TIME}"