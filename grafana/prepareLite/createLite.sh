#!/bin/bash

set -e

cd "$(dirname $0)"

jq -f preprocess.jq ../dashboards/nussknacker-scenario.json | sed -f ./replacements.sed > ../dashboards/nussknacker-lite-scenario.json
cd -