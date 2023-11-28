#!/bin/bash

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

helm uninstall "$RELEASE-akhq"
kubectl delete deployment -l nussknacker.io/nussknackerInstanceName=nu-quickstart
helm uninstall nu-quickstart