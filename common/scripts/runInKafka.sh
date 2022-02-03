#!/bin/bash
if [[ -z "${RELEASE}" ]]
then
docker exec -i nussknacker_kafka $@
else
kubectl exec -i $RELEASE-kafka-0 -- $@
fi