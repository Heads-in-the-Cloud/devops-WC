#!/bin/bash


#Parameter 1: name of service
#Parameter 2: comma-separated environment variables in key-value pairs
#Parameter 3: target-group arn to be associated with service

#Split second argument into array
IFS=',' read -ra ECS_VARS <<< "$2"

#Environment variables metadata for yaml
ARGS='environment: \'

#Extract arguments split by comma and parse key value pairs
for i in "${!ECS_VARS[@]}"
do
    IFS='=' read -ra var <<< ${ECS_VARS[$i]}
    temp=${var[1]////'\/'}
    temp=${temp//\'/}
    ARGS+="
     - ${var[0]}=$temp" # replace all slashes to appease SED

    if [[ i -lt ${#ECS_VARS[@]}-1 ]]; then
      ARGS+=' \'
    fi
done


#Use sed to insert environment variables metadata
sed -e 's/$SERVICE/'"${1}:"' \
    '"$ARGS"' /g' definition_files/compose-template.yaml > ${1}-temp-docker-compose.yaml


# Inject environment variables in definition files
envsubst < "./definition_files/ecs-template.yaml" > "${1}-ecs-params.yaml"
envsubst < "${1}-temp-docker-compose.yaml" > "${1}-docker-compose.yaml"


# Remove temporary files
rm ${1}-temp-docker-compose.yaml

cat "${1}-docker-compose.yaml"
cat "${1}-ecs-params.yaml"


#Docker-Compose Up with target-group 
ecs-cli compose --file "${1}-docker-compose.yaml" --project-name ${1}  --region "${AWS_DEFAULT_REGION}" \
--ecs-params "${1}-ecs-params.yaml" service up \
--force-deployment \
--target-groups "targetGroupArn=${3},containerName=${1},containerPort=${PORT}" 

#Scale the service to the desired count
# ecs-cli compose --project-name ${1} --file "${1}-docker-compose.yaml" service scale ${DESIRED_COUNT}

rm "${1}-ecs-params.yaml"
rm "${1}-docker-compose.yaml"