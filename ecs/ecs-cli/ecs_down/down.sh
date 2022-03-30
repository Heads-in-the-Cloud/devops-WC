#!/bin/bash

sed -e 's/$SERVICE/'"${1}"':/g' definition_files/compose-template.yaml > temp-docker-compose.yaml



# Inject environment variables into definition file
envsubst < "temp-docker-compose.yaml" > "docker-compose.yaml"

rm temp-docker-compose.yaml

ecs-cli compose --project-name ${1} --file docker-compose.yaml --region ${AWS_DEFAULT_REGION} service rm --timeout 10
