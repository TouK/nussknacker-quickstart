#!/bin/sh

if [ -z "${RELEASE}" ]; then
  CONTAINER_NAME=$(docker ps | grep nussknacker_kafka | awk '{print $1}')
  docker exec -i $CONTAINER_NAME "$@"
else
  kubectl exec -i $RELEASE-kafka-0 -- "$@"
fi