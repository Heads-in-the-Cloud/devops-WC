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

ecs-cli compose --project-name ${1} --file docker-compose.yaml service rm

# sed -e 's/$SERVICE/'"${FLIGHTS_CONTAINER}"'/g' compose-template.yaml > docker-compose.yaml

# ecs-cli compose --project-name ${FLIGHTS_SERVICE} --file docker-compose.yaml service rm

# sed -e 's/$SERVICE/'"${BOOKINGS_CONTAINER}"'/g' compose-template.yaml > docker-compose.yaml

# ecs-cli compose --project-name ${BOOKINGS_SERVICE} --file docker-compose.yaml service rm

# sed -e 's/$SERVICE/'"${FRONTEND_CONTAINER}"'/g' compose-template.yaml > docker-compose.yaml

# ecs-cli compose --project-name ${FRONTEND_SERVICE} --file docker-compose.yaml service rm

# ecs-cli down --cluster ECS-Cluster-WC -f

aws cloudformation delete-stack --stack-name ${STACK_NAME}
