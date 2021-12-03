#!/bin/sh

#In prepare replacement based on measurements
REPLACEMENT=`cat replacements | sed "s/.*/-e s\/&\//" | tr '\n' ' '`
cd ../dashboards
#We delete last two panels and change uid and title
jq "del(.panels[-2:]) | .uid |= \"nussknacker-lite-scenario\" | .title |= \"Lite scenario\"" nussknacker-scenario.json | sed $REPLACEMENT > nussknacker-lite-scenario.json
cd -