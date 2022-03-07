#!/bin/bash

echo $AWS_REGION

#Split first argument into array
IFS=',' read -ra ECS_VARS <<< "$2"

#Environment variables metadata for yaml
ARGS='environment: \'

#Extract arguments split by comma and parse key value pairs
for i in "${!ECS_VARS[@]}"
do
    IFS='=' read -ra var <<< ${ECS_VARS[$i]}
    temp=${var[1]////'\/'}
    temp=${temp//\'/}
    echo $temp
    ARGS+="
     - ${var[0]}=$temp" # replace all slashes to appease SED

    if [[ i -lt ${#ECS_VARS[@]}-1 ]]; then
      ARGS+=' \'
    fi
done

echo $ARGS

sed -e 's/$SERVICE/'"${1}:"' \
    '"$ARGS"' /g' compose-template.yaml > temp-docker-compose.yaml

# Inject all environment variables in ecs-params-template.yaml
rm -f ecs-params.yaml temp.yaml
( echo "cat <<EOF >ecs-params.yaml";
  cat ecs-template.yaml;
  echo "EOF";
) >temp.yaml
. temp.yaml


# Inject all environment variables in compose-template.yaml
rm -f docker-compose.yaml temp.yaml
( echo "cat <<EOF >docker-compose.yaml";
  cat temp-docker-compose.yaml;
) >temp.yaml
. temp.yaml


rm temp.yaml
rm temp-docker-compose.yaml

cat docker-compose.yaml
cat ecs-params.yaml



ecs-cli compose --file docker-compose.yaml --project-name ${1} \
--ecs-params ecs-params.yaml service up \
--force-deployment \
--target-groups "targetGroupArn=${3},containerName=${1},containerPort=${PORT}" 

ecs-cli compose --project-name ${1} --file docker-compose.yaml service scale ${DESIRED_COUNT}