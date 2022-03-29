#!/bin/sh
LINE_NUMBER=$1
BASE_URL=http://localhost:3181/scenario
sed "${LINE_NUMBER}q;d" sampleRequests.txt | curl -d @- -v $BASE_URL/loan
