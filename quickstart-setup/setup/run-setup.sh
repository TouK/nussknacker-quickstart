#!/bin/bash -e

cd "$(dirname "$0")"

./schema-registry/setup-schemas.sh
./kafka/setup-topics.sh
./nu/customize-nu-configuration.sh
./nu/import-and-deploy-example-scenarios.sh