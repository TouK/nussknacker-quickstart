#!/bin/bash -e

cd "$(dirname "$0")"

source /app/utils/lib.sh

RECORD_TYPE="$(pick_randomly 1 2)" 
MESSAGE_STATUS="$(pick_randomly 1 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 3 4 5 6 7 )" 
MSISDNA=$(random_Ndigit_number 9)
MSISDNB=$(random_Ndigit_number 9)


echo "{ \"record_type\": $RECORD_TYPE,  \"message_status\": $MESSAGE_STATUS, \"msisdn_a\": \"$MSISDNA\", \"msisdn_b\": \"$MSISDNB\" }"