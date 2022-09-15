#!/bin/sh

set -e
cd "$(dirname $0)"

LINE_NUMBER=$1
sed "${LINE_NUMBER}q;d" sampleRequests.txt | curl -d @- -v http://localhost:3181
