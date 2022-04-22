#!/bin/bash

set -e

cd "$(dirname $0)"

function wrapWithSchemaRegistryMessage() {
    NAME=$1
    echo "{\"schema\": \"$(cat $NAME.json | sed -z -e 's/\n/\\n/g' -e 's/"/\\"/g')\"}"
}

function createSchema() {
    NAME=$1
    if [[ -z "${RELEASE}" ]]
    then
        wrapWithSchemaRegistryMessage $NAME | curl -d @- -H "Content-Type: application/vnd.schemaregistry.v1+json" http://localhost:3082/subjects/$NAME/versions -v
    else
        wrapWithSchemaRegistryMessage $NAME | kubectl exec -i deploy/$RELEASE-apicurio-registry -- curl -d @- -H "Content-type: application/json" http://localhost:8080/apis/ccompat/v6/subjects/$NAME/versions -v
    fi
}

createSchema transactions-value
createSchema processedEvents-value
createSchema alerts-value
