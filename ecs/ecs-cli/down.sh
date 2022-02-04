#!/bin/bash

sed -e 's/$SERVICE/'"${USERS_CONTAINER}"'/g' compose-template.yaml > docker-compose.yaml

ecs-cli compose --project-name ${USERS_SERVICE} --file docker-compose.yaml service rm

sed -e 's/$SERVICE/'"${FLIGHTS_CONTAINER}"'/g' compose-template.yaml > docker-compose.yaml

ecs-cli compose --project-name ${FLIGHTS_SERVICE} --file docker-compose.yaml service rm

sed -e 's/$SERVICE/'"${BOOKINGS_CONTAINER}"'/g' compose-template.yaml > docker-compose.yaml

ecs-cli compose --project-name ${BOOKINGS_SERVICE} --file docker-compose.yaml service rm

sed -e 's/$SERVICE/'"${FRONTEND_CONTAINER}"'/g' compose-template.yaml > docker-compose.yaml

ecs-cli compose --project-name ${FRONTEND_SERVICE} --file docker-compose.yaml service rm

ecs-cli down --cluster ECS-Cluster-WC -f

aws cloudformation delete-stack --stack-name ${STACK_NAME}
