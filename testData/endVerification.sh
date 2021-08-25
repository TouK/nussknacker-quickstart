#!/bin/bash

while true; do
  NUSS=$(curl -u admin:admin -s 'http://localhost:8080/api/processCounts/DetectLargeTransactions?dateFrom=2021-08-25T10:38:00%2B02:00&dateTo=2021-08-31T23:59:59%2B02:00' |
    python3 -c "import sys, json; print(json.load(sys.stdin)['send for audit']['all'])")
  FLINK=$(curl -s 'http://localhost:8081/flink/jobs/00716fa1f0f2ec952da69a346755e241/vertices/29ae407dbfb9ffc27c2eb61b11c78d73/subtasks/metrics?get=DetectLargeTransactions-send_for_audit-function.numRecordsOut' |
    python3 -c "import sys, json; print(json.load(sys.stdin)[0]['sum'])")
  printf '\n'

  echo "nuss = ${NUSS}; flink = ${FLINK}"
  if [[ "$NUSS" == "$FLINK" ]]; then
    echo "Hi"
    exit 0
  else
    echo "Not Hi"
  fi
  sleep 1
done


