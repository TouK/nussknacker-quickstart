#!/bin/bash -e

cd "$(dirname "$0")"

source ../../../scripts/utils/lib.sh

# todo add random for remaining cities and limit aggregate to specific numbers of events
CLIENT_ID=$(random_1digit_number)
LAT="52.23$(random_3digit_number)"
LON="21.01$(random_3digit_number)"
TIME=$(date +%s)

echo "{\"clientId\": $CLIENT_ID, \"geo\": { \"lat\": $LAT, \"lon\": $LON }, \"eventTime\": $TIME }"