#!/bin/bash

set -e

# If dir parameter not provided, fallback to script's directory
dir=${1:-$(dirname $0)}
resolved_dir=$(readlink -f $dir)
echo "Registering schemas from $resolved_dir"
cd $resolved_dir

function wrapWithSchemaRegistryMessage() {
    NAME=$1
    echo "{\"schema\": \"$(cat $NAME.json | awk '{gsub(/\n/, "\\n"); gsub(/"/, "\\\""); print}')\", \"schemaType\": \"JSON\"}"
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

for file in $(ls *.json); do
  subject=$(basename $file .json)
  createSchema $subject;
done
