#!/usr/bin/env bash

curl -X POST -u admin:admin 'http://localhost:8081/api/processManagement/cancel/DetectLargeTransactions'
curl -u admin:admin -X DELETE http://localhost:8081/api/processes/DetectLargeTransactions -v

main() {
  echo "Starting docker containers.."

  docker-compose -f docker-compose.yml -f docker-compose-env.yml kill
  docker-compose -f docker-compose.yml -f docker-compose-env.yml rm -f -v
  docker-compose -f docker-compose.yml -f docker-compose-env.yml build
  docker-compose -f docker-compose.yml -f docker-compose-env.yml up -d --no-recreate

  waitForOK "api/processes" "Checking Nussknacker API response.." "Nussknacker not started" "designer"
  waitForOK "api/processes/status" "Checking connect with Flink.." "Nussknacker not connected with flink" "designer"
  waitForOK "flink/" "Checking Flink response.." "Flink not started" "jobmanager"
  waitForOK "metrics" "Checking Grafana response.." "Grafana not started" "grafana"

  echo "Creating process"
  CODE=$(curl -s -o /dev/null -w "%{http_code}" -X POST "http://admin:admin@localhost:8081/api/processes/DetectLargeTransactions/Default?isSubprocess=false")
  if [[ $CODE == 201 ]]; then
    echo "Scenario creation success"
  elif [[ $CODE == 400 ]]; then
    echo "Scenario has already exists in db."
  else
    echo "Scenario creation failed with $CODE"
    docker logs nussknacker_designer
    exit 1
  fi

  echo "Importing scenario"
  curl -u admin:admin -F 'data=@testData/DetectLargeTransactions.json' http://localhost:8081/api/processes/import/DetectLargeTransactions -v
  echo "Saving scenario"
  curl 'http://localhost:8081/api/processes/DetectLargeTransactions' -X PUT -u admin:admin -v \
    -H 'Content-Type: application/json;charset=UTF-8' \
    --data-raw $'{"process":{"id":"DetectLargeTransactions","properties":{"typeSpecificProperties":{"parallelism":1,"spillStateToDisk":true,"useAsyncInterpretation":null,"checkpointIntervalInSeconds":null,"type":"StreamMetaData"},"exceptionHandler":{"parameters":[]},"isSubprocess":false,"additionalFields":{"description":null,"groups":[],"properties":{}},"subprocessVersions":{}},"nodes":[{"additionalFields":{"layoutData":{"x":0,"y":0},"description":null},"id":"kafka-json","ref":{"typ":"kafka-json","parameters":[{"name":"topic","expression":{"language":"spel","expression":"\'asd\'"}}]},"type":"Source"},{"additionalFields":{"layoutData":{"x":0,"y":180},"description":null},"id":"filter","expression":{"language":"spel","expression":"true"},"isDisabled":null,"type":"Filter"},{"additionalFields":{"layoutData":{"x":0,"y":360},"description":null},"id":"dead-end","ref":{"typ":"dead-end","parameters":[]},"endResult":{"language":"spel","expression":"#input"},"isDisabled":null,"type":"Sink"}],"edges":[{"from":"kafka-json","to":"filter","edgeType":null},{"from":"filter","to":"dead-end","edgeType":{"type":"FilterTrue"}}],"processingType":"streaming","validationResult":{"errors":{"invalidNodes":{},"processPropertiesErrors":[],"globalErrors":[]},"warnings":{"invalidNodes":{}},"nodeResults":{"filter":{"variableTypes":{"AGG":{"display":"AggregateHelper","type":"TypedClass","refClazzName":"pl.touk.nussknacker.engine.flink.util.transformer.aggregate.AggregateHelper","params":[]},"UTIL":{"display":"util","type":"TypedClass","refClazzName":"pl.touk.nussknacker.engine.util.functions.util$","params":[]},"NUMERIC":{"display":"numeric","type":"TypedClass","refClazzName":"pl.touk.nussknacker.engine.util.functions.numeric$","params":[]},"CONV":{"display":"conversion","type":"TypedClass","refClazzName":"pl.touk.nussknacker.engine.util.functions.conversion$","params":[]},"GEO":{"display":"geo","type":"TypedClass","refClazzName":"pl.touk.nussknacker.engine.util.functions.geo$","params":[]},"DATE":{"display":"date","type":"TypedClass","refClazzName":"pl.touk.nussknacker.engine.util.functions.date$","params":[]},"meta":{"display":"{processName: String, properties: {}}","type":"TypedObjectTypingResult","fields":{"processName":{"display":"String","type":"TypedClass","refClazzName":"java.lang.String","params":[]},"properties":{"display":"{}","type":"TypedObjectTypingResult","fields":{},"refClazzName":"java.util.Map","params":[{"display":"String","type":"TypedClass","refClazzName":"java.lang.String","params":[]},{"display":"Unknown","type":"Unknown","refClazzName":"java.lang.Object","params":[]}]}},"refClazzName":"java.util.Map","params":[{"display":"String","type":"TypedClass","refClazzName":"java.lang.String","params":[]},{"display":"Unknown","type":"Unknown","refClazzName":"java.lang.Object","params":[]}]},"inputMeta":{"display":"InputMeta[String]","type":"TypedObjectTypingResult","fields":{"key":{"display":"String","type":"TypedClass","refClazzName":"java.lang.String","params":[]},"topic":{"display":"String","type":"TypedClass","refClazzName":"java.lang.String","params":[]},"partition":{"display":"Integer","type":"TypedClass","refClazzName":"java.lang.Integer","params":[]},"offset":{"display":"Long","type":"TypedClass","refClazzName":"java.lang.Long","params":[]},"timestamp":{"display":"Long","type":"TypedClass","refClazzName":"java.lang.Long","params":[]},"timestampType":{"display":"TimestampType","type":"TypedClass","refClazzName":"org.apache.kafka.common.record.TimestampType","params":[]},"headers":{"display":"Map[String,String]","type":"TypedClass","refClazzName":"java.util.Map","params":[{"display":"String","type":"TypedClass","refClazzName":"java.lang.String","params":[]},{"display":"String","type":"TypedClass","refClazzName":"java.lang.String","params":[]}]},"leaderEpoch":{"display":"Integer","type":"TypedClass","refClazzName":"java.lang.Integer","params":[]}},"refClazzName":"pl.touk.nussknacker.engine.kafka.source.InputMeta","params":[]},"input":{"display":"Map","type":"TypedClass","refClazzName":"java.util.Map","params":[]}},"parameters":null,"typingInfo":{"$expression":{"display":"Boolean","type":"TypedClass","refClazzName":"boolean","params":[]}}},"dead-end":{"variableTypes":{"AGG":{"display":"AggregateHelper","type":"TypedClass","refClazzName":"pl.touk.nussknacker.engine.flink.util.transformer.aggregate.AggregateHelper","params":[]},"UTIL":{"display":"util","type":"TypedClass","refClazzName":"pl.touk.nussknacker.engine.util.functions.util$","params":[]},"NUMERIC":{"display":"numeric","type":"TypedClass","refClazzName":"pl.touk.nussknacker.engine.util.functions.numeric$","params":[]},"CONV":{"display":"conversion","type":"TypedClass","refClazzName":"pl.touk.nussknacker.engine.util.functions.conversion$","params":[]},"GEO":{"display":"geo","type":"TypedClass","refClazzName":"pl.touk.nussknacker.engine.util.functions.geo$","params":[]},"DATE":{"display":"date","type":"TypedClass","refClazzName":"pl.touk.nussknacker.engine.util.functions.date$","params":[]},"meta":{"display":"{processName: String, properties: {}}","type":"TypedObjectTypingResult","fields":{"processName":{"display":"String","type":"TypedClass","refClazzName":"java.lang.String","params":[]},"properties":{"display":"{}","type":"TypedObjectTypingResult","fields":{},"refClazzName":"java.util.Map","params":[{"display":"String","type":"TypedClass","refClazzName":"java.lang.String","params":[]},{"display":"Unknown","type":"Unknown","refClazzName":"java.lang.Object","params":[]}]}},"refClazzName":"java.util.Map","params":[{"display":"String","type":"TypedClass","refClazzName":"java.lang.String","params":[]},{"display":"Unknown","type":"Unknown","refClazzName":"java.lang.Object","params":[]}]},"inputMeta":{"display":"InputMeta[String]","type":"TypedObjectTypingResult","fields":{"key":{"display":"String","type":"TypedClass","refClazzName":"java.lang.String","params":[]},"topic":{"display":"String","type":"TypedClass","refClazzName":"java.lang.String","params":[]},"partition":{"display":"Integer","type":"TypedClass","refClazzName":"java.lang.Integer","params":[]},"offset":{"display":"Long","type":"TypedClass","refClazzName":"java.lang.Long","params":[]},"timestamp":{"display":"Long","type":"TypedClass","refClazzName":"java.lang.Long","params":[]},"timestampType":{"display":"TimestampType","type":"TypedClass","refClazzName":"org.apache.kafka.common.record.TimestampType","params":[]},"headers":{"display":"Map[String,String]","type":"TypedClass","refClazzName":"java.util.Map","params":[{"display":"String","type":"TypedClass","refClazzName":"java.lang.String","params":[]},{"display":"String","type":"TypedClass","refClazzName":"java.lang.String","params":[]}]},"leaderEpoch":{"display":"Integer","type":"TypedClass","refClazzName":"java.lang.Integer","params":[]}},"refClazzName":"pl.touk.nussknacker.engine.kafka.source.InputMeta","params":[]},"input":{"display":"Map","type":"TypedClass","refClazzName":"java.util.Map","params":[]}},"parameters":null,"typingInfo":{"$expression":{"display":"Map","type":"TypedClass","refClazzName":"java.util.Map","params":[]}}},"kafka-json":{"variableTypes":{"AGG":{"display":"AggregateHelper","type":"TypedClass","refClazzName":"pl.touk.nussknacker.engine.flink.util.transformer.aggregate.AggregateHelper","params":[]},"UTIL":{"display":"util","type":"TypedClass","refClazzName":"pl.touk.nussknacker.engine.util.functions.util$","params":[]},"NUMERIC":{"display":"numeric","type":"TypedClass","refClazzName":"pl.touk.nussknacker.engine.util.functions.numeric$","params":[]},"CONV":{"display":"conversion","type":"TypedClass","refClazzName":"pl.touk.nussknacker.engine.util.functions.conversion$","params":[]},"GEO":{"display":"geo","type":"TypedClass","refClazzName":"pl.touk.nussknacker.engine.util.functions.geo$","params":[]},"DATE":{"display":"date","type":"TypedClass","refClazzName":"pl.touk.nussknacker.engine.util.functions.date$","params":[]},"meta":{"display":"{processName: String, properties: {}}","type":"TypedObjectTypingResult","fields":{"processName":{"display":"String","type":"TypedClass","refClazzName":"java.lang.String","params":[]},"properties":{"display":"{}","type":"TypedObjectTypingResult","fields":{},"refClazzName":"java.util.Map","params":[{"display":"String","type":"TypedClass","refClazzName":"java.lang.String","params":[]},{"display":"Unknown","type":"Unknown","refClazzName":"java.lang.Object","params":[]}]}},"refClazzName":"java.util.Map","params":[{"display":"String","type":"TypedClass","refClazzName":"java.lang.String","params":[]},{"display":"Unknown","type":"Unknown","refClazzName":"java.lang.Object","params":[]}]}},"parameters":[{"name":"topic","typ":{"display":"String","type":"TypedClass","refClazzName":"java.lang.String","params":[]},"editor":{"simpleEditor":{"type":"StringParameterEditor"},"defaultMode":"RAW","type":"DualParameterEditor"},"validators":[{"type":"MandatoryParameterValidator"},{"type":"NotBlankParameterValidator"}],"additionalVariables":{},"variablesToHide":[],"branchParam":false}],"typingInfo":{"topic":{"display":"String","type":"TypedClass","refClazzName":"java.lang.String","params":[]}}},"$exceptionHandler":{"variableTypes":{"AGG":{"display":"AggregateHelper","type":"TypedClass","refClazzName":"pl.touk.nussknacker.engine.flink.util.transformer.aggregate.AggregateHelper","params":[]},"UTIL":{"display":"util","type":"TypedClass","refClazzName":"pl.touk.nussknacker.engine.util.functions.util$","params":[]},"NUMERIC":{"display":"numeric","type":"TypedClass","refClazzName":"pl.touk.nussknacker.engine.util.functions.numeric$","params":[]},"CONV":{"display":"conversion","type":"TypedClass","refClazzName":"pl.touk.nussknacker.engine.util.functions.conversion$","params":[]},"GEO":{"display":"geo","type":"TypedClass","refClazzName":"pl.touk.nussknacker.engine.util.functions.geo$","params":[]},"DATE":{"display":"date","type":"TypedClass","refClazzName":"pl.touk.nussknacker.engine.util.functions.date$","params":[]},"meta":{"display":"{processName: String, properties: {}}","type":"TypedObjectTypingResult","fields":{"processName":{"display":"String","type":"TypedClass","refClazzName":"java.lang.String","params":[]},"properties":{"display":"{}","type":"TypedObjectTypingResult","fields":{},"refClazzName":"java.util.Map","params":[{"display":"String","type":"TypedClass","refClazzName":"java.lang.String","params":[]},{"display":"Unknown","type":"Unknown","refClazzName":"java.lang.Object","params":[]}]}},"refClazzName":"java.util.Map","params":[{"display":"String","type":"TypedClass","refClazzName":"java.lang.String","params":[]},{"display":"Unknown","type":"Unknown","refClazzName":"java.lang.Object","params":[]}]}},"parameters":null,"typingInfo":{}}}}},"comment":""}'
  echo "Deploying scenario"
  curl -u admin:admin -X POST 'http://localhost:8081/api/processManagement/deploy/DetectLargeTransactions' -v
}

waitTime=0
sleep=10
waitLimit=120
checkCode() {
 echo "$(curl -s -o /dev/null -w "%{http_code}" "http://admin:admin@localhost:8081/$1")"
}

waitForOK() {
  echo "$2"

  URL_PATH=$1
  STATUS_CODE=$(checkCode "$URL_PATH")
  CONTAINER_FOR_LOGS=$4

  while [[ $waitTime -lt $waitLimit && $STATUS_CODE != 200 ]]
  do
    sleep $sleep
    waitTime=$((waitTime+sleep))
    STATUS_CODE=$(checkCode "$URL_PATH")

    if [[ $STATUS_CODE != 200  ]]
    then
      echo "Service still not started within $waitTime sec and response code: $STATUS_CODE.."
    fi
  done
  if [[ $STATUS_CODE != 200 ]]
  then
    echo "$3"
    docker-compose -f docker-compose-env.yml -f docker-compose.yml logs --tail=200 $CONTAINER_FOR_LOGS
    exit 1
  fi
}

main;
exit;