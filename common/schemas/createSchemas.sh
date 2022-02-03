#!/bin/bash

set -e

cd "$(dirname $0)"

function createSchema() {
    NAME=$1
    if [[ -z "${RELEASE}" ]]
    then
        curl -X POST -H "Content-Type: application/vnd.schemaregistry.v1+json"  --data @$NAME.json http://localhost:3082/subjects/$NAME/versions -v
    else
        cat $NAME.json | kubectl exec -i deploy/$RELEASE-apicurio-registry -- curl -d @- -H "Content-type: application/json" http://localhost:8080/apis/ccompat/v6/subjects/$NAME/versions -v
    fi 
}

createSchema transactions-value
createSchema processedEvents-value
createSchema alerts-value
