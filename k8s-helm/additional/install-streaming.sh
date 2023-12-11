#!/bin/bash -e

if ! command -v "helm" &> /dev/null; then
    echo "helm does not exist. Please install it first https://helm.sh/docs/helm/helm_install/"
    exit 1
fi

if ! command -v "kubectl" &> /dev/null; then
    echo "kubectl does not exist. Please install it first https://kubernetes.io/docs/tasks/tools/"
    exit 2
fi

cd "$(dirname $0)"
set -a; . ../.env; set +a

displayLogs() {
    ../scripts/displayAllPodLogs.sh
}

trap displayLogs ERR

./waitForServiceAccount.sh

export AKHQ_SECURITY_GROUP=admin

kubectl apply -f custom-services.yaml

helm repo add akhq https://akhq.io/
if [[ -z $DOMAIN ]]; then
    export AKHQ_HOST=localhost
else 
    export AKHQ_HOST="$RELEASE-nussknacker.$DOMAIN"
fi

envsubst < akhq.yaml | helm upgrade -i "$RELEASE-akhq" akhq/akhq --debug --wait --values -