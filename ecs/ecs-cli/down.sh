#!/bin/bash

sed -e 's/$SERVICE/'"${1}"':/g' compose-template.yaml > temp-docker-compose.yaml


rm -f docker-compose.yaml temp.yaml
( echo "cat <<EOF >docker-compose.yaml";
  cat temp-docker-compose.yaml;
) >temp.yaml
. temp.yaml


cat docker-compose.yaml
rm temp.yaml
rm temp-docker-compose.yaml

ecs-cli compose --project-name ${1} --file docker-compose.yaml --timeout 10 service rm
