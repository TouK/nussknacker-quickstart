#!/bin/bash -ex

if ! command -v "kubectl" &> /dev/null; then
    echo "kubectl does not exist. Please install it first https://kubernetes.io/docs/tasks/tools/"
    exit 1
fi

cd "$(dirname "$0")"
set -a; . ../.env; set +a

./waitForServiceAccount.sh

kubectl apply -f custom-services.yaml
