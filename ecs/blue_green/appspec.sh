#!/bin/bash

envsubst < appspec.sh

APPSPEC=$(echo '{"version":1,"Resources":[{"TargetService":{"Type":"AWS::ECS::Service","Properties":{"TaskDefinition":"'${AWS_TASK_DEFINITION_ARN}'","LoadBalancerInfo":{"ContainerName":"${CONTAINER_NAME}","ContainerPort":$CONTAINER_PORT}}}}]}' | jq -Rs .)

aws deploy create-deployment --application-name wc-users-api-dev --deployment-group-name users-deployment-group --revision revisionType=AppSpecContent,appSpecContent={content=$APPSPEC}