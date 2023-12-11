#!/bin/bash -e

cd "$(dirname "$0")"

displayLogs() {
    scripts/displayAllPodLogs.sh
}

trap displayLogs ERR

./install-common.sh -f values-request-response.yaml
