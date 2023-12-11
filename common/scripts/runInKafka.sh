#!/bin/bash -e

if [ -z "${RELEASE}" ]; then
  if ! command -v "docker" &> /dev/null; then
      echo "docker does not exist. Please install it first https://docs.docker.com/engine/install/"
      exit 1
  fi

  CONTAINER_NAME=$(docker ps | grep nussknacker_kafka | awk '{print $1}')
  docker exec -i "$CONTAINER_NAME" $@
else
  if ! command -v "kubectl" &> /dev/null; then
    echo "kubectl does not exist. Please install it first https://kubernetes.io/docs/tasks/tools/"
    exit 1
  fi

  #In Docker-based setup we use Confluent image. In K8s setup we use Bitnami. The former has scripts without .sh suffix, while the latter - with it...
  ORIGINAL_COMMAND="$@"
  BITNAMI_COMMAND=$(echo "$ORIGINAL_COMMAND" | sed 's/\(kafka-[^[:space:]]*\)/\1.sh/g')
  kubectl exec -i "$RELEASE"-kafka-0 -- $BITNAMI_COMMAND
fi