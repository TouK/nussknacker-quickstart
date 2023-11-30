#!/bin/bash -e

cd "$(dirname "$0")"

source ../../scripts/utils.sh

COUNT=$1
SCENARIO=$2

rm -f /tmp/benchmarkResult.txt

function measure() {
    NAME=$1
    shift
    echo "Running $NAME stage of benchmark"
    /usr/bin/time -o /tmp/res -f "%e*1000" $@ 
    echo "$NAME,$(cat /tmp/res | bc)" >> /tmp/benchmarkResult.csv
}

measure "prepareData" ./sendBenchmarkTransactions.sh transactions "$COUNT"
measure "runScenario" ../../scripts/createScenarioAndDeploy.sh "$(fullPath "$SCENARIO")"
measure "verifyResult" ./verifyScenarioFinish.sh
