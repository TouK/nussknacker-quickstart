#!/bin/bash -e

cd "$(dirname "$0")"

source /app/utils/lib.sh

case $(($(random_1digit_number) % 3)) in
  0)
    LAT="52.23$(random_3digit_number)"
    LON="21.01$(random_3digit_number)"
    ;;
  1)
    LAT="50.04$(random_3digit_number)"
    LON="19.94$(random_3digit_number)"
    ;;
  *)
    LAT="51.10$(random_3digit_number)"
    LON="17.03$(random_3digit_number)"
    ;;
esac

CLIENT_ID=$(random_1digit_number)
TIME=$(date +%s)

echo "{\"clientId\": $CLIENT_ID, \"geo\": { \"lat\": $LAT, \"lon\": $LON }, \"eventTime\": $TIME }"
