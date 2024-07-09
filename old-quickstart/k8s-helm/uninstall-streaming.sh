#!/bin/bash

if ! command -v "helm" &> /dev/null; then
    echo "helm does not exist. Please install it first https://helm.sh/docs/helm/helm_install/"
    exit 1
fi

cd "$(dirname "$0")"
set -a; source .env; set +a

displayLogs() {
    scripts/displayAllPodLogs.sh
}

trap displayLogs ERR

kubectl delete deployment -l nussknacker.io/nussknackerInstanceName=nu-quickstart
helm uninstall "$RELEASE-akhq"
kubectl delete -f additional/custom-services.yaml
helm uninstall nu-quickstart