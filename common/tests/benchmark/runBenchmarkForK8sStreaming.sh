#!/bin/bash -e

cd "$(dirname "$0")"

displayLogs() {
    ../../../k8s-helm/scripts/displayAllPodLogs.sh
}

trap displayLogs ERR

./runBenchmark.sh $@ 