#!/bin/bash

set -e

cd "$(dirname $0)"
source .env

helm repo add --force-update touk https://helm-charts.touk.pl/public
helm repo add --force-update touk-snapshots https://helm-charts.touk.pl/nexus/repository/helm-snapshots/
helm repo update

if [[ "$DEVEL" = true ]]; then
  HELM_REPO=${HELM_REPO:-touk-snapshots/nussknacker}
  NUSSKNACKER_VERSION=${NUSSKNACKER_VERSION:-staging-latest}
  DEVEL_ARG="--devel"
else
  HELM_REPO=${HELM_REPO:-touk/nussknacker}
  NUSSKNACKER_VERSION=${NUSSKNACKER_VERSION:-latest}
  DEVEL_ARG=""
fi

kubectl get secret "$RELEASE-postgresql" || cat postgres-secret.yaml | POSTGRES_PASSWORD=`date +%s | sha256sum | base64 | head -c 32` RELEASE=$RELEASE MAYBE_NAMESPACE=`kubectl config view --minify -o jsonpath='{..namespace}'` NAMESPACE=${MAYBE_NAMESPACE:-default} envsubst | kubectl apply -f -

if [[ -z $DOMAIN ]]
then
  ADDITIONAL_VALS="--set ingress.skipHost=true"
else 
  ADDITIONAL_VALS="--set ingress.skipHost=false --set ingress.domain=$DOMAIN"
fi

COMMAND=${COMMAND:-"upgrade -i"}

helm $COMMAND $DEVEL_ARG "${RELEASE}" $HELM_REPO \
  --wait \
  $ADDITIONAL_VALS \
  --set image.tag="${NUSSKNACKER_VERSION}" \
  --set postgresql.auth.existingSecret="${RELEASE}-postgresql" $@
