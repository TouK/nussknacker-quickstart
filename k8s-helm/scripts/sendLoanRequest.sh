#!/bin/bash -ex

cd "$(dirname "$0")"

MAX_SAMPLE_POSITION=$(cat sampleLoanRequests.txt | wc -l)

function print_help() {
  echo "Usage $0 <sample_position>"
  echo ""
  echo "sample_position - number in range <1, $MAX_SAMPLE_POSITION>, position of sample in sampleLoanRequests.txt file"
}

if [[ $# -lt 1 ]]; then
  echo "Missing sample position argument"
  echo ""
  print_help
  exit 1
fi

SAMPLE_POSITION=$1

if [[ $SAMPLE_POSITION -ge 1 && $SAMPLE_POSITION -le $MAX_SAMPLE_POSITION ]]; then
  sample_request=$(sed "${SAMPLE_POSITION}q;d" sampleLoanRequests.txt)
  echo -e "Sending request:\n\n${sample_request}\n"
  curl -d "$sample_request" -HContent-Type:application/json -i http://localhost:3181
  echo ""
else
  echo "Invalid sample position argument: $SAMPLE_POSITION"
  echo ""
  print_help
  exit 2
fi
