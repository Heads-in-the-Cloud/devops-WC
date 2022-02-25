#!/bin/bash

# $1=repository
# $2=container
# $3=service
# $4=targetgrouparn


export IMAGE=$1

sed -e 's/$SUBNET1/'"${PUBLIC_SUBNET1}"'/g' \
    -e 's/$SUBNET2/'"${PUBLIC_SUBNET2}"'/g' \
    -e 's/$SECURITY_GROUP/'"${SECURITY_GROUP}"'/g' \
    -e 's/$SERVICE/'"${2}"'/g ' \
    -e 's/$CPU_LIMIT/'"${5}"'/g ' \
    -e 's/$MEM_LIMIT/'"${6}"'/g ' ecs-template.yaml > ecs-params.yaml

sed -e 's/$SERVICE/'"${2}"'/g' compose-template.yaml | sed '/'"${2}"':/a \
    environment: \
    - DB_USER=${DB_USER} \
    - DB_USER_PASSWORD=${DB_USER_PASSWORD} \
    - SECRET_KEY=${SECRET_KEY} \
    - DB_HOST=${DB_HOST} \
    - ${2}_PORT=${PORT} \
    - HOST_DOMAIN=${7}'> docker-compose.yaml


ecs-cli compose --file docker-compose.yaml --project-name ${3} \
--ecs-params ecs-params.yaml service up \
--force-deployment \
--target-groups "targetGroupArn=${4},containerName=${2},containerPort=${PORT}" 

