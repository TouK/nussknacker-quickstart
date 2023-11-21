#!/bin/bash -ex

if ! command -v "helm" &> /dev/null; then
    echo "heml does not exist. Please install it first https://helm.sh/docs/helm/helm_install/"
    exit 1
fi

if ! command -v "kubectl" &> /dev/null; then
    echo "kubectl does not exist. Please install it first https://kubernetes.io/docs/tasks/tools/"
    exit 2
fi

cd "$(dirname "$0")"
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

kubectl get secret "$RELEASE-postgresql" || cat postgres-secret.yaml | POSTGRES_PASSWORD=$(date +%s | sha256sum | base64 | head -c 32) RELEASE=$RELEASE MAYBE_NAMESPACE=$(kubectl config view --minify -o jsonpath='{..namespace}') NAMESPACE=${MAYBE_NAMESPACE:-default} envsubst | kubectl apply -f -

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
  --set nussknacker.usageStatisticsReportsFingerprint="${USAGE_REPORTS_FINGERPRINT}" \
  --set postgresql.auth.existingSecret="${RELEASE}-postgresql" $@
