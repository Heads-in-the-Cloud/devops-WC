#!/bin/bash

# $1=repository
# $2=container
# $3=service
# $4=targetgrouparn


export IMAGE=$1

sed -e 's/$SUBNET1/'"${PUBLIC_SUBNET1}"'/g' \
    -e 's/$SUBNET2/'"${PUBLIC_SUBNET2}"'/g' \
    -e 's/$SECURITY_GROUP/'"${SECURITY_GROUP}"'/g' \
    -e 's/$SERVICE/'"${2}"'/g' ecs-template.yaml > ecs-params.yaml

sed -e 's/$SERVICE/'"${2}"'/g' compose-template.yaml | sed '/'"${2}"':/a \
environment: \
- DB_USER=${DB_USER} \
- DB_USER_PASSWORD=${DB_USER_PASSWORD} \
- SECRET_KEY=${SECRET_KEY} \
- DB_HOST=${DB_HOST} \
- USERS_PORT=${PORT}' > docker-compose.yaml

ecs-cli compose --file docker-compose.yaml --project-name ${3} \
--ecs-params ecs-params.yaml service up \
--force-deployment \
--target-groups "targetGroupArn=${4},containerName=${2},containerPort=${PORT}" 


# if [[ ${PARAM_ACTION} = 'create' || ${PARAM_CONTAINER} = 'users' ]]
# then
#     echo 'users'

#     export IMAGE=${USERS_REPO}
#     sed -e 's/$SUBNET1/'"${PUBLIC_SUBNET1}"'/g' \
#         -e 's/$SUBNET2/'"${PUBLIC_SUBNET2}"'/g' \
#         -e 's/$SECURITY_GROUP/'"${SECURITY_GROUP}"'/g' \
#         -e 's/$SERVICE/'"${USERS_CONTAINER}"'/g' ecs-template.yaml > ecs-params.yaml

#     sed -e 's/$SERVICE/'"${USERS_CONTAINER}"'/g' compose-template.yaml | sed '/'"${USERS_CONTAINER}"':/a \
#     environment: \
#     - DB_USER=${DB_USER} \
#     - DB_USER_PASSWORD=${DB_USER_PASSWORD} \
#     - SECRET_KEY=${SECRET_KEY} \
#     - DB_HOST=${DB_HOST} \
#     - USERS_PORT=${PORT}' > docker-compose.yaml

#     ecs-cli compose --file docker-compose.yaml --project-name ${USERS_SERVICE} \
#     --ecs-params ecs-params.yaml service up \
#     --force-deployment \
#     --target-groups "targetGroupArn=${USERS_TG},containerName=${USERS_CONTAINER},containerPort=${PORT}" 
# fi

# if [[ ${PARAM_ACTION} = 'create' || ${PARAM_CONTAINER} = 'flights' ]]
# then
#     echo 'flights'
#     export IMAGE=${FLIGHTS_REPO}
#     sed -e 's/$SUBNET1/'"${PUBLIC_SUBNET1}"'/g' \
#         -e 's/$SUBNET2/'"${PUBLIC_SUBNET2}"'/g' \
#         -e 's/$SECURITY_GROUP/'"${SECURITY_GROUP}"'/g' \
#         -e 's/$SERVICE/'"${FLIGHTS_CONTAINER}"'/g' \
#         ecs-template.yaml > ecs-params.yaml

#     sed -e 's/$SERVICE/'"${FLIGHTS_CONTAINER}"'/g' compose-template.yaml | sed '/'"${FLIGHTS_CONTAINER}"':/a \
#     environment: \
#     - DB_USER=${DB_USER} \
#     - DB_USER_PASSWORD=${DB_USER_PASSWORD} \
#     - SECRET_KEY=${SECRET_KEY} \
#     - DB_HOST=${DB_HOST} \
#     - FLIGHTS_PORT=${PORT}' > docker-compose.yaml

#     ecs-cli compose --file docker-compose.yaml --project-name ${FLIGHTS_SERVICE} \
#     --ecs-params ecs-params.yaml service up \
#     --force-deployment \
#     --target-groups "targetGroupArn=${FLIGHTS_TG},containerName=${FLIGHTS_CONTAINER},containerPort=${PORT}" 
# fi

# if [[ ${PARAM_ACTION} = 'create' || ${PARAM_CONTAINER} = 'bookings' ]]
# then
#     echo 'bookings'
#     export IMAGE=${BOOKINGS_REPO}
#     sed -e 's/$SUBNET1/'"${PUBLIC_SUBNET1}"'/g' \
#         -e 's/$SUBNET2/'"${PUBLIC_SUBNET2}"'/g' \
#         -e 's/$SECURITY_GROUP/'"${SECURITY_GROUP}"'/g' \
#         -e 's/$SERVICE/'"${BOOKINGS_CONTAINER}"'/g' \
#         ecs-template.yaml > ecs-params.yaml

#     sed -e 's/$SERVICE/'"${BOOKINGS_CONTAINER}"'/g' compose-template.yaml | sed '/'"${BOOKINGS_CONTAINER}"':/a \
#     environment: \
#     - DB_USER=${DB_USER} \
#     - DB_USER_PASSWORD=${DB_USER_PASSWORD} \
#     - SECRET_KEY=${SECRET_KEY} \
#     - DB_HOST=${DB_HOST} \
#     - BOOKINGS_PORT=${PORT}' > docker-compose.yaml

#     ecs-cli compose --file docker-compose.yaml --project-name ${BOOKINGS_SERVICE} \
#     --ecs-params ecs-params.yaml service up \
#     --force-deployment \
#     --target-groups "targetGroupArn=${BOOKINGS_TG},containerName=${BOOKINGS_CONTAINER},containerPort=${PORT}"
# fi

# if [[ ${PARAM_ACTION} = 'create' || ${PARAM_CONTAINER} = 'frontend' ]]
# then
#     echo 'frontend'
#     export IMAGE=${FRONTEND_REPO}
#     sed -e 's/$SUBNET1/'"${PUBLIC_SUBNET1}"'/g' \
#         -e 's/$SUBNET2/'"${PUBLIC_SUBNET2}"'/g' \
#         -e 's/$SECURITY_GROUP/'"${SECURITY_GROUP}"'/g' \
#         -e 's/$SERVICE/'"${FRONTEND_CONTAINER}"'/g' \
#         ecs-template.yaml > ecs-params.yaml

#     sed -e 's/$SERVICE/'"${FRONTEND_CONTAINER}"'/g' compose-template.yaml | sed '/'"${FRONTEND_CONTAINER}"':/a \
#     environment: \
#     - SECRET_KEY=${SECRET_KEY} \
#     - HOST_DOMAIN=http://${HOST_DOMAIN} \
#     - FRONTEND_PORT=${PORT}' > docker-compose.yaml

#     ecs-cli compose --file docker-compose.yaml --project-name ${FRONTEND_SERVICE} \
#     --ecs-params ecs-params.yaml service up \
#     --force-deployment \
#     --target-groups "targetGroupArn=${FRONTEND_TG},containerName=${FRONTEND_CONTAINER},containerPort=${PORT}"
# fi