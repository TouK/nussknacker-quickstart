#!/bin/bash

if ! command -v "helm" &> /dev/null; then
    echo "helm does not exist. Please install it first https://helm.sh/docs/helm/helm_install/"
    exit 1
fi

cd "$(dirname "$0")"

kubectl delete deployment -l nussknacker.io/nussknackerInstanceName=nu-quickstart
kubectl delete -f additional/custom-services.yaml
helm uninstall nu-quickstart