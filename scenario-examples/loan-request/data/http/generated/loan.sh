#!/bin/bash -e

cd "$(dirname "$0")"

source /app/utils/lib.sh

ID="$(random_4digit_number)"
AMOUNT="$(random_4digit_number)"
REQUEST_TYPE="$(pick_randomly "loan" "mortgage" "insurance")"
CITY="$(pick_randomly "Warszawa" "Berlin" "Gdańsk" "Kraków", "Poznań", "Praga")"

echo "{\"customerId\": \"$ID\", \"requestedAmount\": $AMOUNT, \"requestType\": \"$REQUEST_TYPE\", \"location\": { \"city\": \"$CITY\", \"street\": \"\" }}"