#!/bin/bash -e

random_4digit_number() {
  od -An -t d -N 2 /dev/urandom |  head -n 1 | tr -d ' ' | head -c 4
}

random_3digit_number() {
  random_4digit_number | head -c 3
}

ID=$((1 + $(random_4digit_number) % 5))
AMOUNT=$((1 + $(random_4digit_number) % 30))
NOW="$(date +%s)$(random_3digit_number)"
TIME=$((NOW - $(random_4digit_number) % 20))

echo "{ \"clientId\": \"Client$ID\", \"amount\": $AMOUNT, \"eventDate\": $TIME}"


# (dla Trasacations.schema.json zrobc rabom)
# 1. exec nasza lib Transaction.schema.json
# 2. curl drogalisa Transaction.schema.json $SECRET